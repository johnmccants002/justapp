//
//  SharedNetworksController.swift
//  PracticeCustomTableViews
//
//  Created by John McCants on 11/8/21.
//

import Foundation
import UIKit


class SharedNetworksController: UICollectionViewController, UINavigationControllerDelegate {
    
    // MARK: - Properties
    
    var currentUser: User
    var users: [User]
    let sharedNetworkNibName = "SharedNetworkCell"
    
    
    // MARK: - Lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "Shared Networks"
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.barStyle = .default
    }
    
    // MARK: - Helper Functions
    
    func configure() {
        let nib = UINib(nibName: sharedNetworkNibName, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "sharedNetworkCell")
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        navigationController?.delegate = self
       
        
        
    }
    
    // MARK: - Initializer
    
    required init?(coder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    init(users: [User], currentUser: User) {
    self.users = users
    self.currentUser = currentUser
    super.init(collectionViewLayout: UICollectionViewFlowLayout())
}
  
    
    // MARK: - UICollectionViewDelegate
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "sharedNetworkCell", for: indexPath) as! SharedNetworkCell
        cell.delegate = self
        cell.user = users[indexPath.row]
        cell.currentUser = currentUser
        
        return cell
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users.count
        
    }
        
}

// MARK: - UICollectionViewDelegateFlowLayout

extension SharedNetworksController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 60)
    }
}

// MARK: - SharedNetworkCellDelegate

extension SharedNetworksController: SharedNetworkCellDelegate {
    
    func userButtonTapped(cell: SharedNetworkCell) {
        guard let user = cell.user else { return }
        if cell.user == currentUser {
            let controller = CurrentUserController(currentUser: currentUser, isUser: false)
            self.navigationController?.pushViewController(controller, animated: true)
        } else {
            let controller = CurrentUserController(currentUser: currentUser, isUser: true)
            controller.fetchUser(uid: user.uid)
            controller.currentUserArray = self.users
            
            self.navigationController?.pushViewController(controller, animated: true)
        }
       
    }
}
