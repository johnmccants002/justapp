//
//  ProfileHeader.swift
//  PracticeCustomTableViews
//
//  Created by John McCants on 8/24/21.
//

import Foundation
import UIKit
import Firebase
import ImageViewer_swift

protocol ProfileHeaderDelegate: AnyObject {

    func imageViewTapped(_ header: ProfileHeader, url: URL)
    func handleSettingsTapped(_ header: ProfileHeader)
    func handleBackTapped(_ header: ProfileHeader)
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
        button.setTitle("Settings", for: .normal)
        button.layer.borderColor = UIColor.blue.cgColor
        button.layer.borderWidth = 1.25
        button.setTitleColor(.blue, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.isHidden = true
        button.addTarget(self, action: #selector(handleSettingsTapped), for: .touchUpInside)
        
        return button
    }()
    
    let viewProfileImageButton: UIButton = {
        let button = UIButton()
        return button
    }()
    
    var instagramButton : UIButton = {
        var button = UIButton()
        button.backgroundColor = .white
        button.layer.borderWidth = 0.75
        button.layer.borderColor = UIColor.blue.cgColor
        button.setTitle("Instagram", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(instagramButtonTapped), for: .touchUpInside)
        return button
    }()
    
    var twitterButton: UIButton = {
        var button = UIButton()
        button.backgroundColor = .white
        button.layer.borderWidth = 0.75
        button.layer.borderColor = UIColor.blue.cgColor
        button.setTitle("Twitter", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: #selector(twitterButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
    func configure() {
        guard let user = user else {
            print("No user")
            return }
        fullnameLabel.text = "\(user.firstName) \(user.lastName)"
        usernameLabel.text = "@" + user.username
        biotTextView.text = self.user?.aboutText
        if let url = user.profileImageUrl {
            profileImageView.sd_setImage(with: url, completed: nil)
            if isUser == true {
                profileImageView.setupImageViewer()
            }
        }
        
        setupSocialButtons(user: user)
       
        
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
    
    @objc func imageViewTapped() {
        guard let url = user?.profileImageUrl else { return }
        delegate?.imageViewTapped(self, url: url)
        print("imageviewtapped")
        
    }
    
    @objc func handleSettingsTapped() {
        delegate?.handleSettingsTapped(self)
            
    }
    
    @objc func handleBackTapped() {
        delegate?.handleBackTapped(self)
    }

    
    @objc func twitterButtonTapped() {
        guard let user = user, let twitterUsername = user.twitterUsername else { return }
        let appURL = URL(string: "twitter://user?screen_name=\(twitterUsername)")!
                let application = UIApplication.shared
                
                if application.canOpenURL(appURL)
                {
                    application.open(appURL)
                }
                else
                {
                    let webURL = URL(string: "https://twitter.com/\(twitterUsername)")!
                    application.open(webURL)
                }
    }
    
    @objc func instagramButtonTapped() {
        print("Instagram button tapped")
        guard let user = user, let instagramUsername = user.instagramUsername else { return }
        let appURL = URL(string: "instagram://user?username=\(instagramUsername)")!
                let application = UIApplication.shared
                
                if application.canOpenURL(appURL)
                {
                    application.open(appURL)
                }
                else
                {
                    let webURL = URL(string: "https://instagram.com/\(instagramUsername)")!
                    application.open(webURL)
                }
        
    }
    
    var biotTextView : UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.isEditable = false
        tv.isScrollEnabled = false
    
        return tv
    }()
    
    private let underLineView: UIView = {
        let view = UIView()
        view.backgroundColor = .blue
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.isUserInteractionEnabled = true
        addSubview(containerView)
        containerView.anchor(top: topAnchor, left: leftAnchor, right: rightAnchor, height: 108)
        containerView.isUserInteractionEnabled = true
        addSubview(profileImageView)
        profileImageView.anchor(top: containerView.bottomAnchor, paddingTop: -24)
        profileImageView.centerX(inView: self)
        profileImageView.setDimensions(width: 120, height: 120)
        profileImageView.layer.cornerRadius = 120/2
        

//        self.addSubview(viewProfileImageButton)
//        viewProfileImageButton.anchor(top: containerView.bottomAnchor, paddingTop: -24)
//        viewProfileImageButton.centerX(inView: self)
//        viewProfileImageButton.setDimensions(width: 120, height: 120)
//        viewProfileImageButton.layer.cornerRadius = 120/2
//        viewProfileImageButton.isUserInteractionEnabled = true
//        viewProfileImageButton.addTarget(self, action: #selector(imageViewTapped), for: .touchUpInside)
        
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
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        instagramButton.setRoundedView()
        twitterButton.setRoundedView()
        self.isUserInteractionEnabled = true
        self.containerView.isUserInteractionEnabled = true
        self.profileImageView.isUserInteractionEnabled = true
        
    }
    
 
    
    func setupBioTextView() {
        guard let bioText = biotTextView.text else { return }
        self.user?.aboutText = bioText
    }

    func setupSocialButtons(user: User) {
            if user.instagramUsername != "" && user.twitterUsername != "" {
                setupBothSocialButtons()
            } else if user.instagramUsername != "" && user.twitterUsername == "" {
                setupInstagramButton()
            } else if user.instagramUsername == "" && user.twitterUsername != "" {
                setupTwitterButton()
            }
        
   
    }
    
    func setupBothSocialButtons() {
        self.addSubview(instagramButton)
        instagramButton.anchor(top: biotTextView.bottomAnchor, left: self.leftAnchor, right: self.rightAnchor, paddingTop: 15, paddingLeft: 20, paddingRight: 20, height: 40)
        self.addSubview(twitterButton)
        
        instagramButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 16)
        twitterButton.anchor(top: instagramButton.bottomAnchor, left: self.leftAnchor, right: self.rightAnchor, paddingTop: 10, paddingLeft: 20, paddingRight: 20, height: 40)
        twitterButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 16)
    }
    
    func setupInstagramButton() {
        self.addSubview(instagramButton)
        instagramButton.anchor(top: biotTextView.bottomAnchor, left: self.leftAnchor, right: self.rightAnchor, paddingTop: 15, paddingLeft: 20, paddingRight: 20, height: 40)
        instagramButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 16)
        
    }
    
    func setupTwitterButton() {
        self.addSubview(twitterButton)
        twitterButton.anchor(top: biotTextView.bottomAnchor, left: self.leftAnchor, right: self.rightAnchor, paddingTop: 15, paddingLeft: 20, paddingRight: 20, height: 40)
        twitterButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 16)
    }
    
}


