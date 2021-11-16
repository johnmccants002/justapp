//
//  SettingsController.swift
//  PracticeCustomTableViews
//
//  Created by John McCants on 10/19/21.
//

import Foundation
import UIKit

class SettingsController: UIViewController, UINavigationControllerDelegate {
    
    // MARK: - Properties
    
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
        lb.layer.backgroundColor = UIColor.systemRed.cgColor
        lb.setTitleColor(UIColor.white, for: .normal)
        return lb
    }()
    
    private let addPhotoButton: UIButton = {
        let button = UIButton()
        button.setTitle("Change Photo", for: .normal)
        button.addTarget(self, action: #selector(profileImageViewTapped), for: .touchUpInside)
        button.setTitleColor(UIColor.systemBlue, for: .normal)
        
        return button
        
    }()
    
    private let aboutLabel: UILabel = {
        let label = UILabel()
        label.text = "About"
        label.font = UIFont(name: "HelveticaNeue", size: 16)
        
        return label
        
    }()
    
    // MARK: - Initializer
    
    init(currentUser: User) {
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Settings View Did Load Called")
        setupStack()
        configure()
        setupUserInfo()
        loadingIndicator.hidesWhenStopped = true
        self.hideKeyboardWhenTappedAround()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        logoutButton.setRoundedView()
    }
    
    // MARK: - Helper Functions
    
    func configure() {
        self.view.isUserInteractionEnabled = true
        self.navigationController?.navigationBar.isUserInteractionEnabled = true
        self.view.backgroundColor = .white
        self.navigationController?.delegate = self
        self.navigationItem.title = "Edit Profile"
        self.view.isUserInteractionEnabled = true
        self.aboutTextView.delegate = self
        self.aboutTextView.autocorrectionType = .no
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
        profileImageView.setDimensions(width: 100, height: 100)
        profileImageView.layer.cornerRadius = 100 / 2
        profileImageView.centerX(inView: self.view)
        profileImageView.clipsToBounds = true
        profileImageView.image = UIImage(named: "test")
        
        
        // AddPhotobutton
        view.addSubview(addPhotoButton)
        addPhotoButton.anchor(top: profileImageView.bottomAnchor, paddingTop: 10, width: 120, height: 20)
        addPhotoButton.titleLabel?.textAlignment = .center
        addPhotoButton.centerX(inView: self.view)
        addPhotoButton.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 14)
        
        // About Label
        view.addSubview(aboutLabel)
        aboutLabel.anchor(top: addPhotoButton.bottomAnchor, left: self.view.safeAreaLayoutGuide.leftAnchor, paddingTop: 20, paddingLeft: 20)
        aboutLabel.setDimensions(width: 60, height: 20)
        aboutLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 14)
        aboutLabel.textColor = .black
        aboutLabel.textAlignment = .left
        
        
        
        
        
        
        // About TextView
        view.addSubview(aboutTextView)
        aboutTextView.anchor(top: aboutLabel.bottomAnchor, left: self.view.safeAreaLayoutGuide.leftAnchor, right: self.view.safeAreaLayoutGuide.rightAnchor, paddingTop: 10, paddingLeft: 20, paddingRight: 20, height: 85)
        aboutTextView.font = UIFont(name: "HelveticaNeue", size: 14)
        aboutTextView.textAlignment = .left
        
       
        
        
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
        instagramLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 14)
        twitterLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 14)
        twitterTextField.delegate = self
        instagramTextField.delegate = self
        twitterTextField.font = UIFont(name: "HelveticaNeue", size: 14)
        instagramTextField.font = UIFont(name: "HelveticaNeue", size: 14)
        if currentUser.twitterUsername != "" {
            twitterTextField.text = currentUser.twitterUsername
        }
        if currentUser.instagramUsername != "" {
            instagramTextField.text = currentUser.instagramUsername
        }
        let stack = UIStackView(arrangedSubviews: [instagramLabel, instagramTextField, twitterLabel, twitterTextField])
        view.addSubview(stack)
        stack.spacing = 10
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
    
    func openCamera()
    {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerController.SourceType.camera
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
        else
        {
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func openGallery()
    {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }
        else
        {
            let alert  = UIAlertController(title: "Warning", message: "You don't have permission to access gallery.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func presentSaveAlert() {
        let alert = UIAlertController(title: "Saved", message: "Changes to profile saved", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Selectors

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
        
        if let aboutText = self.aboutTextView.text, !aboutText.isEmpty, aboutTextView.textColor != UIColor.lightGray {
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
            self.presentSaveAlert()
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
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
              alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
                  self.openCamera()
              }))

              alert.addAction(UIAlertAction(title: "Photos", style: .default, handler: { _ in
                  self.openGallery()
              }))

              alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))

              self.present(alert, animated: true, completion: nil)
//        self.present(imagePicker, animated: true, completion: nil)
        
    }
    
    @objc func updateObserver() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refetchCurrentUser"), object: nil)
        loadingIndicator.stopAnimating()
       
    }
}

// MARK: - UIImagePickerControllerDelegate

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

// MARK: - UITextViewDelegate

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

// MARK: - UITextFieldDelegate

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
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Enter info about yourself..."
            textView.textColor = UIColor.lightGray
        }
    }
}
