//
//  CurrentUserController.swift
//  PracticeCustomTableViews
//
//  Created by John McCants on 8/24/21.
//

import Foundation
import UIKit

private let reuseIdentifier = "networkJustCell"
private let headerIdentifier = "ProfileHeader"

class CurrentUserController: UICollectionViewController, UINavigationControllerDelegate {

    // MARK - Properties

    var currentUser: User {
        didSet {
            collectionView.reloadData()
            print("Current user didset called")
        }
    }
    
    var previewURL: URL?
    var justs = [Just]() {
        didSet {
            collectionView.reloadData()
        }
    }
    let justNibName = "NetworkJustCell"

    
    var user: User? {
        didSet {
            collectionView.reloadData()
            fetchSharedNetworks()
        }
    }
    var currentUserArray: [User]? {
        didSet {
            fetchSharedNetworks()
        }
    }
    
    var sharedArray: [User]? {
        didSet {
            collectionView.reloadData()
        }
    }
    var isUser: Bool
    var userJustsArray : [UserJustsObject]? {
        didSet {
            print("userJustsArray didSet")
            self.collectionView.reloadData()
        }
    }
    
    private let cache = NSCache<NSNumber, UserJustsObject>()
     
    
    private let utilityQueue = DispatchQueue.global(qos: .utility)
    
    // MARK - Initializer
    
    init(currentUser: User, isUser: Bool) {
        self.currentUser = currentUser
        self.isUser = isUser
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK - Lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUserJusts()
        addObservers()
        setupCurrentUserArray()
        overrideUserInterfaceStyle = .light
        print("Is User is == to \(isUser)")
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        updateViews()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.cache.removeAllObjects()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.isHidden = false
    }
    
    
    
    // MARK: - Firebase Functions
    
