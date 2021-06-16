//
//  RespectedByViewController.swift
//  PracticeCustomTableViews
//
//  Created by John McCants on 5/14/21.
//

import UIKit

class RespectedByViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var delegate : UITableViewDelegate?
    var dummyData = DummyData()
    override func viewDidLoad() {
        super.viewDidLoad()
    }

}

extension RespectedByViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dummyData.respectedArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "respectCell", for: indexPath) as? RespectByTableViewCell {
            cell.delegate = self
            let username = "\(dummyData.respectedArray[indexPath.row])"
            cell.usernameButton.setTitle(username, for: .normal)
            return cell
        }
        
        return UITableViewCell()
    }
}

extension RespectedByViewController: RespectCellDelegate {
    func usernameButtonTapped(cell: RespectByTableViewCell) {
        self.performSegue(withIdentifier: "respectProfile", sender: self)
    }   
}
