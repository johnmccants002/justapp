//
//  NetworkJustsController.swift
//  PracticeCustomTableViews
//
//  Created by John McCants on 8/20/21.
//

import Foundation
import UIKit

private let headerIdentifier = "JustsHeader"

class NetworkJustsController: UICollectionViewController, UINavigationControllerDelegate {
    
    // MARK: - Properties
    
    var currentUser: User
    var lastJusts = [Just]() {
        didSet {
            collectionView.isUserInteractionEnabled = true
            fetchAllNetworkJusts()
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
    
    var allNetworkJusts = [Just]()
     
    var lastJustIds: [String]? {
        didSet {
            guard let lastJustIds = lastJustIds else { return }
            fetchOtherJusts(lastJustIds: lastJustIds)
        }
    }
    
    var allJusts : [[Just]]? {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var user: User
    
    // MARK: - Initializer
    
    init(currentUser: User, titleText: String, networkId: String, user: User) {
        self.currentUser = currentUser
        self.titleText = titleText
        self.networkId = networkId
        self.user = user
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
        setupRightBarButtonItem()
        setupCurrentUserArray()
        overrideUserInterfaceStyle = .light
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
        let nib = UINib(nibName: justNibName, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "networkJustCell")
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsets(top: -5, left: 0, bottom: 0, right: 0)
        
        collectionView.register(JustsHeader.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)
   
    }
    
    func setupRightBarButtonItem() {
        if titleText == "My Network" {
    
        let button : UIButton = {
            let button = UIButton(type: .infoLight, primaryAction: nil)
            button.addTarget(self, action: #selector(rightBarButtonTapped), for: .touchUpInside)
            
            return button
        }()
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.setRightBarButton(barButton, animated: true)
        
        }
    }
    
    func longPressAlert(currentUser: Bool, cell: NetworkJustCell) -> UIAlertController {
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        if currentUser == true {
            let alert = UIAlertController(title: "Delete", message: "You sure you want to delete this just?", preferredStyle: .alert)
            let deleteAction = UIAlertAction(title: "Delete", style: .default) { action in
                self.removeCell(cell: cell)
                guard let currentUserArray = self.currentUserArray, let just = cell.just else { return }
                var networkIds = currentUserArray.map { $0.networkId }
                JustService.shared.deleteJust(networkIDs: networkIds, justID: just.justID, uid: self.currentUser.uid, currentUserNetworkID: self.currentUser.networkId) {
                    self.collectionView.reloadData()
                }
                
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
            
            var lastJustIds : [String] = []
            for var just in justs {
                lastJustIds.append(just.justID)
            }
            self.lastJustIds = lastJustIds
            self.lastJusts = justs
            
            if self.lastJusts.isEmpty == false {
                self.checkIfUserRespectedJusts(justs: self.lastJusts)
            }
      
           
        }
    }
    
    func fetchOtherJusts(lastJustIds: [String]) {
        if lastJustIds.isEmpty == false {
        JustService.shared.testGrabAllJusts(lastJustIds: lastJustIds, networkId: networkId) { justs in
            self.collectionView.refreshControl?.endRefreshing()
            var sortedJusts = justs.sorted(by: {
                $0.dateString!.compare($1.dateString!) == .orderedDescending
            })
            
            var objectGroups = Array(Dictionary(grouping:sortedJusts){$0.dateString}.values.sorted(by: { $0.first!.timestamp.compare($1.first!.timestamp) == .orderedDescending }))

            objectGroups.insert(self.lastJusts, at: 0)
            self.allJusts = objectGroups
        }
        }
    }
    
    func sortJusts() {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.calendar]
        
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
    
    func fetchAllNetworkJusts() {
        
    }
    // MARK: - Selectors
    
    @objc func removeCell(cell: NetworkJustCell) {
        let i = cell.tag
        lastJusts.remove(at: i)
        collectionView.reloadData()
    }
    
    @objc func reloadNetworkJusts() {
        fetchLastJusts()
    }
    
    @objc func rightBarButtonTapped() {
        print("right bar button tapped")
        guard let currentUserArray = currentUserArray else { return }
        if self.currentUser == user {
            let controller = NetworkDetailsController(currentUser: currentUser, user: currentUser, currentUserArray: currentUserArray)
            controller.networkUsers = currentUserArray
            
            self.navigationController?.pushViewController(controller, animated: true)
        } else {
            let controller = NetworkDetailsController(currentUser: currentUser, user: user, currentUserArray: currentUserArray)
            controller.fetchNetworkUsers()
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    

    
    
    // MARK: - UICollectinViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "networkJustCell", for: indexPath) as! NetworkJustCell
        if let allJusts = allJusts {
            cell.just = allJusts[indexPath.section][indexPath.row]
            cell.delegate = self
            cell.currentUserId = self.currentUser.uid
            cell.fetchToken()
            cell.timestampLabel.isHidden = true
        }
         
 
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let allJusts = allJusts else { return 0 }
        return allJusts[section].count
        
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard let allJusts = allJusts else { return 0 }
        return allJusts.count
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let allJusts = allJusts else { return }
        let just = allJusts[indexPath.section][indexPath.row]

        let titleText = "\(just.firstName) \(just.lastName)"
        let userUid = just.uid
        let controller = UserJustsController(currentUser: currentUser, userUid: userUid, titleText: titleText, networkId: networkId)
        controller.lastJust = just
        if let currentUserArray = self.currentUserArray {
        controller.currentUserArray = currentUserArray
        }
        navigationController?.pushViewController(controller, animated: true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! JustsHeader
        
        guard let allJusts = allJusts else { return sectionHeader }
        
        sectionHeader.date = allJusts[indexPath.section].first?.dateString!
            
        return sectionHeader
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: self.view.bounds.width, height: 50)
    }
    
}

extension NetworkJustsController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let allJusts = allJusts else { return CGSize() }
        let just = allJusts[indexPath.section][indexPath.row]
        let viewModel = JustViewModel(just: just)
        let height = viewModel.size(forWidth: view.frame.width).height
        return CGSize(width: view.frame.width - 20, height: height + 100)
    }
    

    
}

extension NetworkJustsController: NetworkJustCellDelegate {
    func moreButtonTapped(cell: NetworkJustCell) {
        guard let just = cell.just  else { return }
        let titleText = "\(just.firstName) \(just.lastName)"
        let userUid = just.uid
        let controller = UserJustsController(currentUser: currentUser, userUid: userUid, titleText: titleText, networkId: networkId)
        controller.lastJust = just
        if let currentUserArray = self.currentUserArray {
        controller.currentUserArray = currentUserArray
        }
        navigationController?.pushViewController(controller, animated: true)
    }
    
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