    func fetchUserJusts() {
            if isUser == false {
            JustService.shared.fetchUserJusts(networkId: currentUser.networkId, userUid: currentUser.uid) { justs in
                self.justs = justs
                self.justs.reverse()
                self.fetchJustRespects(justs: self.justs) {
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    func setUserJustsArray(justs: [Just]) {
        var justObjects: [UserJustsObject] = []
        for just in justs {
            justObjects.append(UserJustsObject(just: just))
        }
        self.userJustsArray = justObjects
    }
    
    func checkIfUserRespectedJusts(justs: [Just], completion:@escaping() -> (Void)) {
        for (index, just) in justs.enumerated() {
            JustService.shared.checkIfUserRespected(just: just) {
                didRespect in
                guard didRespect == true else { return }
                let itemNumber = NSNumber(value: index)
                if let cachedObject = self.cache.object(forKey: itemNumber) {
                    cachedObject.just.didRespect = true
                } else {
                    
                    self.justs[index].didRespect = true
                }
            }
        }
    }
    
    func fetchJustRespects(justs: [Just], completion: @escaping() -> (Void)) {
        print("fetchJustRespects Called")
        if isUser == false {
            print("in fetch just respects")
            let myGroup = DispatchGroup()
            for var (index, just) in self.justs.enumerated() {
                myGroup.enter()
                JustService.shared.fetchJustRespects(just: just) { respectCount in
                    if let respectCount = respectCount {
                        self.justs[index].respects = Int(respectCount)
                    }
                    myGroup.leave()
                }
            }
            myGroup.notify(queue: .main) {
                self.collectionView.reloadData()
                self.setUserJustsArray(justs: self.justs)
            }
            
        }
    }
    
    func fetchUser(uid: String) {
        UserService.shared.fetchUser(uid: uid) { user in
            self.user = user
        }
    }
    
    func fetchSharedNetworks() {
        guard let currentUserArray = self.currentUserArray else { return }
        if isUser == true {
            if let user = user {
                UserService.shared.fetchSharedNetworks(currentUserArray: currentUserArray, user: user) { users in
                    if users.count >= 1 {
                    self.sharedArray = users
                    }
                    for user in users {
                        print("Current user and user are in \(user.username) network")
                    }
                }
            }
        }
    }
    
    // MARK - Helper Functions
    
    func updateViews() {
        configureCollectionView()
        
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
    
    func loadJust(completion: @escaping(Just?) -> ()) {
        
    }

    
    func addObservers() {
            NotificationCenter.default.addObserver(self, selector: #selector(refetchCurrentUser), name: NSNotification.Name.init("refetchCurrentUser"), object: nil)
        
    }
    
    @objc func refetchCurrentUser() {
            UserService.shared.fetchUser(uid: self.currentUser.uid) { user in
                self.currentUser = user

        }
    }
    
    // MARK: UICollectionView Functions

    
    func configureCollectionView() {
        navigationController?.navigationBar.isHidden = true
        collectionView.delegate = self
        self.title = "\(currentUser.firstName) \(currentUser.lastName)"
        let nib = UINib(nibName: justNibName, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "networkJustCell")
        collectionView.backgroundColor = .white
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.backgroundColor = .white
        collectionView.register(ProfileHeader.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! NetworkJustCell
            
        let itemNumber = NSNumber(value: indexPath.row)
        cell.currentUserId = currentUser.uid
        cell.delegate = self
        cell.moreJustsButton.isHidden = true
        
        
        if let cachedJust = self.cache.object(forKey: itemNumber) {
            cell.just = cachedJust.just
            print("we have cachedJust")
            print("This is the number of respects: \(cachedJust.just.respects)")
        } else {
            print("we do not have cachedJust")
            cell.just = justs[indexPath.row]
            cell.setupRespectCountButton()
            guard let userJustsArray = userJustsArray else {  return cell }
            self.cache.setObject(userJustsArray[indexPath.row], forKey: itemNumber)
            print("we did set the cache object")
        }
        
        cell.tag = indexPath.row
        
        if justs[indexPath.row].uid == currentUser.uid {
            cell.currentUser = self.currentUser
        }
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return justs.count
    }
}

// MARK: - ProfileHeaderDelegate

extension CurrentUserController: ProfileHeaderDelegate {
    func handleSharedNetworksTapped(_ header: ProfileHeader) {
        guard let sharedArray = sharedArray else { return }
        let controller = SharedNetworksController(users: sharedArray, currentUser: currentUser)
        
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func imageViewTapped(_ header: ProfileHeader, url: URL) {
        
    }
    
    func handleSettingsTapped(_ header: ProfileHeader) {
        let controller = SettingsController(currentUser: currentUser)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func handleBackTapped(_ header: ProfileHeader) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func removeCell(cell: NetworkJustCell) {
        
        guard let just = cell.just, let currentUserArray = currentUserArray else { return }
        var networkIds: [String] = []
        for user in currentUserArray {
            networkIds.append(user.networkId)
        }
        
        
        JustService.shared.deleteJust(networkIDs: networkIds, justID: just.justID, uid: currentUser.uid, currentUserNetworkID: currentUser.networkId) {
            print("In delete just completion handler")
            self.collectionView.reloadData()
        }

    }
    
    // MARK: - Long Press Alert
    
    func longPressAlert(currentUser: Bool, cell: NetworkJustCell) -> UIAlertController {
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        if currentUser == true {
            let alert = UIAlertController(title: "Delete", message: "You sure you want to delete this just?", preferredStyle: .alert)
            let deleteAction = UIAlertAction(title: "Delete", style: .default) { action in
                self.removeCell(cell: cell)
                self.justs.remove(at: cell.tag)
                let itemNumber = NSNumber(value: cell.tag)
                self.cache.removeObject(forKey: itemNumber)
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
    
    
}

// MARK: UICollectionViewDelegateFlowLayout

extension CurrentUserController: UICollectionViewDelegateFlowLayout {
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! ProfileHeader
        
        if isUser == true {
            print("isUser == true")
            header.user = self.user
            header.isUser = true
            header.delegate = self
            if let sharedArray = self.sharedArray {
                header.sharedArray = sharedArray
            }
        } else if isUser == false {
            print("isUser == not true")
            header.isUser = false
            header.currentUser = currentUser
            header.delegate = self
       
        }
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if isUser == false {
            return CGSize(width: view.frame.width, height: 440)
        }
        
        if let user = user {
            if user.instagramUsername != "" {
                return CGSize(width: view.frame.width, height: 440)
            } else {
                print("returned 300")
                return CGSize(width: view.frame.width, height: 300)
            }
        }
        return CGSize(width: view.frame.width, height: 440)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: view.frame.width, height: 120)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 15.0, left: 1.0, bottom: 1.0, right: 1.0)
    }
}

// MARK: NetworkJustCellDelegate

extension CurrentUserController: NetworkJustCellDelegate {
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
        print("This is the cell.tag: \(cell.tag)")
        if just.uid == self.currentUser.uid {
            let alert = self.longPressAlert(currentUser: true, cell: cell)
            self.present(alert, animated: true, completion: nil)
        } else if just.uid != self.currentUser.uid {
            let alert = self.longPressAlert(currentUser: false, cell: cell)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func imageTapped(cell: NetworkJustCell) {
    }
    
    func respectTapped(cell: NetworkJustCell) {
    }
    
    
}




