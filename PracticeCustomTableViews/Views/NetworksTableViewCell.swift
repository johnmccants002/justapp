//
//  NetworksTableViewCell.swift
//  PracticeCustomTableViews
//
//  Created by John McCants on 5/18/21.
//

import UIKit


class NetworksTableViewCell: UITableViewCell {

    @IBOutlet weak var friendsNameLabel: UILabel!
    @IBOutlet weak var checkedImageView: UIImageView!
    @IBOutlet weak var friendsImageView: UIImageView!
    var delegate : NetworkTableViewCellDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func updateViews() {
        
    }
    
    func cellTapped(sender: UITapGestureRecognizer) {
        if sender.state == .recognized {
        delegate?.didTapCell(cell: self)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}

protocol NetworkTableViewCellDelegate {
    func didTapCell(cell: NetworksTableViewCell)
}
