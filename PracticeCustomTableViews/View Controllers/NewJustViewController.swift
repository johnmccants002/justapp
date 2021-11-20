//
//  NewJustViewController.swift
//  PracticeCustomTableViews
//
//  Created by John McCants on 5/14/21.
//

import UIKit
import Firebase
import FirebaseAuth

class NewJustViewController: UIViewController, UINavigationControllerDelegate {

    
    // MARK: - Properties
    
    @IBOutlet weak var addPhotoImageView: UIImageView!
    @IBOutlet weak var addPhotoButton: UIButton!
    @IBOutlet weak var navigation: UINavigationItem!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet var selectButton : UIButton!
    @IBOutlet weak var countLabel: UILabel!
    var networkIds: [String]?
    var currentUser: User?
    var networks: [Network]?
    var yourNetworkUserIds: [String]?
    var justImage: UIImage?
    var imagePicker = UIImagePickerController()
    
    var postButtonKeyboard: UIBarButtonItem {
        let nextButton = UIBarButtonItem(title: "Post", style: .plain, target: self, action: #selector(self.postButtonPressed(_:)))
        nextButton.width = self.view.viewWidth
        nextButton.tintColor = UIColor.black
        return nextButton
    }
    var keyboardToolBar: UIToolbar {
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.sizeToFit()
        keyboardToolbar.isTranslucent = false
        keyboardToolbar.barTintColor = UIColor.white
        keyboardToolbar.items = [self.postButtonKeyboard]
        keyboardToolbar.layer.borderWidth = 1
        keyboardToolbar.layer.borderColor = UIColor.black.cgColor
        return keyboardToolbar
    }
    
    var xButton : UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "xButton1"), for: .normal)
        button.setDimensions(width: 15, height: 15)
        button.titleLabel?.textAlignment = .center
        button.addTarget(self, action: #selector(xButtonTapped), for: .touchUpInside)
        return button
    }()
    
    @IBOutlet weak var justTextView: UITextView!
    var widthConstraint : NSLayoutConstraint?
    let justMaxLength = 150
    var photoSelected = false
    var friendsNetwork = false
    
    
    // MARK: Lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.justTextView.delegate = self
        updateViews()
        self.imagePicker.delegate = self
        fetchCurrentUserNetworkUsers()
        overrideUserInterfaceStyle = .light
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.justTextView.becomeFirstResponder()
    }
    
    // MARK: Helper Functions
    
    func updateViews() {
        self.loadingIndicator.isHidden = true
        networkButtonSetUp()
        self.justTextView.tintColor = .black
        self.justTextView.autocapitalizationType = .none
        self.justTextView.isScrollEnabled = false
        self.justTextView.inputAccessoryView = keyboardToolBar
        self.justTextView.autocorrectionType = .no
        self.keyboardToolBar.isHidden = true
        
        self.view.addSubview(xButton)
        xButton.setRoundedView()
        addPhotoButton.setRoundedView()
        
        xButton.anchor(top: self.addPhotoButton.topAnchor, right: addPhotoButton.rightAnchor, paddingTop: -4)
        xButton.isHidden = true
        self.imagePicker.allowsEditing = true
        
        self.addPhotoImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(addPhotoButtonTapped(_:)))
        self.addPhotoImageView.addGestureRecognizer(tap)
      
    }
    
    func networkButtonSetUp() {
        selectButton.layer.cornerRadius = 5
        selectButton.layer.borderColor = UIColor.black.cgColor
        selectButton.layer.borderWidth = 1
        selectButton.layer.backgroundColor = UIColor.white.cgColor
        let width = selectButton.widthAnchor.constraint(equalToConstant: 130)
        self.widthConstraint = width
        guard let widthConstraint = widthConstraint else { return }
        selectButton.addConstraint(widthConstraint)
    }
    
    func presentAlertSelection() {
        let alert = UIAlertController(title: "Choose where to send your Just", message: nil, preferredStyle: .actionSheet)
        let action = UIAlertAction(title: "Your Network", style: .default) { _ in
            self.selectButton.setTitle("To: Your Network", for: .normal)
            guard let widthConstraint = self.widthConstraint else { return }
            self.friendsNetwork = false
            self.selectButton.removeConstraint(widthConstraint)
            let width = self.selectButton.widthAnchor.constraint(equalToConstant: 130)
            self.selectButton.addConstraint(width)
            self.widthConstraint = width
        }
        let action2 = UIAlertAction(title: "Your Network and Friends Networks", style: .default) { _ in
            self.selectButton.setTitle("To: Your Network + Friends Networks", for: .normal)
            self.friendsNetwork = true
            guard let widthConstraint = self.widthConstraint else { return }
            self.selectButton.removeConstraint(widthConstraint)
            let widthPlus = self.selectButton.widthAnchor.constraint(equalToConstant: 225)
            self.selectButton.addConstraint(widthPlus)
            self.widthConstraint = widthPlus
            
        }
        if let networks = networks {
            alert.addAction(action2)
        }
            alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    func sendInfoToDB() {
        let _ : Timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.myPerformCode), userInfo: nil, repeats: false)
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
    
    // MARK: - Firebase Functions
    
    func fetchCurrentUserNetworkUsers() {
        guard let currentUser = currentUser else { return }
        NetworkService.shared.fetchCurrentUserNetworkUsers { userIds in
            self.yourNetworkUserIds = userIds
        }
    }
    
    func uncheckNetworks() {
            if let networks = networks, let yourNetworkUserIds = yourNetworkUserIds {
                NetworkService.shared.uncheckNetworks(networks: networks, yourNetworkUserIds: yourNetworkUserIds)
            }
       
        
    }
    
    // MARK: - Selectors
    
    @IBAction func addPhotoButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Choose Image", message: nil, preferredStyle: .actionSheet)
              alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
                  self.openCamera()
              }))

              alert.addAction(UIAlertAction(title: "Photos", style: .default, handler: { _ in
                  self.openGallery()
              }))

              alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))

              self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func selectButtonTapped(_ sender: UIButton) {
        presentAlertSelection()
    }
    
    @objc func postButtonPressed(_: UIButton) {
        if self.justTextView.hasText {
            self.loadingIndicator.isHidden = false
            self.loadingIndicator.startAnimating()
            sendInfoToDB()
        } 
      
    }
    
    @objc func myPerformCode() {
        guard let justText = justTextView.text else { return }
        guard let user = self.currentUser else { return }
        if let networks = networks {
            JustService.shared.uploadJust(user: user, justText: justText, justImage: justImage, networks: networks, friendsNetworks: friendsNetwork) { error in
                if let error = error {
                    print("DEBUG: Error uploading Just: \(error.localizedDescription)")
                }
                self.uncheckNetworks()
                self.navigationController?.popViewController(animated: true)
                self.loadingIndicator.stopAnimating()
            }
        } else {
            JustService.shared.uploadJust(user: user, justText: justText, justImage: justImage, networks: nil, friendsNetworks: friendsNetwork) { error in
                if let error = error {
                    print("DEBUG: Error uploading Just: \(error.localizedDescription)")
                }
                self.navigationController?.popViewController(animated: true)
                self.loadingIndicator.stopAnimating()
            }
        }
    }
    
    @objc func xButtonTapped() {
        self.addPhotoButton.setImage(nil, for: .normal)
        self.xButton.isHidden = true
        self.addPhotoImageView.isHidden = false
    }

}

// MARK: - UITextViewDelegate

extension NewJustViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        self.keyboardToolBar.isHidden = true
        self.postButtonKeyboard.isEnabled = false
        if textView.text.count > 1 {
                self.keyboardToolBar.isHidden = false
            self.postButtonKeyboard.isEnabled = true
            print("textview greater than 1")
            }
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if textView == self.justTextView {
            return textView.text.count + (text.count - range.length) <= justMaxLength
        }
        
        return false
         
    }
        
    func textViewDidBeginEditing(_ textView: UITextView) {
        
    }
    
}

// MARK: - UIImagePickerControllerDelegate

extension NewJustViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            print("image picked")
            addPhotoButton.setImage(pickedImage, for: .normal)
            justImage = pickedImage
            self.addPhotoButton.imageView?.contentMode = .scaleAspectFit
            xButton.isHidden = false
            addPhotoImageView.isHidden = true

            photoSelected = true
        }
        

        dismiss(animated: true, completion: nil)
    }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            dismiss(animated: true, completion: nil)
        }
}

// MARK: - AwakeFromNib
extension NewJustViewController {
    open override func awakeFromNib() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
}
