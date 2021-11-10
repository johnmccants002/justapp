//
//  ResultsTableViewController.swift
//  PracticeCustomTableViews
//
//  Created by John McCants on 5/18/21.
//

import UIKit

class ResultsTableViewController: UITableViewController {

    // MARK: - Properties

    var currentUser : User?
    var toUser: User? {
        didSet {
            self.checkUser()
        }
    }
    
    static let tableViewCellIdentifier = "cellID"
    private static let nibName = "TableCell"
    var searchString : String? 
    var searchDelegate : UISearchControllerDelegate?
    var searchController : UISearchController?
    var inNetwork: Bool? {
        didSet {
            self.tableView.reloadData()
        }
    }
    var status: String? {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    var userExists : Bool? {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    
    // MARK: - Lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let nib = UINib(nibName: ResultsTableViewController.nibName, bundle: nil)
        
        tableView.register(nib, forCellReuseIdentifier: "cellID")
        self.tableView.separatorStyle = .none
        
    }
    
    
    // MARK: - Selectors
    
    @objc func searchButtonPressed() {
       
    }
    
    // MARK: - Helper Functions
    
    func checkUser() {
        guard let toUser = toUser, let currentUser = currentUser else { return }
        self.tableView.reloadData()
    }
    
    func joinAlert() -> UIAlertController {
        guard let searchDelegate = searchDelegate, let searchController = searchController else {return UIAlertController()}
        let joinAlert = UIAlertController(title: "Invite to join network sent", message: nil, preferredStyle: .alert)
        let joinAction = UIAlertAction(title: "Ok", style: .default) { joinAction in
            self.toUser = nil
            self.dismiss(animated: true) {
                searchDelegate.willDismissSearchController?(searchController)
            }
        }
        joinAlert.addAction(joinAction)
        return joinAlert
    }
    

    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellID", for: indexPath) as! ResultTableViewCell
        
        cell.delegate = self
        cell.selectionStyle = .none
        if let status = status {
            cell.status = status
        }
        
        if let userExists = userExists {
            cell.userExists = userExists
        }
        
        guard let currentUser = currentUser else { return UITableViewCell() }
        
        cell.currentUser = currentUser
        if let toUser = toUser {
            cell.user = toUser
                if currentUser.uid == toUser.uid {
                    print("CurrentUser Uid == toUser Uid")
                    cell.inviteButton.isHidden = true
                    cell.userImage.setRounded()
                    return cell
                }
                cell.userImage.setRounded()
                return cell
        
        }
        
        return cell

    }

}

// MARK: - ResultTableViewCellDelegate

extension ResultsTableViewController: ResultTableViewCellDelegate {
    func inviteToNetwork(cell: ResultTableViewCell) {
        guard let currentUser = currentUser else { return }
        guard let toUserUid = cell.user?.uid else { return }
        NetworkService.shared.inviteUserToNetwork(toUserUid: toUserUid, fromUser: currentUser) {
            guard let token = cell.token else { return }
            PushNotificationSender.shared.sendPushNotification(to: token, title: "New Invite", body: "\(currentUser.firstName) \(currentUser.lastName) invited you to join their network.", id: toUserUid)
            
        }
        self.present(joinAlert(), animated: true, completion: nil)
    }
    
}


