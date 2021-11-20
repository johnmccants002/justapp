//
//  NetworkTableViewCell.swift
//  PracticeCustomTableViews
//
//  Created by John McCants on 5/7/21.
//

import UIKit

class RequestsTableViewCell: UITableViewCell {

    @IBOutlet weak var requestLabel: UILabel!
    
    var delegate : NetworkCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        overrideUserInterfaceStyle = .light
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    @IBAction func acceptButtonTapped(_ sender: UIButton) {
        self.delegate?.acceptTapped(cell: self)      
    }
    
    @IBAction func denyButtonTapped(_ sender: UIButton) {
        self.delegate?.denyTapped(cell: self)
    print("deny button tapped")
    }
    
}

protocol NetworkCellDelegate {
    func acceptTapped(cell: RequestsTableViewCell)
    
    func denyTapped(cell: RequestsTableViewCell)

}
