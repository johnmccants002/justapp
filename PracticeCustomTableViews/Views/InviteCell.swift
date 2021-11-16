//
//  InviteCell.swift
//  PracticeCustomTableViews
//
//  Created by John McCants on 8/19/21.
//

import UIKit

class InviteCell: UICollectionViewCell {

    var user: User? {
        didSet {
            print("User set")
            configure()
            fetchToken()
        }
    }
    
    var deleteThisCell: (() -> Void)?
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var captionLabel: UILabel!
    weak var delegate : InviteCellDelegate?
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var denyButton: UIButton!
    var token: String?
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
    }
    @IBAction func acceptButtonTapped(_ sender: UIButton) {
        delegate?.acceptButtonTapped(cell: self)
    }
    
    @IBAction func denyButtonTapped(_ sender: UIButton) {
        delegate?.denyButtonTapped(cell: self)
    }
    
    func fetchToken() {
        guard let user = user else { return }
        UserService.shared.fetchUserToken(uid: user.uid) { token in
            self.token = token
        }
    }
    
    
    
    func configure() {
        setupButtons()
        guard let user = user else { return }
        captionLabel.text = "\(user.firstName) \(user.lastName) invited you to their network"
        
        if let url = user.profileImageUrl {
            profileImageView.sd_setImage(with: url, completed: nil)
        } else {
            profileImageView.image = UIImage(named: "blank")
        }
        self.layer.addBorder(edge: .bottom, color: .systemGray4, thickness: 0.25)
        
    }
    
    func setupButtons() {
        acceptButton.layer.borderWidth = 1.5
        acceptButton.layer.borderColor = UIColor.blue.cgColor
        acceptButton.setTitleColor(UIColor.blue, for: .normal)
        acceptButton.layer.cornerRadius = acceptButton.viewHeight / 2
        denyButton.layer.borderWidth = 1.5
        denyButton.layer.borderColor = UIColor.black.cgColor
        denyButton.setTitleColor(UIColor.black, for: .normal)
        denyButton.layer.cornerRadius = denyButton.viewHeight / 2
        
        profileImageView.layer.cornerRadius = profileImageView.viewHeight / 2
        profileImageView.contentMode = .scaleAspectFit
        profileImageView.clipsToBounds = true
        profileImageView.backgroundColor = .lightGray
        profileImageView.layer.borderColor = UIColor.white.cgColor
        profileImageView.layer.borderWidth = 4
        
    }
    
    
}

protocol InviteCellDelegate: AnyObject {
    func acceptButtonTapped(cell: InviteCell)
    
    func denyButtonTapped(cell: InviteCell)
}

