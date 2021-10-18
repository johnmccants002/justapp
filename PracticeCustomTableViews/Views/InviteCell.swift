//
//  ActivityInviteCell.swift
//  PracticeCustomTableViews
//
//  Created by John McCants on 8/19/21.
//

import UIKit

class InviteCell: UICollectionViewCell {

    var user: User? {
        didSet {
            configure()
        }
    }
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var captionLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    @IBAction func acceptButtonTapped(_ sender: UIButton) {
    }
    
    @IBAction func denyButtonTapped(_ sender: UIButton) {
    }
    
    func configure() {
        guard let user = user else { return }
        captionLabel.text = "\(user.firstName) \(user.lastName) invited you to their network"
        profileImageView.sd_setImage(with: user.profileImageUrl, completed: nil)
        
    }
    
}

