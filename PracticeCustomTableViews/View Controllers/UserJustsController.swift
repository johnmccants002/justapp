//
//  UserJustsController.swift
//  PracticeCustomTableViews
//
//  Created by John McCants on 8/21/21.
//

import Foundation
import UIKit

public enum SimpleAnimationEdge {
  case none
  case top
  case bottom
  case left
  case right
}

class UserJustsController: UICollectionViewController, UINavigationControllerDelegate {
    
    // Properties
    
    var currentUser: User
    var userJusts = [Just]() {
        didSet {
            updateViews()
            userJusts.reverse()
            collectionView.reloadData()
        }
    }
    
    var currentUserArray: [User]?
    
    var lastJust : Just?
    var titleText: String
    let userUid: String
    let justNibName = "NetworkJustCell"
    let networkId: String
    var refreshControl = UIRefreshControl()
    
    // MARK: - Initializer
    
    init(currentUser: User, userUid: String, titleText: String, networkId: String) {
        self.currentUser = currentUser
        self.userUid = userUid
        self.titleText = titleText
        self.networkId = networkId
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
        fetchUserJusts()
        collectionView.isUserInteractionEnabled = true
        setupRefreshControl()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // needed to clear the text in the back navigation:
        self.navigationItem.title = " "
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = titleText
    }
    
    // MARK: Helper Functions
    
    func updateViews() {
        collectionView.delegate = self
        self.title = titleText
        let nib = UINib(nibName: justNibName, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "networkJustCell")
        collectionView.backgroundColor = .white
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
    }
    
    @objc func removeCell(cell: NetworkJustCell) {
        let i = cell.tag
        userJusts.remove(at: i)
        collectionView.reloadData()
    }

    
    func longPressAlert(currentUser: Bool, cell: NetworkJustCell) -> UIAlertController {
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        if currentUser == true {
            let alert = UIAlertController(title: "Delete", message: "You sure you want to delete this just?", preferredStyle: .alert)
            let deleteAction = UIAlertAction(title: "Delete", style: .default) { action in
                self.removeCell(cell: cell)
            }
            alert.addAction(deleteAction)
            alert.addAction(cancelAction)
            return alert
        } else {
            let alert = UIAlertController(title: "Report", message: "Would you like to report this just?", preferredStyle: .alert)
            let reportAction = UIAlertAction(title: "Report Just", style: .default, handler: nil)
            alert.addAction(reportAction)
            alert.addAction(cancelAction)
            return alert
        }
    }
    
    // MARK: - Firebase Functions
    
    func fetchUserJusts() {
        JustService.shared.fetchUserJusts(networkId: networkId, userUid: userUid) { justs in
            self.userJusts = justs
            self.checkIfUserRespectedJusts(justs: self.userJusts)
        }
    }
    
    func checkIfUserRespectedJusts(justs: [Just]) {
        let myGroup = DispatchGroup()
        for (index, just) in justs.enumerated() {
            myGroup.enter()
            JustService.shared.checkIfUserRespected(just: just) {
                didRespect in
                myGroup.leave()
                guard didRespect == true else { return }
                self.userJusts[index].didRespect = true
               
            }
        }
        myGroup.notify(queue: .main) {
            self.collectionView.reloadData()
            self.collectionView.refreshControl?.endRefreshing()
        }
    }
    func loadMoreJusts() {
        
    }
    
    func setupRefreshControl() {
        self.refreshControl.addTarget(self, action: #selector(reloadJusts), for: .valueChanged)
        self.collectionView.refreshControl = self.refreshControl
    }
    
    @objc func reloadJusts() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadNetworkJusts"), object: nil)
        fetchUserJusts()
    }
    
    // MARK: - UICollectionViewDelegate Functions
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "networkJustCell", for: indexPath) as! NetworkJustCell
        cell.just = userJusts[indexPath.row]
        cell.delegate = self
        cell.imageView.isUserInteractionEnabled = true
        cell.currentUserId = self.currentUser.uid
        cell.fetchToken()
        cell.tag = indexPath.row
        
        if userJusts[indexPath.row].uid == currentUser.uid {
            cell.setupRespectButton()
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userJusts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "networkJustCell", for: indexPath) as! NetworkJustCell
        cell.imageView.isUserInteractionEnabled = true
        cell.delegate = self
        let tap = UIGestureRecognizer(target: self, action: #selector(cell.imageTapped))
        cell.imageView.addGestureRecognizer(tap)
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if (indexPath.row == userJusts.count - 1) {
            loadMoreJusts()
        }
    }
}

// MARK: UICollectionViewDelegateFlowLayout

extension UserJustsController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let just = userJusts[indexPath.row]
        let viewModel = JustViewModel(just: just)
        let height = viewModel.size(forWidth: view.frame.width).height
        return CGSize(width: view.frame.width - 20, height: height + 80)
    }
}

// MARK: NetworkJustCellDelegate

extension UserJustsController: NetworkJustCellDelegate {
    func respectCountTapped(cell: NetworkJustCell) {
        guard let just = cell.just else { return }
        let controller = RespectedByViewController(just: just, currentUser: currentUser)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        self.navigationController?.pushViewController(controller, animated: true)
    }

    
    func didLongPress(cell: NetworkJustCell) {
        guard let just = cell.just else { return }
        print("just.uid \(just.uid) and currentUser.uid: \(currentUser.uid)")
        if just.uid == self.currentUser.uid {
            let alert = self.longPressAlert(currentUser: true, cell: cell)
            self.present(alert, animated: true, completion: nil)
        } else if just.uid != self.currentUser.uid {
            let alert = self.longPressAlert(currentUser: false, cell: cell)
            self.present(alert, animated: true, completion: nil)
        }

    }
    
    func imageTapped(cell: NetworkJustCell) {
        guard let uid = cell.just?.uid else { return }
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
    
    func respectTapped(cell: NetworkJustCell) {
        let title = "New Respect"
        
       
        let body = "\(currentUser.firstName) \(currentUser.lastName) respected your just."
        guard var just = cell.just else { return }
        if let lastJust = lastJust {
            if lastJust.justID == just.justID {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadNetworkJusts"), object: nil)
            }
        }
        
        guard let token = cell.token else { return }
        print("this is the token \(token)")
        if just.didRespect == false {
            PushNotificationSender.shared.sendPushNotification(to: token, title: title, body: body, id: self.currentUser.uid)
        }
        
        JustService.shared.respectJust(just: just, currentUser: currentUser) { error, ref in
//            guard let token = cell.token else { return }
//            print("this is the token \(token)")
//                PushNotificationSender.shared.sendPushNotification(to: token, title: title, body: body, id: self.currentUser.uid)
            
            
        }
    }
    
}
