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
    var originalImage: UIImage?
    var newImage: UIImage? {
        didSet {
            saveButton.isEnabled = true
        }
    }
    var loadingIndicator = UIActivityIndicatorView()
    
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
    
    let saveButton: UIBarButtonItem = {
        let cb = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveButtonTapped))
        cb.tag = 1
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
    
    private let instagramLabel: UILabel = {
       let lb = UILabel()
        lb.text = "Instagram"
        lb.font = UIFont(name: "Helvetica-Medium", size: 14)
    
        return lb
    }()
    
    private let instagramTextField: UITextField = {
        let tf = UITextField()
        tf.font = UIFont(name: "Helvetica-Medium", size: 14)
        tf.autocorrectionType = .no
        tf.placeholder = "Instagram Username"
        tf.borderStyle = .roundedRect
        
        return tf
    }()
    
    private let twitterLabel: UILabel = {
        let lb = UILabel()
        lb.text = "Twitter"
        lb.font = UIFont(name: "Helvetica-Medium", size: 14)
        return lb
    }()
    
    private let twitterTextField: UITextField = {
        let tf = UITextField()
        tf.font = UIFont(name: "Helvetica-Medium", size: 14)
        tf.autocorrectionType = .no
        tf.placeholder = "Twitter Username"
        tf.borderStyle = .roundedRect
        return tf
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
        print("Settings View Did Load Called")
        setupStack()
        configure()
        setupUserInfo()
        loadingIndicator.hidesWhenStopped = true
        self.hideKeyboardWhenTappedAround()
    }
    
    func configure() {
        self.view.isUserInteractionEnabled = true
        self.navigationController?.navigationBar.isUserInteractionEnabled = true
        self.view.backgroundColor = .white
        self.navigationController?.delegate = self
        self.navigationItem.title = "Edit Profile"
        self.view.isUserInteractionEnabled = true
        self.aboutTextView.delegate = self
        self.aboutTextView.autocorrectionType = .no
        self.imagePicker.delegate = self
        self.imagePicker.allowsEditing = true
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
        self.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .save
                                                              , target: self, action: #selector(saveButtonTapped)), animated: true)
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        
        // Logout Button
        view.addSubview(logoutButton)
        logoutButton.anchor(left: self.view.safeAreaLayoutGuide.leftAnchor, bottom: self.view.bottomAnchor, right: self.view.safeAreaLayoutGuide.rightAnchor, paddingLeft: 20, paddingBottom: 40, paddingRight: 20, height: 40)
        
        setupLabelsTextFields()
        
        view.addSubview(loadingIndicator)
        loadingIndicator.isHidden = true
        loadingIndicator.centerX(inView: self.view)
        loadingIndicator.centerY(inView: self.view)
        
    }
    
    func setupLabelsTextFields() {
        twitterTextField.delegate = self
        instagramTextField.delegate = self
        if currentUser.twitterUsername != "" {
            twitterTextField.text = currentUser.twitterUsername
        }
        if currentUser.instagramUsername != "" {
            instagramTextField.text = currentUser.instagramUsername
        }
        let stack = UIStackView(arrangedSubviews: [instagramLabel, instagramTextField, twitterLabel, twitterTextField])
        view.addSubview(stack)
        stack.spacing = 5
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.anchor(top: self.aboutTextView.bottomAnchor, left: self.view.leftAnchor, right: self.view.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingRight: 20)
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
        print("Save Button Tapped")
        loadingIndicator.isHidden = false
        loadingIndicator.startAnimating()
        if let newImage = newImage {
            AuthService.shared.updateUserImage(image: newImage) { err, ref in
                if err == nil {
                    print("Success Saving Image")
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refetchUser"), object: nil)
                    print("Refetch User called")
                }
            }
        }
        
        if let aboutText = self.aboutTextView.text, !aboutText.isEmpty {
            AuthService.shared.updateAboutText(aboutText: aboutText) { err, ref in
                if err == nil {
                    print("Success Updating Text")
                }
            }
        }
        
        if let instagramUsername = self.instagramTextField.text, !instagramUsername.isEmpty {
            AuthService.shared.updateInstagramUsername(username: instagramUsername.lowercased())
        }
        
        if let twitterUsername = self.twitterTextField.text, !twitterUsername.isEmpty {
            AuthService.shared.updateTwitterUsername(username: twitterUsername.lowercased())
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refetchCurrentUser"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refetchUser"), object: nil)
            self.loadingIndicator.stopAnimating()
        }
        
        
        self.navigationItem.rightBarButtonItem?.isEnabled = false
        self.aboutTextView.resignFirstResponder()
        
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
    
    @objc func updateObserver() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refetchCurrentUser"), object: nil)
        loadingIndicator.stopAnimating()
       
    }
}

extension SettingsController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.profileImageView.image = pickedImage
            self.newImage = pickedImage
         
        }
        picker.dismiss(animated: true) {
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        }
        
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
        self.newImage = nil
    }
}

extension SettingsController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        self.navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        var newText = textView.text!
        newText.removeAll { (character) -> Bool in
            return character == " " || character == "\n"
        }

        return (newText.count + text.count) <= 140
    }
    
}

extension SettingsController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.navigationItem.rightBarButtonItem?.isEnabled = true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            
            let maxLength : Int
            
            if textField == instagramTextField{
                maxLength = 30
                let currentString: NSString = textField.text! as NSString
                
                let newString: NSString =  currentString.replacingCharacters(in: range, with: string) as NSString
                return newString.length <= maxLength
            } else if textField == twitterTextField{
                maxLength = 15
                let currentString: NSString = textField.text! as NSString
                
                let newString: NSString =  currentString.replacingCharacters(in: range, with: string) as NSString
                return newString.length <= maxLength
            } else {
                
            maxLength = 40
        
        let currentString: NSString = textField.text! as NSString
        
        let newString: NSString =  currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
            
            }
        }
    
   
}
