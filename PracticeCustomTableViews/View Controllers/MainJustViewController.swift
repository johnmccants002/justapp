//
//  MainViewController.swift
//  PracticeCustomTableViews
//
//  Created by John McCants on 5/18/21.
//

import UIKit
import Firebase
import UserNotifications

/// State restoration values.
private enum RestorationKeys: String {
    case viewControllerTitle
    case searchControllerIsActive
    case searchBarText
    case searchBarIsFirstResponder
}


private struct SearchControllerRestorableState {
    var wasActive = false
    var wasFirstResponder = false
}

class MainJustViewController: UIViewController, UINavigationControllerDelegate, UINavigationBarDelegate, UIGestureRecognizerDelegate {

    // MARK: - Properties

    var pushManager : PushNotificationManager? {
        didSet {
            self.registerForPushNotifications()
            print(Messaging.messaging().fcmToken)
        }
    }
    @IBOutlet weak var respectLabel: UILabel!
    @IBOutlet weak var myImageView: UIImageView!
    @IBOutlet weak var myNetworkView: UIView!
    @IBOutlet weak var friendsTableView: UITableView!
    private var searchController: UISearchController!
    private var resultsTableController: ResultsTableViewController!
    @IBOutlet weak var invitesLabel: UILabel!
    var networkUsers: [User]?
//        didSet {
//            friendsTableView.reloadData()
//        }
   
    
    
    var networks: [Network]? {
        didSet {
            friendsTableView.reloadData()
            print("Networks set")
        }
    }
    
    private var restoredState = SearchControllerRestorableState()
    var currentUser : User? {
        didSet {
            self.fetchUserNetworks()
            self.checkedUncheckedActivity()
            print("This is Current User UID: \(currentUser?.uid)")
           
        }
    }
    var searchResult : String?
    var delegate : UINavigationControllerDelegate?
    var delegate2 : UINavigationBarDelegate?
    var detail: String?
    var currentUserNetworkId: String?
    var invitedUsers: [User]?
    let cellSpacingHeight: CGFloat = 10
    var networkIdArray: [String]?
    
