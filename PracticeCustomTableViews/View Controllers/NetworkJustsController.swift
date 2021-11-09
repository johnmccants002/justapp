//
//  NetworkJustsController.swift
//  PracticeCustomTableViews
//
//  Created by John McCants on 8/20/21.
//

import Foundation
import UIKit

class NetworkJustsController: UICollectionViewController, UINavigationControllerDelegate {
    
    // MARK: - Properties
    
    var currentUser: User
    var lastJusts = [Just]() {
        didSet {
            collectionView.isUserInteractionEnabled = true
            collectionView.reloadData()
        }
    }
    let justNibName = "NetworkJustCell"
    var networkId: String
    var titleText: String
    var refreshControl = UIRefreshControl()
    var currentUserArray : [User]? {
        didSet {
            collectionView.reloadData()
        }
    }
    
    // MARK: - Initializer
    
    init(currentUser: User, titleText: String, networkId: String) {
        self.currentUser = currentUser
        self.titleText = titleText
        self.networkId = networkId
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchLastJusts()
        updateViews()
        addObservers()
        setupRefreshControl()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // needed to clear the text in the back navigation:
        self.navigationItem.title = ""
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = titleText
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.barStyle = .default
    }
    
    // MARK: - Helper Functions
    
    func updateViews() {
        print("update views being called")
        let nib = UINib(nibName: justNibName, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "networkJustCell")
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
   
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
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(reloadNetworkJusts), name: NSNotification.Name.init("reloadNetworkJusts"), object: nil)
    }
    
    @objc func reloadNetworkJusts() {
        fetchLastJusts()
    }
    
    func setupRefreshControl() {
        self.refreshControl.addTarget(self, action: #selector(reloadNetworkJusts), for: .valueChanged)
        self.collectionView.refreshControl = self.refreshControl
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

    
    // MARK: - Firebase Functions
    
    func fetchLastJusts() {
        JustService.shared.fetchLastJusts(networkID: networkId) { justs in
            print(justs)
            self.lastJusts = justs
            self.checkIfUserRespectedJusts(justs: self.lastJusts)
            self.collectionView.refreshControl?.endRefreshing()
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
                self.lastJusts[index].didRespect = true
                self.collectionView.refreshControl?.endRefreshing()
                
            }
            
        }
        myGroup.notify(queue: .main) {
            self.collectionView.reloadData()
        }
    }
    
    @objc func removeCell(cell: NetworkJustCell) {
        let i = cell.tag
        lastJusts.remove(at: i)
        collectionView.reloadData()
    }
    

    
    
    // MARK: - UICollectinViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "networkJustCell", for: indexPath) as! NetworkJustCell
            cell.just = lastJusts[indexPath.row]
            cell.delegate = self
            cell.currentUserId = self.currentUser.uid
            cell.fetchToken()
        
//        if lastJusts[indexPath.row].uid == currentUser.uid {
//            cell.setupRespectCountButton()
//        }
        
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return lastJusts.count
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let just = lastJusts[indexPath.row]
        
        let titleText = "\(just.firstName) \(just.lastName)"
        let userUid = just.uid
        let controller = UserJustsController(currentUser: currentUser, userUid: userUid, titleText: titleText, networkId: networkId)
        controller.lastJust = just
        if let currentUserArray = self.currentUserArray {
        controller.currentUserArray = currentUserArray
        }
        navigationController?.pushViewController(controller, animated: true)
    }
    
}

extension NetworkJustsController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let just = lastJusts[indexPath.row]
        let viewModel = JustViewModel(just: just)
        let height = viewModel.size(forWidth: view.frame.width).height
        return CGSize(width: view.frame.width - 20, height: height + 80)
    }
    
}

extension NetworkJustsController: NetworkJustCellDelegate {
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
        if just.didRespect == false {
            guard let token = cell.token else { return }
            PushNotificationSender.shared.sendPushNotification(to: token, title: title, body: body, id: self.currentUser.uid)
        }

        JustService.shared.respectJust(just: just, currentUser: currentUser) { error, ref in
        }
        
    }
    
    
}
