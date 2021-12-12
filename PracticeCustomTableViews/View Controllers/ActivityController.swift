//
//  ActivityController.swift
//  PracticeCustomTableViews
//
//  Created by John McCants on 8/19/21.
//

import Foundation
import UIKit

class ActivityController: UICollectionViewController, UINavigationControllerDelegate {
    
    // MARK: - Properties
    
    let currentUser : User
    var invites : [User]? {
        didSet {
            if ((invites?.isEmpty) != nil) {
                removeLoadingView()
            }
            removeLoadingView()
            collectionView.reloadData()
        }
    }
    let inviteNib : String = "InviteCell"
    var loadingIndicator = UIActivityIndicatorView()
    var refreshControl = UIRefreshControl()
    var emptyInvitesView: InvitesEmptyView?
    var loadingView: LoadingView?
    
    // MARK: - Lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        displayLoadingView()
        let nib = UINib(nibName: self.inviteNib, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "inviteCell")
        setupRefreshControl()
        updateViews()
        setupLoadingIndicator()
        overrideUserInterfaceStyle = .light
        
    }
    
    // MARK: - Initializer
    
    init(currentUser: User) {
        self.currentUser = currentUser
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helper Functions
    
    func setupLoadingIndicator() {
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.isHidden = true
        
        self.view.addSubview(loadingIndicator)
        loadingIndicator.centerX(inView: self.view)
        loadingIndicator.centerY(inView: self.view)
        
    }
    
    func setupLeftBarItem() {
        let backButton = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(dismissController))
        self.navigationItem.leftBarButtonItem = backButton
    }
    
    func updateViews() {
        navigationController?.navigationBar.topItem?.title = "Invites"
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        setupLeftBarItem()
        fetchInvites()
        
    }
    
    func setupRefreshControl() {
        self.refreshControl.addTarget(self, action: #selector(reloadInvites), for: .valueChanged)
        self.collectionView.refreshControl = self.refreshControl
    }
    
    func displayEmptyView() {
            let emptyView = InvitesEmptyView(frame: CGRect(x: self.view.bounds.minX, y: self.view.bounds.minY, width: self.view.bounds.width, height: self.view.bounds.height))
            self.view.addSubview(emptyView)
        
    }
    
    func displayLoadingView() {
        let loadView = LoadingView(frame: CGRect(x: self.view.bounds.minX, y: self.view.bounds.minY, width: self.view.bounds.width, height: self.view.bounds.height))
        self.loadingView = loadView
        self.view.addSubview(loadView)
    }
    
    func removeLoadingView() {
        guard let loadingView = self.loadingView else { return }
        loadingView.removeFromSuperview()
    }
    
    // MARK: - Firebase Functions
    
    func fetchInvites() {
        NetworkService.shared.fetchInvites(uid: currentUser.uid) { users in
            if users.isEmpty {
                self.collectionView.refreshControl?.endRefreshing()
                self.displayEmptyView()
                self.removeLoadingView()
            }
            self.removeLoadingView()
            self.invites = users
            self.collectionView.refreshControl?.endRefreshing()
        }
    }
    
    // MARK: - Selectors
    
    @objc func reloadInvites() {
        fetchInvites()
    }
    
    @objc func dismissController() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func removeCell(sender: UIButton) {
        let i = sender.tag
        invites?.remove(at: i)
        collectionView.reloadData()
    }

// MARK: - UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("dequeueing cell")
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "inviteCell", for: indexPath) as! InviteCell
        guard let invites = invites else { return cell }
        cell.user = invites[indexPath.row]
        cell.delegate = self
        cell.acceptButton.tag = indexPath.row
        cell.denyButton.tag = indexPath.row

      return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return invites?.count ?? 0
    }
}

// MARK: - UICollecitonViewDelegateFlowLayout

extension ActivityController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        return CGSize(width: self.view.frame.width, height: 130)
        }

        public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets{

            return  UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }

        public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat{

            return 0
        }

        public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat{

            return 0
        }
}

// MARK: - InviteCellDelegate

extension ActivityController: InviteCellDelegate {
    func acceptButtonTapped(cell: InviteCell) {
        loadingIndicator.startAnimating()
        guard let user = cell.user else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            NetworkService.shared.handleInvite(user: user, choice: true, currentUser: self.currentUser) { error, ref in
                self.loadingIndicator.stopAnimating()
            if let error = error {
                print("DEBUG Accepting Invite Error: \(error)")
            }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refetchUser"), object: nil)
            guard let token = cell.token else { return }
                PushNotificationSender.shared.sendPushNotification(to: token, title: "New friend in your Network!", body: "\(self.currentUser.firstName) \(self.currentUser.lastName) accepted your invite!", id: self.currentUser.uid)
            self.collectionView.reloadData()
            self.removeCell(sender: cell.acceptButton)
        }
        }
    }
    
    func denyButtonTapped(cell: InviteCell) {
        guard let user = cell.user else { return }
        NetworkService.shared.handleInvite(user: user, choice: false, currentUser: currentUser) { error, ref in
            if let error = error {
                print("DEBUG Deny Invite Error: \(error)")
            }
        }
        self.removeCell(sender: cell.denyButton)
        self.collectionView.reloadData()
    }
}


