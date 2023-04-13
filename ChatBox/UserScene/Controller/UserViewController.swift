//
//  UserViewController.swift
//  ChatBox
//
//  Created by Alexander Chervoncev on 28/3/2023.
//

import UIKit
import Firebase
import SDWebImage
import FirebaseStorage

final class UserViewController: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var editPhotoButton: UIButton!
        
    //MARK: - Inits
    lazy var service = UserService()
    lazy var user = [UserModel]()
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
        userInfoGet()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        view.layoutIfNeeded()
        avatarImageView.makeRounded()
        self.view.layoutIfNeeded()
    }
}

//MARK: - Extension UIImagePicker
extension UserViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
        
        // загрузка аватара и отправвление его в коллекцию user
        service.uploadAvatar(image: image) { [weak self] result in
            switch result {
                
            case .success(let url):
                guard let self = self else { return }
                DispatchQueue.global(qos: .userInitiated).async {
                    self.avatarImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder"))
                    self.service.updateUserProfile(avatarURL: url)
                }
            case .failure(let error):
                print("Error uploading avatar: \(error.localizedDescription)")
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

//MARK: - Private Extension
private extension UserViewController {
    
    // получение всех данных о пользователе
    private func userInfoGet() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        let ref = Storage.storage().reference().child("avatars").child(currentUserId)
        
        service.userInfo { [weak self] user in
            DispatchQueue.global(qos: .userInitiated).async {
                guard let self = self, let userInfo = user.first else { return }
                
                ref.downloadURL { (url, error) in
                    if let error = error {
                        print("Error getting avatar URL: \(error.localizedDescription)")
                    } else if let url = url {
                        self.avatarImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder"))
                    }
                }
                DispatchQueue.main.async {
                    self.nicknameLabel.text = userInfo.nickname
                    self.emailLabel.text = userInfo.email
                }
            }
        }
    }

    // выход из аккаунта
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
