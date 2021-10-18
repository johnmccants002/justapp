//
//  RespectedByViewController.swift
//  PracticeCustomTableViews
//
//  Created by John McCants on 5/14/21.
//

import UIKit

class RespectedByViewController: UIViewController {

    // MARK: - Properties
    
    @IBOutlet weak var tableView: UITableView!
    var delegate : UITableViewDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()
    }

}

// MARK: - UITableViewDelegate UITableViewDataSource

extension RespectedByViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "respectCell", for: indexPath) as? RespectByTableViewCell {
            cell.delegate = self

            return cell
        }
        
        return UITableViewCell()
    }
}

// MARK: - RespectCellDelegate

extension RespectedByViewController: RespectCellDelegate {
    func usernameButtonTapped(cell: RespectByTableViewCell) {
        self.performSegue(withIdentifier: "respectProfile", sender: self)
    }   
}
