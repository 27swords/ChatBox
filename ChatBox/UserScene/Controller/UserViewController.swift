//
//  UserViewController.swift
//  ChatBox
//
//  Created by Alexander Chervoncev on 28/3/2023.
//

import UIKit
import Firebase
import FirebaseStorage
import PhotosUI

final class UserViewController: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nicknameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var editPhotoButton: UIButton!
        
    //MARK: - Inits
    lazy var database = DatabaseManager()
    lazy var user = [DTO]()
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
            try await userInfoGet()
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        avatarImageView.makeRounded()
        navigationController?.navigationBar.prefersLargeTitles = true
    }
}

//MARK: - Extension UIImagePicker
extension UserViewController: PHPickerViewControllerDelegate {
    
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
                        let url = try await self.database.uploadAvatar(image: image)
                        try await self.database.updateUserProfile(avatarURL: url)
                        DispatchQueue.main.async {
                            self.avatarImageView.image = image
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
private extension UserViewController {
    
    private func userInfoGet() async throws {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            throw UserServiceError.userNotLoggedIn
        }
        
        let ref = Storage.storage().reference().child("avatars").child(currentUserId)
        
        do {
            let user = try await database.userInfo()
            self.user = user
            guard let userInfo = user.first else { return }
            
            do {
                let url = try await ref.downloadURL()
                avatarImageView.sd_setImage(with: url)
            } catch {
                print("Failed to download user's profile picture:", error)
                avatarImageView.image = UIImage(named: "default_profile_picture")
            }
            
            DispatchQueue.main.async {
                self.nicknameLabel.text = userInfo.nickname
                self.emailLabel.text = userInfo.email
            }
        } catch {
            throw error
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


