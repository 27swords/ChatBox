//
//  ProfileViewController.swift
//  ChatBox
//
//  Created by Alexander Chervoncev on 28/3/2023.
//

import UIKit
import Firebase
import PhotosUI

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

//MARK: - Extension UIImagePicker
extension ProfileViewController: PHPickerViewControllerDelegate {
    
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

        present(actionSheet, animated: true)
    }

    func presentCamera() {
        
    }

    func presentPhotoPicker() {
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.selectionLimit = 1
        configuration.filter = .images
        let vc = PHPickerViewController(configuration: configuration)
        vc.delegate = self
        present(vc, animated: true)
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        
        results.forEach { result in
            result.itemProvider.loadObject(ofClass: UIImage.self) { reading, error in
                guard let image = reading as? UIImage, error == nil else {
                    return
                }
                
                Task { @MainActor in
                    do {
                        let url = try await self.service.uploadUserIcon(image: image)
                        try await self.service.updateUserProfile(userIconURL: url)
                        DispatchQueue.main.async {
                            self.imageIconImageView.image = image
                        }
                        
                    } catch {
                        print("error \(error)")
                    }
                }
            }
        }
    }
}

//MARK: - Private Extension
private extension ProfileViewController {
    
    private func updateUI(user: DTO) {
        DispatchQueue.global(qos: .userInteractive).async {
            self.imageIconImageView.sd_setImage(with: URL(string: user.userIconURL))
            
            DispatchQueue.main.async {
                self.nicknameLabel.text = user.username
                self.emailLabel.text = user.email
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


