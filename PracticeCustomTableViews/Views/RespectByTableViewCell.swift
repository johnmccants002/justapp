//
//  RespectByTableViewCell.swift
//  PracticeCustomTableViews
//
//  Created by John McCants on 5/14/21.
//

import UIKit

class RespectByTableViewCell: UITableViewCell {

    @IBOutlet weak var usernameButton: UIButton!
    var delegate : RespectCellDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    @IBAction func usernameButtonTapped(_ sender: UIButton) {
        self.delegate?.usernameButtonTapped(cell: self)
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}

protocol RespectCellDelegate {
    func usernameButtonTapped(cell: RespectByTableViewCell)
}
