//
//  ProfileViewController.swift
//  ChatBox
//
//  Created by Alexander Chervoncev on 28/3/2023.
//

import UIKit
import Firebase
import SDWebImage

final class ProfileViewController: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var imageIconImageView: UIImageView!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var editPhotoButton: UIButton!
    
    //MARK: - Inits
    lazy var service = ProfileService()
    lazy var profile = [DTO]()
    var userDefault = UserDefaults.standard
    
    //MARK: - IBAction
    @IBAction func logOutAction(_ sender: Any) {
        logOutAcount()
    }
    
    @IBAction func editPhotoAction(_ sender: Any) {
        presentPhotoActionSheet()
    }
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        Task { @MainActor in
            await profileGet()
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        imageIconImageView.makeRounded()
        navigationController?.navigationBar.prefersLargeTitles = true
    }
}

//MARK: - Extension UIImagePickerController
extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func presentPhotoActionSheet() {
        let actionSheet = UIAlertController(title: nil,
                                            message: nil,
                                            preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Закрыть",
                                            style: .cancel,
                                            handler: nil))
        
        actionSheet.addAction(UIAlertAction(title: "Сделать фото",
                                            style: .default,
                                            handler: { [weak self] _ in
            self?.presentCamera()
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Выбрать из галереи",
                                            style: .default,
                                            handler: { [weak self] _ in
            self?.presentPhotoPicker()
        }))
        
        
        if let rootVC = UIApplication.shared.windows.first?.rootViewController {
            if UIDevice.current.userInterfaceIdiom == .pad {
                actionSheet.popoverPresentationController?.sourceView = rootVC.view
                actionSheet.popoverPresentationController?.sourceRect = CGRect(x: rootVC.view.bounds.midX, y: rootVC.view.bounds.midY, width: 0, height: 0)
                actionSheet.popoverPresentationController?.permittedArrowDirections =  []
                
            }
            rootVC.present(actionSheet, animated: true, completion: nil)
        }
        
    }
    
    func presentCamera() {
        let imagePickerController = UIImagePickerController()
        
        imagePickerController.delegate = self
        imagePickerController.sourceType = .camera
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true)
    }
    
    func presentPhotoPicker() {
        let imagePickerController = UIImagePickerController()
        
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.allowsEditing = true
        present(imagePickerController, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[.editedImage] as? UIImage else {
            print("Error: Selected image could not be converted to UIImage.")
            return
        }
        
        self.service.uploadUserIcon(image: image) { [weak self] result in
            switch result {
            case .success(let url):
                Task {
                    do {
                        try await self?.service.updateUserProfile(userIconURL: url)
                        DispatchQueue.main.async {
                            self?.imageIconImageView.image = image
                        }
                    } catch {
                        print("error \(error)")
                    }
                }
            case .failure(let error):
                print("error \(error)")
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

//MARK: - Private Extension
private extension ProfileViewController {
    
    private func editPhoto() {
        let imagePickerController = UIImagePickerController()
        
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }
    
    private func updateUI(user: DTO) {
        self.nicknameLabel.text = user.username
        self.emailLabel.text = user.email
        
        guard let url = URL(string: user.userIconURL) else {
            self.imageIconImageView.image = UIImage(systemName: "person")
            return
        }
        
        imageIconImageView.sd_setImage(with: url) { [weak self] (image, error, cacheType, url) in
            guard let self = self else { return }
            
            if let error = error {
                print("Failed to load image with error: \(error.localizedDescription)")
            } else {
                DispatchQueue.global(qos: .userInitiated).async {
                    let resizedImage = image?.sd_resizedImage(with: CGSize(width: 100, height: 100), scaleMode: .aspectFill)
                    SDImageCache.shared.store(resizedImage, forKey: url?.absoluteString)
                    
                    DispatchQueue.main.async {
                        self.imageIconImageView.image = resizedImage
                    }
                }
            }
        }
    }
    
    private func profileGet() async {
        do {
            profile = try await service.profileGet()
            if let profile = profile.first {
                updateUI(user: profile)
            }
        } catch {
            print("Error profileGet", error.localizedDescription)
        }
    }
    
    private func logOutAcount() {
        do {
            try Auth.auth().signOut()
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let startVC = storyboard.instantiateViewController(withIdentifier: "StartViewController")
            
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first else {
                return
            }
            
            window.rootViewController = startVC
            userDefault.set(false, forKey: "isLogin")
            
        } catch let signOutError as NSError {
            print("Error signing out: %Q", signOutError)
        }
    }
}


