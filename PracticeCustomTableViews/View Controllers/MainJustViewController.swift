//
//  MainViewController.swift
//  PracticeCustomTableViews
//
//  Created by John McCants on 5/18/21.
//

import UIKit

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

public var searchResults = ["John", "Joe", "Jenny"]

class MainJustViewController: UIViewController, UINavigationControllerDelegate, UINavigationBarDelegate, UIGestureRecognizerDelegate {


    @IBOutlet weak var myImageView: UIImageView!
    @IBOutlet weak var myNetworkView: UIView!
    @IBOutlet weak var friendsTableView: UITableView!
    private var searchController: UISearchController!
    private var resultsTableController: ResultsTableViewController!
    private var restoredState = SearchControllerRestorableState()
    var user : User?
    var searchResult : String?
    var delegate : UINavigationControllerDelegate?
    var delegate2 : UINavigationBarDelegate?
    var detail: String?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTapCellGesture()
        updateViews()
        setUpViewGestureRecognizer()
            resultsTableController = ResultsTableViewController()

            resultsTableController.tableView.delegate = self
            
            searchController = UISearchController(searchResultsController: resultsTableController)
            searchController.searchResultsUpdater = self
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
        self.navigationItem.title = "Just App"
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
    
    func updateViews() {
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
    }
    
    @objc func myNetworkTapped() {
        self.performSegue(withIdentifier: "showNetwork", sender: self)
    }
    
    @IBAction func profileButtonTapped(_ sender: UIBarButtonItem) {
        print("profile button tapped")
        let obj = self.storyboard?.instantiateViewController(withIdentifier: "ProfileViewController")as! ProfileViewController
        obj.user = self.user
        let transition:CATransition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        transition.type = .push
        transition.subtype = .fromLeft
        self.navigationController?.view.layer.add(transition, forKey: kCATransition)
        

        self.navigationController?.pushViewController(obj, animated: true)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showNetwork" {
            guard let detail = detail else {return}
            print("this is \(detail)")
            let destinationVC = segue.destination as! PracticeTableViewController
            destinationVC.title = detail
            
        }
    }
}

extension MainJustViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "friends", for: indexPath) as! NetworksTableViewCell
        
        cell.friendsImageView.image = UIImage(named: "dave")
        cell.friendsImageView.setRounded()
        cell.friendsNameLabel.text = "Dave Portnoy's Network"
        cell.updateViews()
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
        }
    }
    }
    
}

extension MainJustViewController: NetworkTableViewCellDelegate {
    func didTapCell(cell: NetworksTableViewCell) {
        self.performSegue(withIdentifier: "showNetwork", sender: self)
    }
    
    
}

extension MainJustViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let resultsController = searchController.searchResultsController as? ResultsTableViewController {
            guard let searchString = searchController.searchBar.text else {return}
            resultsController.resultTuple = findMatches(searchString: searchString)
            resultsController.tableView.reloadData()
            resultsController.searchController = self.searchController
            resultsController.searchDelegate = self
        }
        
    }
    
    private func findMatches(searchString: String) -> (String, Bool) {
        if searchResults.contains(searchString) {
            return (searchString, true)
           
        } else {
            let noSearchResult = "No username \(searchString)"
            return (noSearchResult, false)
            
        }
    
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

extension MainJustViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
    }
    
}

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

    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
        debugPrint("UISearchControllerDelegate invoked method: \(#function).")
    }
    
}

extension UIView {
    func setRoundedView() {
        self.layer.cornerRadius = (self.frame.width / 25)
        self.layer.masksToBounds = true
        self.contentMode = .scaleAspectFill
    }
}



