//
//  ResultsTableViewController.swift
//  PracticeCustomTableViews
//
//  Created by John McCants on 5/18/21.
//

import UIKit

class ResultsTableViewController: UITableViewController {

    var dummyData = DummyData()
    
    static let tableViewCellIdentifier = "cellID"
    private static let nibName = "TableCell"
    var searchString : String?
    var realUsername : Bool?
    var resultTuple : (String, Bool)?
    var searchDelegate : UISearchControllerDelegate?
    var searchController : UISearchController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let nib = UINib(nibName: ResultsTableViewController.nibName, bundle: nil)
        
        tableView.register(nib, forCellReuseIdentifier: "cellID")
        self.tableView.separatorStyle = .none
        
    }
    
    func joinAlert() -> UIAlertController {
        guard let searchDelegate = searchDelegate, let searchController = searchController else {return UIAlertController()}
        let joinAlert = UIAlertController(title: "Request to join network has been sent", message: nil, preferredStyle: .alert)
        let joinAction = UIAlertAction(title: "Ok", style: .default) { joinAction in
            self.dismiss(animated: true) {
                searchDelegate.willDismissSearchController?(searchController)
            }
        }
        joinAlert.addAction(joinAction)
        return joinAlert
        
    }
    

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellID", for: indexPath) as! ResultTableViewCell
        cell.delegate = self
        cell.userImage.setRounded()
        
        guard let resultTuple = resultTuple else {return cell}
        cell.usernameLabel.text = resultTuple.0
        if resultTuple.1 == false {
            cell.joinNetwork.isHidden = true
        } else if resultTuple.1 == true {
            cell.joinNetwork.isHidden = false
        }
        

        // Configure the cell...

        return cell
    }

}

extension ResultsTableViewController: ResultTableViewCellDelegate {
    func didPressJoinNetwork(cell: ResultTableViewCell) {
        self.present(joinAlert(), animated: true, completion: nil)
    }
    
}


