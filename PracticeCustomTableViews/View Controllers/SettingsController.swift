//
//  SettingsController.swift
//  PracticeCustomTableViews
//
//  Created by John McCants on 10/19/21.
//

import Foundation
import UIKit

class SettingsController: UIViewController, UINavigationControllerDelegate {
    
    var currentUser: User
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        iv.layer.borderColor = UIColor.white.cgColor
        iv.layer.borderWidth = 4
        iv.isUserInteractionEnabled = true
        return iv

    }()
    
//    private let cancelButton: UIBarButtonItem = {
//        let cb = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonTapped))
//        return cb
//    }()
    
    private let saveButton: UIBarButtonItem = {
        let cb = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveButtonTapped))
        return cb
    }()
    
    private let aboutTextView: UITextView = {
        let tv = UITextView()
        tv.layer.borderWidth = 1
        tv.layer.borderColor = UIColor.lightGray.cgColor
        tv.isEditable = true
        tv.isUserInteractionEnabled = true
        tv.isSelectable = true
        return tv
    }()
    
    private let logoutButton: UIButton = {
        let lb = UIButton()
        lb.setTitle("Logout", for: .normal)
        lb.setTitleColor(UIColor.red, for: .normal)
        lb.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
        lb.layer.cornerRadius = lb.viewWidth / 2
        lb.layer.backgroundColor = UIColor.systemRed.cgColor
        lb.setTitleColor(UIColor.white, for: .normal)
        
        return lb
    }()
    
    var imagePicker = UIImagePickerController()
    
    init(currentUser: User) {
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupStack()
        configure()
        setupUserInfo()
        
    }
    
    func configure() {
        self.view.backgroundColor = .white
        self.navigationController?.delegate = self
        self.navigationItem.title = "Edit Profile"
        self.view.isUserInteractionEnabled = true
        self.aboutTextView.delegate = self
        self.imagePicker.delegate = self
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.profileImageViewTapped))
        self.profileImageView.addGestureRecognizer(tap)
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.barStyle = .default
        
    }
    
    func setupUserInfo() {
        if let url = currentUser.profileImageUrl {
            self.profileImageView.sd_setImage(with: url, completed: nil)
        } else {
            self.profileImageView.image = UIImage(named: "blank")
        }
        
        self.aboutTextView.text = currentUser.aboutText
    }
    
    func setupStack() {
        
        // Profile Image View
        view.addSubview(profileImageView)
        profileImageView.anchor(top: self.view.safeAreaLayoutGuide.topAnchor, paddingTop: 20)
        profileImageView.setDimensions(width: 80, height: 80)
        profileImageView.layer.cornerRadius = 80 / 2
        profileImageView.centerX(inView: self.view)
        profileImageView.clipsToBounds = true
        profileImageView.image = UIImage(named: "test")
        
        // About TextView
        view.addSubview(aboutTextView)
        aboutTextView.anchor(top: profileImageView.bottomAnchor, left: self.view.safeAreaLayoutGuide.leftAnchor, right: self.view.safeAreaLayoutGuide.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingRight: 20, height: 100)
        
        // Right Bar Button Item
        self.navigationItem.rightBarButtonItem = saveButton
        saveButton.isEnabled = false
        
        // Left Bar Button Item
//        self.navigationItem.leftBarButtonItem = cancelButton
        
        // Logout Button
        view.addSubview(logoutButton)
        logoutButton.anchor(left: self.view.safeAreaLayoutGuide.leftAnchor, bottom: self.view.bottomAnchor, right: self.view.safeAreaLayoutGuide.rightAnchor, paddingLeft: 20, paddingBottom: 40, paddingRight: 20, height: 40)
        
        
    }
    
    func presentLogin() {
        let storyboard = UIStoryboard(name: "SignUp", bundle: nil)
        UserDefaults.standard.set(false, forKey: "isUserLoggedIn")
        UserDefaults.standard.set("", forKey: "uid")
        UserDefaults.standard.synchronize()
        let loginVC = storyboard.instantiateViewController(identifier: "LoginViewController") as! LoginViewController
        loginVC.modalPresentationStyle = .fullScreen
        self.present(loginVC, animated: true) {
        }
        
    }
    
    @objc func saveButtonTapped() {
        // Firebase Function To
        guard let profileImage = self.profileImageView.image, let aboutText = self.aboutTextView.text else { return }
        AuthService.shared.updateUserImage(image: profileImage) { err, ref in
            AuthService.shared.updateAboutText(aboutText: aboutText) { err, ref in
                self.saveButton.isEnabled = false
            }
        }
        
    }
    
    @objc func cancelButtonTapped() {
        self.navigationController?.dismiss(animated: true, completion: nil)
        
    }
    
    @objc func logoutButtonTapped() {
        AuthService.shared.logoutUser()
            self.presentLogin()
    }
    
    @objc func profileImageViewTapped() {
        print("ProfileImageViewTapped")
        self.present(imagePicker, animated: true, completion: nil)
        
    }
    
 
    
    
    
    
    
}

extension SettingsController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.saveButton.isEnabled = true
        
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.profileImageView.image = pickedImage
        }
        picker.dismiss(animated: true, completion: nil)
        
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension SettingsController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        saveButton.isEnabled = true
        
    }
    
}
