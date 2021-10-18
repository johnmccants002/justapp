//
//  ProfileHeader.swift
//  PracticeCustomTableViews
//
//  Created by John McCants on 8/24/21.
//

import Foundation
import UIKit
import Firebase

protocol ProfileHeaderDelegate: AnyObject {
    func handleSettingsTapped(_ header: ProfileHeader)
    func handleBackTapped(_ header: ProfileHeader)
    func handleDoneTapped(_ header: ProfileHeader, bioText: String?, newImage: UIImage?)
    func handleEditTapped(_ header: ProfileHeader)
    func handleLogout(_ header: ProfileHeader)
    func imageViewTapped(_ header: ProfileHeader)
}

class ProfileHeader: UICollectionReusableView {
    
    // MARK: - Properties
    
    weak var delegate: ProfileHeaderDelegate?
    var user: User? {
        didSet {
            configure()
        }
    }
    var isUser: Bool? {
        didSet {
            if isUser == false {
                editProfileButton.isHidden = false
            }
        }
    }
    var pickedImage: UIImage? {
        didSet {
            print("pickedImage set")
            setPickedImage()
        }
    }
    var photoSelected: Bool = false
    var editMode: Bool? {
        didSet {
            configureEditMode()
        }
    }
    var pickerDelegate: UIImagePickerControllerDelegate?
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .blue
        view.addSubview(backButton)
        backButton.anchor(top: view.topAnchor, left: view.leftAnchor, paddingTop: 42, paddingLeft: 16)
        backButton.setDimensions(width: 30, height: 30)
        
