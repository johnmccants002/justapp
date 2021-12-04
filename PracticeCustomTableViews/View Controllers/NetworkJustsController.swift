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
     
    var lastJustIds: [String]? 
    
    var allJusts : [[Just]]?
    
    var fireUsers: [String: Int]? {
        didSet {
            self.collectionView.reloadData()
        }
    }
    
    var todayArray: [String] = [] {
        didSet {
            print("This is the todayArray \(todayArray)")
            self.fetchSetFireUsers(todayArray: todayArray)
        }
    }
    
    
    
    var user: User
    
    private var cache = NSCache<NSString, UserJustsObject>()
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
        self.cache.removeAllObjects()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.title = titleText
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.barStyle = .default
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.cache.removeAllObjects()
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
        
        } else {
            let button : UIButton = {
                let button = UIButton()
                button.addTarget(self, action: #selector(networkBarButtonTapped), for: .touchUpInside)
                button.setTitle("🚪", for: .normal)
                button.titleLabel?.textAlignment = .center
                
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
            var newJusts: [Just] = []
            var dict : [String: Int] = [:]
            for var just in justs {
                if just.timestamp.timeIntervalSinceNow > -3600 {
                    lastJustIds.append(just.justID)
                    newJusts.append(just)
                    print("We have just within last hour")
                    self.todayArray.append(just.uid)
                }
                    
                
            }
            self.lastJustIds = lastJustIds
            self.lastJusts = newJusts
            self.fetchOtherJusts(lastJustIds: lastJustIds)
           
        }
    }
    
    func fetchOtherJusts(lastJustIds: [String]) {
        if lastJustIds.isEmpty == false {
        JustService.shared.testGrabAllJusts(lastJustIds: lastJustIds, networkId: networkId) { justs in
            var sortedJusts = justs.sorted(by: {
                $0.dateString!.compare($1.dateString!) == .orderedDescending
            })
            for just in sortedJusts {
                if just.dateString == "Today" {
                    self.todayArray.append(just.uid)
                }
            }
            
            
            var objectGroups = Array(Dictionary(grouping:sortedJusts){$0.dateString}.values.sorted(by: { $0.first!.timestamp.compare($1.first!.timestamp) == .orderedDescending }))
            
            if self.lastJusts.isEmpty == false {
                objectGroups.insert(self.lastJusts, at: 0)
                self.allJusts = objectGroups
                self.checkIfUserRespectedJusts(justs: objectGroups)
                self.fetchJustRespects(justs: objectGroups) {
                }
            } else {
                self.allJusts = objectGroups
                self.checkIfUserRespectedJusts(justs: objectGroups)
                self.fetchJustRespects(justs: objectGroups) {
                }
            }
           
        }
        } else {
            JustService.shared.grabAllJusts(networkId: networkId) { justs in
                var sortedJusts = justs.sorted(by: {
                    $0.dateString!.compare($1.dateString!) == .orderedDescending
                })
                for just in sortedJusts {
                    if just.dateString == "Today" {
                        self.todayArray.append(just.uid)
                    }
                }
                
                var objectGroups = Array(Dictionary(grouping:sortedJusts){$0.dateString}.values.sorted(by: { $0.first!.timestamp.compare($1.first!.timestamp) == .orderedDescending }))
                
                self.allJusts = objectGroups
                self.checkIfUserRespectedJusts(justs: objectGroups)
                self.fetchJustRespects(justs: objectGroups) {
                }
            }
        }
        
    }
    
    func sortJusts() {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.calendar]
        
    }
    
    func checkIfUserRespectedJusts(justs: [[Just]]) {
        if let allJusts = self.allJusts {
        let myGroup = DispatchGroup()
            DispatchQueue.main.async {
        for (index1, justArray) in justs.enumerated() {
            myGroup.enter()
        for (index2, just) in justArray.enumerated() {
            JustService.shared.checkIfUserRespected(just: just) {
                didRespect in
                guard didRespect == true else { return }
                self.allJusts?[index1][index2].didRespect = true
                
                if let cachedJust = self.cache.object(forKey: just.justID as NSString) {
                    self.cache.object(forKey: just.justID as NSString)?.just.didRespect = true
                }
               
            }
        }
        }
            myGroup.leave()
        }
            self.collectionView.reloadData()
        myGroup.notify(queue: .main) {
            self.collectionView.refreshControl?.endRefreshing()
            self.collectionView.reloadData()
        }
        }
    }
    
    
    func fetchJustRespects(justs: [[Just]], completion: @escaping() -> (Void)) {
        guard let allJusts = allJusts else { return }
            print("in fetch just respects")
        
        for var (index, justArray) in allJusts.enumerated() {
           
                for var (index2, just) in justArray.enumerated() {
//                if just.uid == currentUser.uid {
                    JustService.shared.fetchJustRespects(just: just) { respectCount in
                        if let respectCount = respectCount {
                            self.allJusts?[index][index2].respects = Int(respectCount)

                            if let cachedJust = self.cache.object(forKey: just.justID as NSString) {
                                cachedJust.just.respects = Int(respectCount)
                            }
                        }
                        
                    }
                   
            }
            
        }
            self.collectionView.reloadData()
        
    }
    
    func fetchSetFireUsers(todayArray: [String]) {
        let mappedItems = todayArray.map { ($0, 1) }
        let counts = Dictionary(mappedItems, uniquingKeysWith: +)
        print("This is the counts: \(counts)")
        self.fireUsers = counts
        self.collectionView.reloadData()
        
        
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
        guard let currentUserArray = currentUserArray else { return }
        if self.currentUser == user {
            let controller = NetworkDetailsController(currentUser: currentUser, user: currentUser, currentUserArray: currentUserArray)
            controller.fetchNetworkUsers()
            
            self.navigationController?.pushViewController(controller, animated: true)
        } else {
            let controller = NetworkDetailsController(currentUser: currentUser, user: user, currentUserArray: currentUserArray)
            controller.fetchNetworkUsers()
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    @objc func networkBarButtonTapped() {
        let alert = UIAlertController(title: "Leave Network", message: "Do you want to leave \(user.firstName)'s network?", preferredStyle: .actionSheet)
        let action = UIAlertAction(title: "Yes", style: .default) { action in
            self.leaveNetworkTapped()
        }
        let cancelAction = UIAlertAction(title: "No", style: .cancel) { action in
            
        }
        alert.addAction(action)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func leaveNetworkTapped() {
        NetworkService.shared.leaveNetwork(currentUserUid: currentUser.uid, userUid: user.uid, networkId: networkId) {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refetchUser"), object: nil)
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    

    
    
    // MARK: - UICollectinViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "networkJustCell", for: indexPath) as! NetworkJustCell
  
        
        if var allJusts = allJusts {
            let idString = allJusts[indexPath.section][indexPath.row].justID as NSString
            if let cachedJust = self.cache.object(forKey: idString), cachedJust.just.justID == allJusts[indexPath.section][indexPath.row].justID {
                cell.section = indexPath.section
                cell.row = indexPath.row
                cell.timestampLabel.isHidden = true
                if cachedJust.just.uid == currentUser.uid {
                    cell.currentUser = currentUser
                    cell.currentUserId = currentUser.uid
                }
                if let fireUsers = self.fireUsers {
                    if fireUsers[cachedJust.just.uid] ?? 0 >= 3 {
                        cachedJust.just.userOnFire = true
                        print("this is fire users \(fireUsers)")
                    } else {
                        cell.fireLabel.isHidden = true
                    }
                }
                cell.just = self.cache.object(forKey: idString as NSString)?.just
                
                
                print("we have a cached just")
            } else {
            cell.delegate = self
            cell.currentUserId = self.currentUser.uid
            cell.fetchToken()
            cell.timestampLabel.isHidden = true
            cell.section = indexPath.section
            cell.row = indexPath.row
                if allJusts[indexPath.section][indexPath.row].uid == currentUser.uid {
                    cell.currentUser = currentUser
                    cell.currentUserId = currentUser.uid
                }
                if let fireUsers = self.fireUsers {
                    if fireUsers[allJusts[indexPath.section][indexPath.row].uid] ?? 0 >= 3 {
                        allJusts[indexPath.section][indexPath.row].userOnFire = true
                    } else {
                        cell.fireLabel.isHidden = true
                    }
                }
            cell.just = allJusts[indexPath.section][indexPath.row]
            self.cache.setObject(UserJustsObject(just: allJusts[indexPath.section][indexPath.row]), forKey: idString)
            }


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
        if let userOnFire = cell.just?.userOnFire {
            controller.userOnFire = userOnFire
        }
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
            print("If let false")
            if let section = cell.section, let row = cell.row {
                self.allJusts?[section][row].didRespect = true
            }
            if let cachedObject = self.cache.object(forKey: just.justID as NSString) {
                cachedObject.just.didRespect = true
            }
        } else {
            if let section = cell.section, let row = cell.row {
                self.allJusts?[section][row].didRespect = false
            }
            if let cachedObject = self.cache.object(forKey: just.justID as NSString) {
                cachedObject.just.didRespect = false
            }
            guard let token = cell.token else { return }
            PushNotificationSender.shared.sendPushNotification(to: token, title: title, body: body, id: self.currentUser.uid)
        }
        JustService.shared.respectJust(just: just, currentUser: currentUser) { error, ref in
            self.collectionView.reloadData()
        }
        
        
    }
    
    
}
