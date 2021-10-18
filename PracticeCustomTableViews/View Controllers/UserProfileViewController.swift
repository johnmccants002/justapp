//
//  UserProfileViewController.swift
//  PracticeCustomTableViews
//
//  Created by John McCants on 5/11/21.
//

import UIKit

class UserProfileViewController: UIViewController, UINavigationBarDelegate, UINavigationControllerDelegate {
    
    
    // MARK: - Properties
    
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        return iv
    }()
    private let aboutTextView: UITextView = {
        let textView = UITextView()
        return textView
    }()

    let nameLabel: UILabel = {
        let label = UILabel()
        return label
    }()

    var titleText : String?
    var user: User? {
        didSet {
            updateViews()
            setupLayout()
        }
    }
    var currentUser: User
    var userUid: String
    
    init(titleText: String, userUid: String, currentUser: User) {
        self.userUid = userUid
        self.currentUser = currentUser
        self.titleText = titleText
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUser()
    }
    
    func fetchUser() {
        UserService.shared.fetchUser(uid: userUid) { user in
            self.user = user
        }
    }
    func updateViews() {
        nameLabel.textAlignment = .center
        self.view.backgroundColor = .white
        guard let user = user else { return }
        self.title = "\(user.firstName) \(user.lastName)"
        self.nameLabel.text = "\(user.firstName) \(user.lastName)"
        self.aboutTextView.text = user.aboutText
        if let url = user.profileImageUrl {
            if url.absoluteString == "blank" {
                profileImageView.image = UIImage(named: "blank")
            } else {
                profileImageView.sd_setImage(with: url, completed: nil)
            }
        }
    }
    
    func setupLayout() {
        self.view.addSubview(profileImageView)
        profileImageView.setDimensions(width: 75, height: 75)
        profileImageView.centerX(inView: self.view, topAnchor: navigationController?.navigationBar.bottomAnchor, paddingTop: 20)
        
        self.view.addSubview(nameLabel)
        nameLabel.anchor(top: profileImageView.bottomAnchor, left: self.view.leftAnchor, right: self.view.rightAnchor, paddingTop: 20, paddingLeft: 20, paddingRight: 20, height: 20)
        
        self.view.addSubview(aboutTextView)
        aboutTextView.anchor(top: nameLabel.bottomAnchor, left: self.view.leftAnchor, right: self.view.rightAnchor, paddingTop: 15, paddingLeft: 20, paddingRight: 20, height: 100)
        
//        nameLabel.anchor(top: profileImageView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 15, paddingLeft: 20, paddingRight: 20, height: 20)
//        view.addSubview(nameLabel)
//        
//        aboutTextView.anchor(top: nameLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 10, paddingLeft: 20, paddingRight: 20, height: 100)
      
    }
}
