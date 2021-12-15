//
//  AnnouncementsController.swift
//  PracticeCustomTableViews
//
//  Created by John McCants on 12/10/21.
//

import Foundation
import UIKit
import Firebase

class AnnouncementController: UICollectionViewController, UINavigationControllerDelegate {
    
    var announcements: [Announcement]? {
        didSet {
            collectionView.reloadData()
        }
    }
    let announcementNibName = "AnnouncementCell"
    var user: User?
    var currentUser: User?
    var currentUserArray : [User]?
    
    init() {
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupRightBarButtonItem()
        fetchAnnouncements()
        addObservers()
        
    }

  
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        announcements?.count ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "announcementCell", for: indexPath) as? AnnouncementCell else { return UICollectionViewCell() }
        if let user = user {
            cell.user = user
        }
        
        if let announcements = announcements {
            cell.announcement = announcements[indexPath.row]
         
        }
        cell.delegate = self
        
        
    
        
        return cell
        
    }
    
    func setupCollectionView() {
        collectionView.delegate = self
        self.title = "Announcements"
        let nib = UINib(nibName: announcementNibName, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "announcementCell")
        collectionView.backgroundColor = .white
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        collectionView.isScrollEnabled = true
    }
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(reloadAnnouncements), name: NSNotification.Name.init("reloadAnnouncements"), object: nil)
    }
    
    @objc func reloadAnnouncements() {
        fetchAnnouncements()
    }

    func setupRightBarButtonItem() {
        guard let user = user else {
            return
        }

        if Auth.auth().currentUser?.uid == user.uid {
            let button : UIButton = {
                let button = UIButton()
                button.setBackgroundImage(UIImage(systemName: "plus"), for: .normal)
                button.tintColor = .systemBlue
                button.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
                
                return button
            }()
            let barButton = UIBarButtonItem(customView: button)
            self.navigationItem.setRightBarButton(barButton, animated: true)
        }
    }
    
    func fetchAnnouncements() {
        if let user = user {
            AnnouncementService.shared.fetchAnnouncements(uid: user.uid) { announcements in
                
                guard let announcements = announcements else {
                    self.presentEmptyView()
                    return
                }

                let sortedAnnouncements = announcements.sorted(by: {$0.timestamp.timeIntervalSince1970 > $1.timestamp.timeIntervalSince1970
                })
                                                               
                self.announcements = sortedAnnouncements
                
            }
        }
       
    }
    
    func presentEmptyView() {
        let view = UIView()
        self.view.addSubview(view)
        view.anchor(top: self.view.topAnchor, left: self.view.leftAnchor, bottom: self.view.bottomAnchor, right: self.view.rightAnchor)
        
        let label = UILabel()
        label.text = "No announcements yet 📢"
        label.textAlignment = .center
        label.font = UIFont(name: "HelveticaNeue-Medium", size: 20)
        self.view.addSubview(label)
        label.anchor(width: 350, height: 50)
        label.centerX(inView: view)
        label.anchor(top: self.view.topAnchor, paddingTop: 200)
        
    }
    
    @objc func addButtonTapped() {
        let controller = NewAnnouncementController()
        controller.currentUser = currentUser
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    
}

extension AnnouncementController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
      
        
        return CGSize(width: view.frame.width, height: 155)
    }
    

}

extension AnnouncementController: AnnouncementCellDelegate {
    func imageTapped(cell: AnnouncementCell) {
        guard let uid = cell.announcement?.uid, let currentUser = currentUser else { return }
        if currentUser.uid == uid {
            let controller = CurrentUserController(currentUser: currentUser, isUser: false)
            self.navigationController?.pushViewController(controller, animated: true)
        } else {
            let controller = CurrentUserController(currentUser: currentUser, isUser: true)
            controller.fetchUser(uid: uid)
            if let currentUserArray = self.currentUserArray {
                controller.currentUserArray = currentUserArray
            }
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func fullNameTapped(cell: AnnouncementCell) {
        print("full name tapped")
        guard let uid = cell.announcement?.uid, let currentUser = currentUser else { return }
        if currentUser.uid == uid {
            let controller = CurrentUserController(currentUser: currentUser, isUser: false)
            self.navigationController?.pushViewController(controller, animated: true)
        } else {
            let controller = CurrentUserController(currentUser: currentUser, isUser: true)
            controller.fetchUser(uid: uid)
            if let currentUserArray = self.currentUserArray {
                controller.currentUserArray = currentUserArray
            }
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    
}
