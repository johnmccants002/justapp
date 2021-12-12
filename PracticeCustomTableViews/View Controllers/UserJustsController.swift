//
//  UserJustsController.swift
//  PracticeCustomTableViews
//
//  Created by John McCants on 8/21/21.
//

import Foundation
import UIKit

private let headerIdentifier = "JustsHeader"
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
    
    var allJusts : [[Just]]? {
        didSet {
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
    private let cache = NSCache<NSString, UserJustsObject>()
    var userOnFire: Bool = false
    
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
        overrideUserInterfaceStyle = .light
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // needed to clear the text in the back navigation:
        self.navigationItem.title = " "
        self.cache.removeAllObjects()
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
        collectionView.contentInset = UIEdgeInsets(top: -5, left: 0, bottom: 0, right: 0)
        
        collectionView.register(JustsHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)
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
                guard let currentUserArray = self.currentUserArray, let just = cell.just else { return }
                let networkIds = currentUserArray.map { $0.networkId }
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
    
    // MARK: - Firebase Functions
    
    func fetchUserJusts() {
        JustService.shared.fetchUserJusts(networkId: networkId, userUid: userUid) { justs in
            self.userJusts = justs
            var sortedJusts = justs.sorted(by: {
                $0.dateString!.compare($1.dateString!) == .orderedDescending
            })
            
            var objectGroups = Array(Dictionary(grouping:sortedJusts){$0.dateString}.values.sorted(by: { $0.first!.timestamp.compare($1.first!.timestamp) == .orderedDescending }))
            
            self.allJusts = objectGroups
            if self.userUid != self.currentUser.uid {
                self.checkIfUserRespectedJusts(justs: objectGroups)
            } else {
                self.fetchJustRespects(justs: objectGroups) {
                }
            }
        }
    }
    
//    func checkIfUserRespectedJusts(justs: [Just]) {
//        let myGroup = DispatchGroup()
//        for (index, just) in justs.enumerated() {
//            myGroup.enter()
//            JustService.shared.checkIfUserRespected(just: just) {
//                didRespect in
//                myGroup.leave()
//                guard didRespect == true else { return }
//                self.userJusts[index].didRespect = true
//
//            }
//        }
//        myGroup.notify(queue: .main) {
//            let sortedJusts = justs.sorted(by: {
//                $0.dateString!.compare($1.dateString!) == .orderedAscending
//            })
//
//            let objectGroups = Array(Dictionary(grouping:sortedJusts){$0.dateString}.values.sorted(by: { $0.first!.timestamp.compare($1.first!.timestamp) == .orderedDescending }))
//            self.allJusts = objectGroups
//            self.collectionView.refreshControl?.endRefreshing()
//        }
//    }
    
    func checkIfUserRespectedJusts(justs: [[Just]]) {
        if let allJusts = self.allJusts {
        let myGroup = DispatchGroup()
        for (index1, justArray) in justs.enumerated() {
            myGroup.enter()
        for (index2, just) in justArray.enumerated() {
            JustService.shared.checkIfUserRespected(just: just) {
                didRespect in
                guard didRespect == true else { return }
                self.allJusts?[index1][index2].didRespect = true
                self.collectionView.refreshControl?.endRefreshing()
            }
        }
            myGroup.leave()
        }
        myGroup.notify(queue: .main) {
            self.collectionView.reloadData()
        }
        }
    }
    
    func fetchJustRespects(justs: [[Just]], completion: @escaping() -> (Void)) {
        if userUid == currentUser.uid {
        guard let allJusts = allJusts else { return }
            print("in fetch just respects")
            let myGroup = DispatchGroup()
        for var (index, justArray) in allJusts.enumerated() {
            for var (index2, just) in justArray.enumerated() {
                    JustService.shared.fetchJustRespects(just: just) { respectCount in
                        if let respectCount = respectCount {
                            self.allJusts?[index][index2].respects = Int(respectCount)
                        }
                    }
            }
            
        }
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
        
        if var allJusts = allJusts {
            let idString = allJusts[indexPath.section][indexPath.row].justID as NSString
            if let cachedJust = self.cache.object(forKey: idString) {
                print("We have a cached just")
                cell.just = cachedJust.just
                cell.delegate = self
                cell.imageView.isUserInteractionEnabled = true
                cell.currentUserId = self.currentUser.uid
                cell.fetchToken()
                cell.timestampLabel.isHidden = true
                cell.moreJustsButton.isHidden = true
                cell.currentUser = currentUser
                
            }
            allJusts[indexPath.section][indexPath.row].userOnFire = userOnFire
            cell.just = allJusts[indexPath.section][indexPath.row]
            cell.delegate = self
            cell.imageView.isUserInteractionEnabled = true
            cell.currentUserId = self.currentUser.uid
            cell.fetchToken()
            cell.timestampLabel.isHidden = true
            cell.moreJustsButton.isHidden = true
            cell.currentUser = currentUser
            self.cache.setObject(UserJustsObject(just: allJusts[indexPath.section][indexPath.row]), forKey: idString)
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let allJusts = allJusts {
            return allJusts[section].count
        }
        return 0
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        if let allJusts = allJusts {
            return allJusts.count
        }
        return 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "networkJustCell", for: indexPath) as! NetworkJustCell
        cell.imageView.isUserInteractionEnabled = true
        cell.delegate = self
        let tap = UIGestureRecognizer(target: self, action: #selector(cell.imageTapped))
        cell.imageView.addGestureRecognizer(tap)
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
    
//    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        if (indexPath.row == userJusts.count - 1) {
//            loadMoreJusts()
//        }
//    }
}

// MARK: UICollectionViewDelegateFlowLayout

extension UserJustsController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let allJusts = allJusts else { return CGSize()}
        let just = allJusts[indexPath.section][indexPath.row]
        let viewModel = JustViewModel(just: just)
        let height = viewModel.size(forWidth: view.frame.width).height
        return CGSize(width: view.frame.width - 20, height: height + 100)
    }
}

// MARK: NetworkJustCellDelegate

extension UserJustsController: NetworkJustCellDelegate {
    func detailsTapped(cell: NetworkJustCell) {
        guard let just = cell.just else { return }
        if let details = just.details, !details.isEmpty {
            let controller = JustDetailsController()
            controller.just = just
            self.navigationController?.present(controller, animated: true, completion: nil)
        }
    }
    
    func moreButtonTapped(cell: NetworkJustCell) {
        
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