    // MARK: - Lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchController()
        setupInvitesLabel()
        setupRespectsLabel()
        setUpViewGestureRecognizer()
        fetchUser()
        getNotificationSettings()
        addObservers()

        
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        setUpViewGestureRecognizer()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // needed to clear the text in the back navigation:
        self.navigationItem.title = " "
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("Main Just View Will Appear")
        authenticateUserAndConfigureUI()
        updateViews()
        setCurrentNetworkImage()
        self.navigationItem.title = "Just App"
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.barStyle = .default
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Restore the searchController's active state.
        if restoredState.wasActive {
            searchController.isActive = restoredState.wasActive
            restoredState.wasActive = false

            if restoredState.wasFirstResponder {
                searchController.searchBar.becomeFirstResponder()
                restoredState.wasFirstResponder = false
            }
        }
    }
    
    // MARK: Firebase Functions
    
    func fetchUserNetworks() {
        guard var currentUser = currentUser else { return }
        NetworkService.shared.fetchCurrentUserNetworks(currentUser: currentUser) { users in
            self.networkUsers = users
            print("These are your networks \(users)")
            NetworkService.shared.checkedUncheckedNetworks(users: users, currentUser: currentUser) { networks in
                self.networks = networks
                print("These are the networks we got \(networks)")
            }
       
            print("Fetch User Networks called")
        }
    }
    
    func fetchUser() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        UserService.shared.fetchUser(uid: uid) { user in
            self.currentUser = user
            self.currentUserNetworkId = user.networkId
            let pushManager = PushNotificationManager(userID: user.uid)
            self.pushManager = pushManager
            print("This is the current user networkId \(user.networkId) and the uid: \(user.uid)")
            if let url = user.profileImageUrl {
                self.myImageView.sd_setImage(with: url, completed: nil) }
         else {
            self.myImageView.image = UIImage(named: "blank")
        }
        }
        
    }
    
    func setCurrentNetworkImage() {
        guard let currentUser = currentUser else { return }
        UserService.shared.fetchProfileImage(uid: currentUser.uid) { imageUrl in
            self.myImageView.sd_setImage(with: imageUrl) { image, error, cache, url in
                if let error = error {
                    self.myImageView.image = UIImage(named: "blank")
                }
            }
        }
        
    }
    
    func fetchUserToken() {
        guard let currentUser = currentUser else { return }
        
        UserService.shared.fetchUserToken(uid: currentUser.uid) { token in
            print(token)
        }
    }
    
    func setRootController() {
        self.window?.rootViewController = self
        self.window?.makeKeyAndVisible()
    }
    
    func setupInvitesLabel() {
        self.invitesLabel.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleInvitesTapped))
        self.invitesLabel.addGestureRecognizer(tap)
        self.invitesLabel.font = UIFont.systemFont(ofSize: 14)
        self.invitesLabel.text = "Invites"
    }
    
    func setupRespectsLabel() {
        self.respectLabel.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleRespectsTapped))
        self.respectLabel.addGestureRecognizer(tap)
        self.respectLabel.font = UIFont.systemFont(ofSize: 14)
        self.respectLabel.text = "Respects"
    }
    
    func checkedUncheckedActivity() {
        guard let uid = currentUser?.uid else { return }
        UserService.shared.fetchCheckedRespect(uid: uid) { respectString in
            self.respectLabel.text = respectString
            if respectString == "New Respects!" {
                self.respectLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 14)
            } else {
                self.respectLabel.font = UIFont(name: "HelveticaNeue", size: 14)
            }
            
        }
        
        UserService.shared.fetchCheckedInvites(uid: uid) { invitesString in
            self.invitesLabel.text = invitesString
            if invitesString == "New Invites!" {
                self.invitesLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 14)
            } else {
                self.invitesLabel.font = UIFont(name: "HelveticaNeue", size: 14)
            }
            
        }
    }
    
    func getNotificationSettings() {
      UNUserNotificationCenter.current().getNotificationSettings { settings in
        print("Notification settings: \(settings)")
        guard settings.authorizationStatus == .authorized else { return }
        DispatchQueue.main.async {
          UIApplication.shared.registerForRemoteNotifications()
        }
      }
    }
    
    func registerForPushNotifications() {
        guard let pushManager = pushManager else { return }
        pushManager.registerForPushNotifications()
    }
    
    func logoutButtonTapped() {
        AuthService.shared.logoutUser()
            self.presentLogin()
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
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(refetchUser), name: NSNotification.Name.init(rawValue: "refetchUser"), object: nil)
    }
    
    @objc func refetchUser() {
        fetchUser()
    }
    
    
    
    

    // MARK: - Selectors
        
    @objc func handleInvitesTapped() {
        guard let user = self.currentUser else { return }
        UserService.shared.checkUncheckInvites(string: "check", uid: user.uid)
        self.invitesLabel.text = "Invites"
        self.invitesLabel.font = UIFont(name: "HelveticaNeue", size: 14)
        let controller = ActivityController(currentUser: user)
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true) {
        }
    }
    
    @objc func handleRespectsTapped() {
        guard let user = self.currentUser else { return }
        UserService.shared.checkUncheckRespects(string: "check", uid: user.uid)
        self.respectLabel.text = "Respects"
        self.respectLabel.font = UIFont(name: "HelveticaNeue", size: 14)
        let controller = ActivityRespectController(currentUser: user)
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true)
    }
    
    @objc func myNetworkTapped() {
        guard let currentUser = currentUser else { return }
        let controller = NetworkJustsController(currentUser: currentUser, titleText: "My Network", networkId: currentUser.networkId)
        controller.networkId = currentUser.networkId
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func profileButtonTapped(_ sender: UIBarButtonItem) {
        print("profile button tapped")

        guard let currentUser = currentUser else { return }
        let controller = CurrentUserController(currentUser: currentUser, isUser: false)
        controller.currentUser = currentUser
        
        let transition:CATransition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        transition.type = .push
        transition.subtype = .fromLeft
        self.navigationController?.view.layer.add(transition, forKey: kCATransition)

        self.navigationController?.pushViewController(controller, animated: true)
    }
    

    
    
    func setupSearchController() {
        
        resultsTableController = ResultsTableViewController()

            resultsTableController.tableView.delegate = self
            
            searchController = UISearchController(searchResultsController: resultsTableController)
            searchController.searchBar.autocapitalizationType = .none
        searchController.searchBar.placeholder = "Search By Username"
        
        if #available(iOS 11.0, *) {
            // For iOS 11 and later, place the search bar in the navigation bar.
            print("11")
            self.navigationItem.searchController = searchController
            
            // Make the search bar always visible.
            self.navigationItem.hidesSearchBarWhenScrolling = false
        } else {
            // For iOS 10 and earlier, place the search controller's search bar in the table view's header.
            print("else is happening")
            self.resultsTableController.tableView.tableHeaderView = searchController.searchBar
        }
        
        searchController.delegate = self
        searchController.dimsBackgroundDuringPresentation = false // The default is true.
        searchController.searchBar.delegate = self // Monitor when the search button is tapped.
        definesPresentationContext = true
    
    }

    
    // MARK: - Helper Functions
    
    func updateViews() {
        self.invitesLabel.text = "Invites"
        self.friendsTableView.delegate = self
        self.friendsTableView.dataSource = self
        self.myNetworkView.layer.backgroundColor = UIColor.systemGray5.cgColor
        myImageView.setRounded()
        self.myNetworkView.layer.borderWidth = 1
        self.myNetworkView.layer.borderColor = UIColor.lightGray.cgColor
        self.myNetworkView.setRoundedView()
        self.myNetworkView.layer.shadowOpacity = 0.5
        self.friendsTableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        self.delegate = self
        self.delegate2 = self
    }
    
    func setUpViewGestureRecognizer() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector (self.myNetworkTapped))
        self.myNetworkView.addGestureRecognizer(tapRecognizer)
        self.detail = "My Network"
        self.myNetworkView.sendSubviewToBack(invitesLabel)
        self.myNetworkView.sendSubviewToBack(respectLabel)
    }
    
    
    func authenticateUserAndConfigureUI() {
            setUpViewGestureRecognizer()
            setupTapCellGesture()
    }
    


    

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            
        if segue.identifier == "newJust" {
        guard let currentUser = self.currentUser else { return }
        let destinationVC = segue.destination as! NewJustViewController
            destinationVC.currentUser = currentUser
            
            if let networks = networks {
                destinationVC.networks = networks
            }
            guard let networkUsers = networkUsers else { return }
            destinationVC.networkIds = setupNetworkIds(networkUsers: networkUsers)
        }
    }

