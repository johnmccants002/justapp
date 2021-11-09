//
//  CurrentUserController.swift
//  PracticeCustomTableViews
//
//  Created by John McCants on 8/24/21.
//

import Foundation
import UIKit
import QuickLook

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
    
    private let cache = NSCache<NSNumber, Just>()
    private let utilityQueue = DispatchQueue.global(qos: .utility)
    
    var instagramButton : UIButton = {
        var button = UIButton()
        button.backgroundColor = .brown
        button.setTitle("Instagram", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(instagramButtonTapped), for: .touchUpInside)
//        button.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 16)
        return button
    }()
    
    var twitterButton: UIButton = {
        var button = UIButton()
        button.backgroundColor = .twitterBlue
        button.setTitle("Twitter", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(twitterButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
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
//        updateViews()
        fetchUserJusts()
        addObservers()
        setupCurrentUserArray()
        
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
        if isUser == true {
            guard let user = user else { return }
            JustService.shared.fetchUserJusts(networkId: user.networkId, userUid: user.uid) { justs in
                self.justs = justs
                self.checkIfUserRespectedJusts(justs: self.justs)
                self.justs.reverse()
            }
        } else if isUser == false {
            JustService.shared.fetchUserJusts(networkId: currentUser.networkId, userUid: currentUser.uid) { justs in
                self.justs = justs
                self.checkIfUserRespectedJusts(justs: self.justs)
                self.justs.reverse()
        }
        }
    }
    
    func checkIfUserRespectedJusts(justs: [Just]) {
        for (index, just) in justs.enumerated() {
            JustService.shared.checkIfUserRespected(just: just) {
                didRespect in
                guard didRespect == true else { return }
                self.justs[index].didRespect = true
            }
        }
    }
    
    func fetchUser(uid: String) {
        UserService.shared.fetchUser(uid: uid) { user in
            self.user = user
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
    
    func presentLogin() {
        let storyboard = UIStoryboard(name: "SignUp", bundle: nil)
        UserDefaults.standard.set(false, forKey: "isUserLoggedIn")
        UserDefaults.standard.set("", forKey: "uid")
        UserDefaults.standard.synchronize()
        let loginVC = storyboard.instantiateViewController(identifier: "LoginViewController") as! LoginViewController
        loginVC.modalPresentationStyle = .fullScreen
        self.present(loginVC, animated: true) {
        }
        
    }
    
    func loadJust(completion: @escaping(Just?) -> ()) {
        
    }
    
    func setupSocialButtons() {
        if isUser == false {
            guard let user = user else { return }
            collectionView.isHidden = true
            
            if user.instagramUsername != "" && user.twitterUsername != "" {
                setupSocialButtons()
            } else if user.instagramUsername != "" && user.twitterUsername == "" {
                setupInstagramButton()
            } else if user.instagramUsername == "" && user.twitterUsername != "" {
                setupTwitterButton()
            }
        }
   
    }
    
    func setupBothSocialButtons() {
        view.addSubview(instagramButton)
        instagramButton.anchor(top: collectionView.topAnchor, left: collectionView.leftAnchor, right: collectionView.rightAnchor, paddingTop: 15, paddingLeft: 20, paddingRight: 20)
        view.addSubview(twitterButton)
        twitterButton.anchor(top: instagramButton.bottomAnchor, left: collectionView.leftAnchor, right: collectionView.rightAnchor, paddingTop: 10, paddingLeft: 20, paddingRight: 20)
    }
    
    func setupInstagramButton() {
        view.addSubview(instagramButton)
        instagramButton.anchor(top: collectionView.topAnchor, left: collectionView.leftAnchor, right: collectionView.rightAnchor, paddingTop: 15, paddingLeft: 20, paddingRight: 20)
        
    }
    
    func setupTwitterButton() {
        view.addSubview(twitterButton)
        twitterButton.anchor(top: collectionView.topAnchor, left: collectionView.leftAnchor, right: collectionView.rightAnchor, paddingTop: 15, paddingLeft: 20, paddingRight: 20)
    }
    
    func addObservers() {
            NotificationCenter.default.addObserver(self, selector: #selector(refetchCurrentUser), name: NSNotification.Name.init("refetchCurrentUser"), object: nil)
        
    }
    
    @objc func refetchCurrentUser() {
        print("refetchCurrentUser called")
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
        
        if let cachedJust = self.cache.object(forKey: itemNumber) {
            cell.just = cachedJust
            print("we have cachedJust")
        } else {
            print("we do not have cachedJust")
            cell.just = justs[indexPath.row]
            self.cache.setObject(justs[indexPath.row], forKey: itemNumber)
        }
        cell.tag = indexPath.row
        
        if justs[indexPath.row].uid == currentUser.uid {
            cell.setupRespectButton()
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
        //        let alert = self.setupSettings()
//        self.present(alert, animated: true, completion: nil)
        
    }
    
    func handleBackTapped(_ header: ProfileHeader) {
//        let transition:CATransition = CATransition()
//        transition.duration = 0.5
//        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
//        transition.type = CATransitionType.push
//        transition.subtype = .fromRight
//        self.navigationController?.view.layer.add(transition, forKey: kCATransition)
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func removeCell(cell: NetworkJustCell) {
        let i = cell.tag
        justs.remove(at: i)
        collectionView.reloadData()
    }
    
    @objc func instagramButtonTapped() {
        guard let user = user, let instagramUsername = user.instagramUsername else { return }
        let appURL = URL(string: "instagram://user?username=\(instagramUsername)")!
                let application = UIApplication.shared
                
                if application.canOpenURL(appURL)
                {
                    application.open(appURL)
                }
                else
                {
                    let webURL = URL(string: "https://instagram.com/\(instagramUsername)")!
                    application.open(webURL)
                }
        
    }
    
    @objc func twitterButtonTapped() {
        guard let user = user, let twitterUsername = user.twitterUsername else { return }
        let appURL = URL(string: "twitter://user?screen_name=\(twitterUsername)")!
                let application = UIApplication.shared
                
                if application.canOpenURL(appURL)
                {
                    application.open(appURL)
                }
                else
                {
                    let webURL = URL(string: "https://twitter.com/\(twitterUsername)")!
                    application.open(webURL)
                }
    }
    
    // MARK: - Long Press Alert
    
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
                print("we have a shared array")
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
            return CGSize(width: view.frame.width, height: 420)
        }
        
        if let user = user {
            if user.instagramUsername != "" {
                return CGSize(width: view.frame.width, height: 420)
            } else {
                print("returned 300")
                return CGSize(width: view.frame.width, height: 300)
            }
        }
        return CGSize(width: view.frame.width, height: 420)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: view.frame.width, height: 120)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20.0, left: 1.0, bottom: 1.0, right: 1.0)
    }
}

// MARK: NetworkJustCellDelegate

extension CurrentUserController: NetworkJustCellDelegate {
    func respectCountTapped(cell: NetworkJustCell) {
        guard let just = cell.just else { return }
        let controller = RespectedByViewController(just: just, currentUser: currentUser)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func didLongPress(cell: NetworkJustCell) {
        guard let just = cell.just else { return }
        
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




