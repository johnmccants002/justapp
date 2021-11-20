//
//  ActivityRespectController.swift
//  PracticeCustomTableViews
//
//  Created by John McCants on 8/20/21.
//

import Foundation
import UIKit
import Firebase

class ActivityRespectController: UICollectionViewController, UINavigationControllerDelegate {

    // MARK: - Properties
    
    var respectNotifications: [RespectNotification]? {
        didSet {
            self.collectionView.reloadData()
        }
    }
    var justIDs : [String]?
    let currentUser : User
    let respectNibName = "ActivityRespectCell"
    var respectCount : String?
    var refreshControl = UIRefreshControl()
    var currentUserArray: [User]?
    
    
    // MARK: - Initializer
    
    init(currentUser: User) {
        self.currentUser = currentUser
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
        fetchRespect()
        setupLeftBarItem()
        fetchTotalRespect()
        setupRightBarItem()
        setupRefreshControl()
        setupCurrentUserArray()
        overrideUserInterfaceStyle = .light
        
    }
    
    // MARK: - Helper Functions
    
    func updateViews() {
        let nib = UINib(nibName: respectNibName, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "respectCell")
        collectionView.backgroundColor = .white
        self.navigationController?.navigationBar.topItem?.title = "Respects"
    }
    
    func setupLeftBarItem() {
        let backButton = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(dismissController))
        self.navigationItem.leftBarButtonItem = backButton
    }
    
    func setupRightBarItem() {
        let rightButton = UIBarButtonItem(title: "", style: .plain, target: self, action: #selector(respectCountTapped))
        self.navigationItem.rightBarButtonItem = rightButton
    }
    
    func setupRefreshControl() {
        self.refreshControl.addTarget(self, action: #selector(reloadRespects), for: .valueChanged)
        self.collectionView.refreshControl = refreshControl
    }
    
    // MARK: - Firebase Functions
    
    func fetchRespect() {
        UserService.shared.fetchUserRespect(uid: currentUser.uid) { respectNotifications in
            if respectNotifications.isEmpty {
                self.collectionView.refreshControl?.endRefreshing()
            }
            let respectArray = respectNotifications.sorted(by: {
                $0.timestamp.compare($1.timestamp) == .orderedDescending
            })
            self.respectNotifications = respectArray
            
            self.collectionView.refreshControl?.endRefreshing()
            print("These are the respectNotfications: \(respectNotifications)")
        }
    }
    
    func setUserInRespectNotifications() {
        guard let respectNotifications = self.respectNotifications else { return }
        for var respectNotification in respectNotifications {
            UserService.shared.fetchUser(uid: respectNotification.fromUserUid) { user in
                respectNotification.user = user
            }
        }
    }
    
    func setupCurrentUserArray() {
        var currentUserArray : [User] = []
        if let currentUserNetworks = currentUser.networks {
            for network in currentUserNetworks {
                currentUserArray.append(network.user)
            }
            self.currentUserArray = currentUserArray
            
        }
    }
    
    func fetchTotalRespect() {
        UserService.shared.fetchTotalRespect(uid: currentUser.uid) { countString in
            self.navigationItem.rightBarButtonItem?.title = countString
            self.respectCount = countString
        }
    }
    
    // MARK: - Selectors
    
    @objc func dismissController() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func reloadRespects() {
        fetchRespect()
        fetchTotalRespect()
    }
    
    @objc func respectCountTapped() {
        guard let respectCount = respectCount else { return }
        let alertController = UIAlertController(title: "Total Respect", message: "Your total respect received is \(respectCount). Keep doing more to get more respect.", preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Will do", style: .default, handler: nil)
        alertController.addAction(alertAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    // MARK: - UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "respectCell", for: indexPath) as! ActivityRespectCell
        
        guard let respectNotifications = respectNotifications else { return UICollectionViewCell() }
        cell.respectNotification = respectNotifications[indexPath.row]
        cell.delegate = self
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let respectNotifications = respectNotifications else { return 0 }
       return respectNotifications.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let respectNotifications = respectNotifications {
            let notification = respectNotifications[indexPath.row]
            let controller = ViewJustController(justID: notification.justID, user: notification.user, currentUser: currentUser)
            navigationController?.pushViewController(controller, animated: true)
        }
    }
}

// MARK: ActivityRespectCellDelegate

extension ActivityRespectController: ActivityRespectCellDelegate {
    func cellImageTapped(cell: ActivityRespectCell) {
        guard let user = cell.user else { return }
        let profileController = CurrentUserController(currentUser: currentUser, isUser: true)
        profileController.fetchUser(uid: user.uid)
        if let currentUserArray = self.currentUserArray {
            profileController.currentUserArray = currentUserArray
        }
        self.navigationController?.pushViewController(profileController, animated: true)

    }
    
}

// MARK: UICollectionViewDelegateFlowLayout

extension ActivityRespectController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width, height: 60)
    }
}