func usernameDoesNotExist(username: String, controller: UITableViewController) -> UIAlertController {
    let alert = UIAlertController(title: "Username not found", message: "\(username) does not exist.", preferredStyle: .alert)
    let action = UIAlertAction(title: "Ok", style: .default) { action in
        controller.dismiss(animated: true, completion: nil)
    }
    alert.addAction(action)
    
    return alert
}

func setupNetworkIds(networkUsers: [User]) -> [String]? {
    var networkIds: [String] = []
    for user in networkUsers {
        networkIds.append(user.networkId)
    }
    if networkIds.count > 0 {
        return networkIds
    } else {
    return nil
    }
}
}


// MARK: - UITableViewDataSource

extension MainJustViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return networks?.count ?? 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return cellSpacingHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "friends", for: indexPath) as! NetworksTableViewCell
        
        
        if let networks = networks {
            cell.user = networks[indexPath.section].user
            cell.network = networks[indexPath.section]
        } else {
            cell.user = networkUsers?[indexPath.section] ?? nil
        }
        
        cell.layer.borderWidth = 1
        cell.layer.shadowOpacity = 0.5
        cell.layer.cornerRadius = self.myNetworkView.layer.cornerRadius
        return cell
    }
    
    func setupTapCellGesture() {
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.cellTapped))
        tapRecognizer.delegate = self
        self.friendsTableView.addGestureRecognizer(tapRecognizer)
    }
    
    @objc func cellTapped(gestureRecognizer: UITapGestureRecognizer) {
        print("cell Tapped")
        if gestureRecognizer.state == .recognized {
            print("gesture began")
        let touchPoint = gestureRecognizer.location(in: self.friendsTableView)
        if let indexPath = friendsTableView.indexPathForRow(at: touchPoint) {
            let cell = friendsTableView.cellForRow(at: indexPath) as! NetworksTableViewCell
            cell.delegate = self
            self.detail = cell.friendsNameLabel.text
            cell.cellTapped(sender: gestureRecognizer)
            if let network = cell.network {
                NetworkService.shared.checkNetwork(network: network)
            }
           
        }
    }
    }
    
}

// MARK: - NetowrkTableViewCellDelegate

extension MainJustViewController: NetworkTableViewCellDelegate {
    func imageTapped(cell: NetworksTableViewCell) {
        
    }
    
    func didTapCell(cell: NetworksTableViewCell) {
        guard let user = cell.user else { return }
        guard let currentUser = currentUser else { return }
        let titleText = "\(user.firstName) \(user.lastName)'s Network"
        let controller = NetworkJustsController(currentUser: currentUser, titleText: titleText, networkId: user.networkId)
        cell.network?.checked = 0
        navigationController?.pushViewController(controller, animated: true)
        
    }
    
    
}

// MARK: - UIStateRestoration

