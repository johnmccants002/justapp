//
//  SharedNetworkCell.swift
//  PracticeCustomTableViews
//
//  Created by John McCants on 11/8/21.
//

import UIKit

class SharedNetworkCell: UICollectionViewCell {

    var user: User?
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userButton: UIButton!
    
    var delegate: SharedNetworkCellDelegate?
    
    var currentUser: User?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateViews()
        self.layer.addBorder(edge: .bottom, color: .systemGray4, thickness: 0.25)
    }
    
    func updateViews() {
        userImage.setRounded()
        userImage.clipsToBounds = true
        self.userButton.setTitleColor(.label, for: .normal)
        guard let user = user else { return }
        self.userButton.setTitle("\(user.firstName) \(user.lastName)", for: .normal)
        
        if let url = user.profileImageUrl {
            self.userImage.sd_setImage(with: url, completed: nil)
        }
        
    }

    @IBAction func userButtonTapped(_ sender: UIButton) {
        delegate?.userButtonTapped(cell: self)
    }
}


protocol SharedNetworkCellDelegate {
    func userButtonTapped(cell: SharedNetworkCell)
    
}
