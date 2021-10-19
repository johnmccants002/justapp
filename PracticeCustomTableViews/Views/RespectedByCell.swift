//
//  RespectedByCell.swift
//  PracticeCustomTableViews
//
//  Created by John McCants on 10/19/21.
//

import UIKit

class RespectedByCell: UICollectionViewCell {

    var user: User? {
        didSet {
            configure()
        }
    }
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userButton: UIButton!
    var delegate : RespectedByCellDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func userButtonTapped(_ sender: UIButton) {
        self.delegate?.usernameButtonTapped(cell: self)
    }
    
    func configure() {
        guard let user = user else { return }
        self.profileImageView.clipsToBounds = true
        self.profileImageView.setRounded()
        self.userButton.setTitleColor(.label, for: .normal)
        userButton.setTitle("\(user.firstName) \(user.lastName)", for: .normal)
        if let url = user.profileImageUrl {
            self.profileImageView.sd_setImage(with: url, completed: nil)
        } else {
            self.profileImageView.image = UIImage(named: "blank")
        }
        
    }

}

protocol RespectedByCellDelegate {
    func usernameButtonTapped(cell: RespectedByCell)
}
