//
//  NetworkDetailsController.swift
//  PracticeCustomTableViews
//
//  Created by John McCants on 11/12/21.
//

import Foundation
import UIKit

private let headerIdentifier = "NetworkDetailsHeader"

class NetworkDetailsController: UICollectionViewController, UINavigationControllerDelegate {
    
    // MARK: - Properties
    
    var user: User
    var networkUsers: [User]? {
        didSet {
            collectionView.reloadData()
        }
    }
    var currentUser: User
    var currentUserArray: [User]
    
    let userNibName = "NetworkUserCell"
    
    // MARK: - Intializer
    
    init(currentUser: User, user: User, currentUserArray: [User]) {
        self.currentUser = currentUser
        self.user = user
        self.currentUserArray = currentUserArray
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCell()
        configureCollectionView()
        overrideUserInterfaceStyle = .light
        
        print("This is the currentUser Network Id: \(currentUser.networkId)")
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setupProperNetwork()
    }
    
    // MARK: - Helper Functions
    
    func configureCollectionView() {
        collectionView.register(NetworkDetailsHeader.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)
    }
    
    func registerCell() {
        let nib = UINib(nibName: userNibName, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "networkUserCell")
        collectionView.backgroundColor = .white
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func setupProperNetwork() {
        if user == currentUser {
            setupCurrentUserNetwork()
        } else {
            setupUserNetwork()
        }
    }
    
    func setupCurrentUserNetwork() {
        self.title = "Your Network"
        
    }
    
    func setupUserNetwork() {
        self.title = "\(user.firstName)'s Network"
        
    }
    
    func longPressAlert(cell: NetworkUserCell) -> UIAlertController {
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let alert = UIAlertController(title: "Remove User from Network?", message: "You sure you want remove user from network?", preferredStyle: .alert)
            let removeAction = UIAlertAction(title: "Remove", style: .default) { action in
                self.removeCell(cell: cell)
                if let user = cell.user {
                    NetworkService.shared.removeUserFromNetwork(currentUser: self.currentUser, userToRemove: user, networkId: self.currentUser.networkId) {
                        self.collectionView.reloadData()
                    }
                }
               
            }
            alert.addAction(removeAction)
            alert.addAction(cancelAction)
            return alert
        
        
    }
    
    // MARK: - Selectors
    
    @objc func removeCell(cell: NetworkUserCell) {
        let i = cell.tag
        networkUsers!.remove(at: i)
        collectionView.reloadData()
    }
    
    // MARK: - Firebase Functions
    
    func fetchNetworkUsers() {
        NetworkService.shared.fetchUsersInNetwork(networkId: currentUser.networkId, currentUser: currentUser) { users in
            self.networkUsers = users
        }
    }
    
    
    
    
    // MARK: - UICollectionViewDelegate + DataSource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let networkUsers = networkUsers {
            return networkUsers.count
        } else {
            return 1
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "networkUserCell", for: indexPath) as! NetworkUserCell
        if let networkUsers = networkUsers {
            cell.user = networkUsers[indexPath.row]
        }
        cell.delegate = self
        cell.tag = indexPath.row
        
        return cell
    }
    
    
}


// MARK: UICollectionViewDelegateFlowLayout

extension NetworkDetailsController: UICollectionViewDelegateFlowLayout {
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! NetworkDetailsHeader
        header.count = self.networkUsers?.count
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
      
        return CGSize(width: view.frame.width, height: 40)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width, height: 60)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10.0, left: 1.0, bottom: 1.0, right: 1.0)
    }
}
    
    

extension NetworkDetailsController: NetworkUserCellDelegate {
    func cellTapped(cell: NetworkUserCell) {
        guard let user = cell.user else { return }
        let controller = CurrentUserController(currentUser: user, isUser: true)
        controller.fetchUser(uid: user.uid)
        controller.currentUserArray = currentUserArray
        
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func removeUserFromNetwork(cell: NetworkUserCell) {
        guard let user = cell.user else { return }
        NetworkService.shared.removeUserFromNetwork(currentUser: currentUser, userToRemove: user, networkId: currentUser.networkId) {
            self.collectionView.reloadData()
        }
    }
    
    func didLongPress(cell: NetworkUserCell) {
        if currentUser == user {
            let alert = longPressAlert(cell: cell)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}
