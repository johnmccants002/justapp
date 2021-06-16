//
//  ResultTableViewCell.swift
//  PracticeCustomTableViews
//
//  Created by John McCants on 5/20/21.
//

import UIKit

class ResultTableViewCell: UITableViewCell {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var joinNetwork: UIButton!
    @IBOutlet weak var usernameLabel: UILabel!
    var delegate : ResultTableViewCellDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func joinNetworkTapped(_ sender: UIButton) {
        delegate?.didPressJoinNetwork(cell: self)
    }
    

}

protocol ResultTableViewCellDelegate {
    func didPressJoinNetwork(cell: ResultTableViewCell)
}