extension MainJustViewController {
    override func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)
        
        // Encode the view state so it can be restored later.
        
        // Encode the title.
        coder.encode(navigationItem.title!, forKey: RestorationKeys.viewControllerTitle.rawValue)

        // Encode the search controller's active state.
        coder.encode(searchController.isActive, forKey: RestorationKeys.searchControllerIsActive.rawValue)
        
        // Encode the first responser status.
        coder.encode(searchController.searchBar.isFirstResponder, forKey: RestorationKeys.searchBarIsFirstResponder.rawValue)
        
        // Encode the search bar text.
        coder.encode(searchController.searchBar.text, forKey: RestorationKeys.searchBarText.rawValue)
    }
    
    override func decodeRestorableState(with coder: NSCoder) {
        super.decodeRestorableState(with: coder)
        
        // Restore the title.
        guard let decodedTitle = coder.decodeObject(forKey: RestorationKeys.viewControllerTitle.rawValue) as? String else {
            fatalError("A title did not exist. In your app, handle this gracefully.")
        }
        navigationItem.title! = decodedTitle
        
        /** Restore the active state:
            We can't make the searchController active here since it's not part of the view
            hierarchy yet, instead we do it in viewWillAppear.
        */
        restoredState.wasActive = coder.decodeBool(forKey: RestorationKeys.searchControllerIsActive.rawValue)
        
        /** Restore the first responder status:
            Like above, we can't make the searchController first responder here since it's not part of the view
            hierarchy yet, instead we do it in viewWillAppear.
        */
        restoredState.wasFirstResponder = coder.decodeBool(forKey: RestorationKeys.searchBarIsFirstResponder.rawValue)
        
        // Restore the text in the search field.
        searchController.searchBar.text = coder.decodeObject(forKey: RestorationKeys.searchBarText.rawValue) as? String
    }
    
}

// MARK: - UISearchBarDelegate

extension MainJustViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        guard let searchText = searchBar.text else { return }
        if let resultsController = searchController.searchResultsController as? ResultsTableViewController {
            guard let currentUser = currentUser else { return }
            resultsController.tableView.reloadData()
            resultsController.tableView.isHidden = true
            resultsController.currentUser = currentUser
            resultsController.searchController = self.searchController
            resultsController.searchDelegate = self
            
            UserService.shared.searchUsername(username: searchText.lowercased()) { toUser, userExists in
                print("userExists = \(userExists)")
                
                resultsController.userExists = userExists
                
                if userExists == false {
                    resultsController.tableView.isHidden = false
                }
                if let toUser = toUser {
                    print("CheckIfUsersInNetwork called")
                    NetworkService.shared.checkIfUsersInNetwork(networkId: currentUser.networkId, userId: toUser.uid) { string in
                        print("String from Firebase: \(string)")
                        resultsController.status = string
                        resultsController.tableView.isHidden = false
                        resultsController.toUser = toUser
                    }
//                    resultsController.toUser = toUser
                    
                }
//                resultsController.tableView.isHidden = false
                
            }
        }
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        if let resultsController = searchController.searchResultsController as? ResultsTableViewController {
            resultsController.tableView.reloadData()
            resultsController.currentUser = nil
            resultsController.toUser = nil
            resultsController.inNetwork = nil
            
        }
        self.navigationController?.popToViewController(self, animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchController.showsSearchResultsController = false
        if let resultsController = self.searchController.searchResultsController as? ResultsTableViewController {
            resultsController.toUser = nil
            resultsController.userExists = nil
            resultsController.inNetwork = nil
        }
        if searchText.isEmpty {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if let resultsController = self.searchController.searchResultsController as? ResultsTableViewController {
                    resultsController.searchController = self.searchController
                    resultsController.searchDelegate = self
                    resultsController.tableView.reloadData()
                    resultsController.tableView.isHidden = true
                    resultsController.toUser = nil
                    resultsController.userExists = nil
                    resultsController.inNetwork = nil
                }
                searchBar.resignFirstResponder()

            }
        }
    }
    
}

// MARK: - UISearchControllerDelegate

extension MainJustViewController: UISearchControllerDelegate {
    
    func presentSearchController(_ searchController: UISearchController) {
        debugPrint("UISearchControllerDelegate invoked method: \(#function).")
    }
    
    func willPresentSearchController(_ searchController: UISearchController) {
        debugPrint("UISearchControllerDelegate invoked method: \(#function).")
        self.myNetworkView.isHidden = true
        self.friendsTableView.isHidden = true
        
        print("search button clicked")
    }
    
    func didPresentSearchController(_ searchController: UISearchController) {
        debugPrint("UISearchControllerDelegate invoked method: \(#function).")
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        debugPrint("UISearchControllerDelegate invoked method: \(#function).")
        self.myNetworkView.isHidden = false
        self.friendsTableView.isHidden = false
        self.searchController.searchBar.text = ""
        self.setupSearchController()
        

    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
        debugPrint("UISearchControllerDelegate invoked method: \(#function).")
    }
    
}

// MARK: - AppDelegate + SceneDelegat

extension MainJustViewController {
        var appDelegate: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    var sceneDelegate: SceneDelegate? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let delegate = windowScene.delegate as? SceneDelegate else { return nil }
         return delegate
    }

    var window: UIWindow? {
        if #available(iOS 13, *) {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                let delegate = windowScene.delegate as? SceneDelegate, let window = delegate.window else { return nil }
                   return window
        }
        
        guard let delegate = UIApplication.shared.delegate as? AppDelegate, let window = delegate.window else { return nil }
        return window
    }

}






