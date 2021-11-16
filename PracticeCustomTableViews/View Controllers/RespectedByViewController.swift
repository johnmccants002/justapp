//
//  RespectedByViewController.swift
//  PracticeCustomTableViews
//
//  Created by John McCants on 5/14/21.
//

import UIKit

class RespectedByViewController: UICollectionViewController, UINavigationControllerDelegate {

    // MARK: - Properties
    
    var users: [User]? {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var just: Just
    var currentUser: User
    let respectByNibName = "RespectedByCell"
    
    // MARK: Lifecycles

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        fetchUsers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = "Respected By"
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.barStyle = .default
    }
    
    // MARK: Helper Functions
    
    func configure() {
        let nib = UINib(nibName: respectByNibName, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "respectedByCell")
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        navigationController?.delegate = self
       
        
        
    }
    
    // MARK: - Initializer

    init(just: Just, currentUser: User) {
    self.just = just
    self.currentUser = currentUser
    super.init(collectionViewLayout: UICollectionViewFlowLayout())
}
    
    required init?(coder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Firebase Functions
    
    func fetchUsers() {
        JustService.shared.fetchRespectedBy(just: just) { users in
            let names = users.map { $0.firstName
            }
            print("These are the names of the users: \(names)")
            self.users = users
        }
    }
}
    


// MARK: - UICollectionViewDataSource / Delegate

extension RespectedByViewController {
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "respectedByCell", for: indexPath) as! RespectedByCell
        cell.delegate = self
        if let users = users {
            cell.user = users[indexPath.row]
        }
        return cell
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users?.count ?? 1
        
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout

extension RespectedByViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 60)
    }
}

// MARK: - RespectCellDelegate

extension RespectedByViewController: RespectedByCellDelegate {
    func usernameButtonTapped(cell: RespectedByCell) {
        guard let user = cell.user else { return }
        let controller = CurrentUserController(currentUser: currentUser, isUser: true)
        let uid = user.uid
        controller.fetchUser(uid: uid)
        self.navigationController?.pushViewController(controller, animated: true)
    }
}
