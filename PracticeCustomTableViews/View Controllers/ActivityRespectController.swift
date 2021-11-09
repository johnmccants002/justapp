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
    }
    
   
    
    // MARK: Helper Functions
    
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
    
    func fetchRespect() {
        UserService.shared.fetchUserRespect(uid: currentUser.uid) { respectNotifications in
            if respectNotifications.isEmpty {
                self.collectionView.refreshControl?.endRefreshing()
            }
            self.respectNotifications = respectNotifications
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
    
    func fetchTotalRespect() {
        UserService.shared.fetchTotalRespect(uid: currentUser.uid) { countString in
            self.navigationItem.rightBarButtonItem?.title = countString
            self.respectCount = countString
        }
    }
     
    func setupRefreshControl() {
        self.refreshControl.addTarget(self, action: #selector(reloadRespects), for: .valueChanged)
        self.collectionView.refreshControl = refreshControl
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
}

// MARK: ActivityRespectCellDelegate

extension ActivityRespectController: ActivityRespectCellDelegate {
    func cellImageTapped(cell: ActivityRespectCell) {
        print("cell image tapped")
        guard let user = cell.user else { return }
        let fullName = "\(user.firstName) \(user.lastName)"
        let profileController = CurrentUserController(currentUser: currentUser, isUser: true)
        profileController.user = user
        self.navigationController?.pushViewController(profileController, animated: true)

    }
    
}

// MARK: UICollectionViewDelegateFlowLayout

extension ActivityRespectController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width, height: 81)
    }
}
