//
//  NewAnnouncementController.swift
//  PracticeCustomTableViews
//
//  Created by John McCants on 12/10/21.
//

import Foundation
import UIKit

class NewAnnouncementController: UIViewController, UINavigationControllerDelegate {
    
    var currentUser: User?
    var announcementTextView: UITextView = {
        let tv = UITextView()
        tv.textColor = .black
        tv.textAlignment = .left
        tv.font = UIFont(name: "HelveticaNeue", size: 14)
        return tv
    }()
    
    var loadingIndicator = UIActivityIndicatorView()
    
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
    
    var notificationLabel: UILabel = {
        let label = UILabel()
        label.text = "Send Push Notification?"
        label.font = UIFont(name: "HelveticaNeue", size: 14)
        return label
    }()
    
    var toggle = UISwitch()
    
    var tokenArray : [String] = [] {
        didSet {
            print("This is the token array \(tokenArray)")
        }
    }
    
    var yourNetworkUserIds: [String]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
        fetchCurrentUserNetworkUsers()
    }
    
    func fetchUserTokens(uids: [String]) {
        for uid in uids {
            UserService.shared.fetchUserToken(uid: uid) { token in
                self.tokenArray.append(token)
            }
        }
        
    }
    
    func fetchCurrentUserNetworkUsers() {
        NetworkService.shared.fetchCurrentUserNetworkUsers { userIds in
            self.yourNetworkUserIds = userIds
            if let userIds = userIds {
                self.fetchUserTokens(uids: userIds)
            }
        }
    }
    
    
    func updateViews() {
        self.view.backgroundColor = .white
        self.title = "New Announcement"
        announcementTextView.delegate = self
        self.view.addSubview(announcementTextView)
        announcementTextView.anchor(top: self.view.topAnchor, left: self.view.leftAnchor, right: self.view.rightAnchor, paddingTop: 60, paddingLeft: 20, paddingRight: 20, height: 300)
        announcementTextView.inputAccessoryView = keyboardToolBar
        announcementTextView.becomeFirstResponder()
        
        self.view.addSubview(loadingIndicator)
        self.loadingIndicator.isHidden = true
        loadingIndicator.centerX(inView: self.view)
        loadingIndicator.anchor(top: self.announcementTextView.topAnchor, paddingTop: 200)
        loadingIndicator.setDimensions(width: 40, height: 40)
        loadingIndicator.color = .black
        self.loadingIndicator.hidesWhenStopped = true
        
        self.view.addSubview(notificationLabel)
        notificationLabel.anchor(top: announcementTextView.bottomAnchor, right: self.view.rightAnchor, paddingTop: 15, paddingRight: 120)
        notificationLabel.anchor(width: 175, height: 40)
        
        self.view.addSubview(toggle)
        toggle.anchor(top: announcementTextView.bottomAnchor, left: notificationLabel.rightAnchor, right: self.view.rightAnchor, paddingTop: 20, paddingLeft: 10, paddingRight: 5)
        toggle.anchor(width: 30, height: 30)
        
    }
    
    func sendInfoToDB() {
        let _ : Timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.sendAnnouncementToFirebase), userInfo: nil, repeats: false)
    }
    
    @objc func sendAnnouncementToFirebase() {
        guard let currentUser = currentUser else {
            return
        }

        if let announcementText = announcementTextView.text, !announcementText.isEmpty {
            AnnouncementService.shared.postAnnouncement(announcementText: announcementText) {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadAnnouncements"), object: nil)
                self.loadingIndicator.stopAnimating()
                self.navigationController?.popViewController(animated: true)
            }
            
            if toggle.isOn == true {
                for token in self.tokenArray {
                    PushNotificationSender.shared.sendPushNotification(to: token, title: "Just", body: "\(currentUser.firstName) \(currentUser.lastName) made an announcement!", id: currentUser.uid)
                    }
            }
        }
        
    }
    
    @objc func postButtonPressed(_ : UIBarButtonItem) {
        sendInfoToDB()
        loadingIndicator.startAnimating()
    }
}


extension NewAnnouncementController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return textView.text.count + (text.count - range.length) <= 350
    }
    
}
