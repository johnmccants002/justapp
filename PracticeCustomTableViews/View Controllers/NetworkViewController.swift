//
//  NetworkViewController.swift
//  PracticeCustomTableViews
//
//  Created by John McCants on 5/7/21.
//

import UIKit

class NetworkViewController: UIViewController {

    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var networkTableView: UITableView!
    var selectedCellInt : Int?
    var selectedIndexPath : IndexPath?
    var delegate : UITableViewDelegate?
    var tableViewHeight: CGFloat = 0
    var dummyData = DummyData()
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        tableViewHeightConstraint.constant = networkTableView.contentSize.height
    }
    
    func updateViews() {
        self.delegate = self
        self.loadingIndicator.isHidden = true
        self.networkTableView.isUserInteractionEnabled = true
        if dummyData.requestsArray.isEmpty {
            self.networkTableView.isHidden = true
        }
    }
    
    func delayedReloadData() {
        let _ : Timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.performCode), userInfo: nil, repeats: false)
    }
    
    @objc func performCode() {
        self.networkTableView.reloadData()
        self.updateViews()
    }

}

extension NetworkViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dummyData.requestsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "networkCell") as! RequestsTableViewCell
        cell.delegate = self
        cell.requestLabel.text = "\(dummyData.requestsArray[indexPath.row]) wants to join your network."
        cell.tag = indexPath.row
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.estimatedRowHeight
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        print(cell.frame.size.height, self.tableViewHeight)
        self.tableViewHeight += cell.frame.size.height
        self.tableViewHeightConstraint.constant = self.tableViewHeight
    }
     
}

extension NetworkViewController: NetworkCellDelegate {
    func acceptTapped(cell: RequestsTableViewCell) {
        dummyData.requestsArray.remove(at: cell.tag)
        networkTableView.deleteRows(at: [NSIndexPath(row: cell.tag, section: 0) as IndexPath], with: .automatic)
        print(cell.tag)
        self.networkTableView.isUserInteractionEnabled = false
        self.tableViewHeight -= cell.frame.size.height
        self.tableViewHeightConstraint.constant = self.tableViewHeight
        self.loadingIndicator.isHidden = false
        self.loadingIndicator.startAnimating()
        self.delayedReloadData()
    }
    
    func denyTapped(cell: RequestsTableViewCell) {
        dummyData.requestsArray.remove(at: cell.tag)
        networkTableView.deleteRows(at: [NSIndexPath(row: cell.tag, section: 0) as IndexPath], with: .automatic)
        self.tableViewHeight -= cell.frame.size.height
        self.tableViewHeightConstraint.constant = self.tableViewHeight
        self.networkTableView.isUserInteractionEnabled = false
        self.loadingIndicator.isHidden = false
        self.loadingIndicator.startAnimating()
        self.delayedReloadData()
    }
  
}
