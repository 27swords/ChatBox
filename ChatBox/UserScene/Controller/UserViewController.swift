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
    private let service = UserService()
    private var user = [UserModel]()
    var userDefault = UserDefaults.standard
    
    //MARK: - IBAction
    @IBAction func logOutAction(_ sender: Any) {
        logOutAcount()
    }

    @IBAction func editPhotoAction(_ sender: Any) {
        editPhoto()
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)

        guard let image = info[.originalImage] as? UIImage else {
            print("Error: Selected image could not be converted to UIImage.")
            return
        }
        
        // загрузка аватара и отправвление его в коллекцию user
        service.uploadAvatar(image: image) { result in
            switch result {
                
            case .success(let url):
                self.avatarImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder"))
                self.service.updateUserProfile(avatarURL: url)
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
    
    private func editPhoto() {
        let imagePickerController = UIImagePickerController()
        
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }
    
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