        return view
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(named: "backArrow")
        button.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleBackTapped), for: .touchUpInside)
        return button
    }()
    
    let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.backgroundColor = .lightGray
        iv.layer.borderColor = UIColor.white.cgColor
        iv.layer.borderWidth = 4
        return iv
    }()
    
    lazy var editProfileButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Loading", for: .normal)
        button.layer.borderColor = UIColor.blue.cgColor
        button.layer.borderWidth = 1.25
        button.setTitleColor(.blue, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.isHidden = true
        button.addTarget(self, action: #selector(handleSettingsTapped), for: .touchUpInside)
        
        return button
    }()
    
    lazy var editProfileImageButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "addPhoto"), for: .normal)
        button.addTarget(self, action: #selector(editProfileImageTapped), for: .touchUpInside)
        button.layer.opacity = 0.5
        button.imageView?.layer.opacity = 0.5
        button.isHidden = true
        return button
    }()
    
    func configure() {
        guard let user = user else {
            print("No user")
            return }
        fullnameLabel.text = "\(user.firstName) \(user.lastName)"
        usernameLabel.text = "@" + user.username
        biotTextView.text = self.user?.aboutText
        if let pickedImage = pickedImage {
            self.profileImageView.image = pickedImage
        } else {
            setProperImage()
        }
        print("User is \(user.username)")
    }
    
    func markChangedImage() {
        self.user?.changedImage.toggle()
    }
    
    func updateAboutText() {
        guard let aboutText = biotTextView.text else { return }
        biotTextView.text = aboutText
        biotTextView.isEditable = false
        
        self.user?.aboutText = aboutText
    }
    
    func setProperImage() {
        guard let user = user else { return }
        
        if user.changedImage == true {
            UserService.shared.fetchProfileImage(uid: user.uid) { imageUrl in
                self.profileImageView.sd_setImage(with: imageUrl) { image, error, cache, url in
                    if let error = error {
                        self.profileImageView.image = UIImage(named: "blank")
                    }
                }
            }
        } else if user.changedImage == false {
            UserService.shared.fetchProfileImage(uid: user.uid) { imageUrl in
                self.profileImageView.sd_setImage(with: imageUrl) { image, error, cache, url in
                    if let error = error {
                        self.profileImageView.image = UIImage(named: "blank")
                    }
                }
            }
        }
        
    }
    
    func configureEditMode() {
        editProfileButton.isHidden = false
        if editMode == false {
        editProfileButton.setTitle("Settings", for: .normal)
            editProfileImageButton.isHidden = true
            print("Edit mode false in profile header configure")
        } else if editMode == true {
            print("Edit mode true in profile header configure")
        enterEditMode()
        }
        
//        if let pickedImage = pickedImage {
//            profileImageView.image = pickedImage
//        }
    }
    
    func setPickedImage() {
        guard let pickedImage = pickedImage else { return }
        self.profileImageView.image = pickedImage
    }
    
    private let fullnameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        return label
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .lightGray
        return label
    }()
    
    fileprivate func attributedText(withValue value: Int, text: String) -> NSAttributedString {
        let attributedTitle = NSMutableAttributedString(string: "\(value)", attributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
        
        attributedTitle.append(NSAttributedString(string: "\(text)", attributes: [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.lightGray]))
        
        return attributedTitle
    }
    
    @objc func editProfileImageTapped() {
        delegate?.imageViewTapped(self)
        print("editProfileButtonTapped")
    }
    
    @objc func handleSettingsTapped() {
        print("editProfileButtonTapped")
        if editProfileButton.title(for: .normal) == "Done" {
            print("editProfileButton == Done")
            self.editProfileImageButton.isHidden = true
            self.editProfileButton.setTitle("Settings", for: .normal)
            self.updateAboutText()
            self.biotTextView.isEditable = false
            delegate?.handleDoneTapped(self, bioText: biotTextView.text, newImage: pickedImage)
            
            
        } else if editProfileButton.title(for: .normal) == "Settings" {
            delegate?.handleSettingsTapped(self)
            
        }
            
    }
    
    @objc func handleBackTapped() {
        delegate?.handleBackTapped(self)
    }
    
    @objc func handleDoneTapped() {
        updateAboutText()
        markChangedImage()
       
    }
    
    var biotTextView : UITextView = {
        let label = UITextView()
        label.font = UIFont.systemFont(ofSize: 16)
//        label.numberOfLines = 3
        label.isEditable = false
    
        return label
    }()
    
    private let underLineView: UIView = {
        let view = UIView()
        view.backgroundColor = .blue
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.biotTextView.delegate = self
        
        addSubview(containerView)
        containerView.anchor(top: topAnchor, left: leftAnchor, right: rightAnchor, height: 108)
        
        addSubview(profileImageView)
        profileImageView.anchor(top: containerView.bottomAnchor, paddingTop: -24)
        profileImageView.centerX(inView: self)
        profileImageView.setDimensions(width: 120, height: 120)
        profileImageView.layer.cornerRadius = 120/2
        
        addSubview(editProfileImageButton)
        editProfileImageButton.centerX(inView: profileImageView)
        editProfileImageButton.centerY(inView: profileImageView)
        editProfileImageButton.setDimensions(width: 80, height: 80)
        editProfileImageButton.layer.cornerRadius = 80/2
//        editProfileImageButton.isHidden = true
        
        
        let userDetailsStack = UIStackView(arrangedSubviews: [fullnameLabel, usernameLabel, biotTextView])
        userDetailsStack.axis = .vertical
        userDetailsStack.distribution = .fillProportionally
        userDetailsStack.spacing = 4
        
        addSubview(userDetailsStack)
        fullnameLabel.textAlignment = .center
        usernameLabel.textAlignment = .center
        biotTextView.textAlignment = .center
        
        biotTextView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        userDetailsStack.anchor(top: profileImageView.bottomAnchor, paddingTop: 8, paddingLeft: 20, paddingRight: 20, width: self.viewWidth)
        userDetailsStack.centerX(inView: self)
        
        addSubview(editProfileButton)
        editProfileButton.anchor(top: containerView.bottomAnchor, left: leftAnchor, paddingTop: 12, paddingLeft: 20)
        editProfileButton.setDimensions(width: 80, height: 36)
        editProfileButton.layer.cornerRadius = 36/2
     
//        
//        addSubview(underLineView)
//        underLineView.anchor(top: userDetailsStack.bottomAnchor, left: leftAnchor, width: frame.width / 3, height: 2)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupBioTextView() {
        guard let bioText = biotTextView.text else { return }
        self.user?.aboutText = bioText
    }
    
    func enterEditMode() {
        editProfileImageButton.isHidden = false
        editProfileImageButton.isUserInteractionEnabled = true
        biotTextView.isEditable = true
        self.editProfileButton.setTitle("Done", for: .normal)
        guard let pickedImage = pickedImage else {
            return
        }
        self.profileImageView.image = pickedImage

    }
    
}

extension ProfileHeader: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        self.biotTextView.text = textView.text
    }
}
