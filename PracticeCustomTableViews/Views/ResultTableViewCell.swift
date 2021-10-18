//
//  ResultTableViewCell.swift
//  PracticeCustomTableViews
//
//  Created by John McCants on 5/20/21.
//

import UIKit
import SDWebImage

class ResultTableViewCell: UITableViewCell {

    @IBOutlet weak var inviteButton: UIButton!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    var inNetwork: Bool? {
        didSet {
            checkUserNetwork()
        }
    }
    var delegate : ResultTableViewCellDelegate?
    var user : User? {
        didSet {
            configure()
            fetchUserToken()
        }
    }
    var token : String?
    var userExists: Bool? {
        didSet {
            checkUserExists()
        }
    }
    
    var currentUser: User? 
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func inviteTapped(_ sender: UIButton) {
        delegate?.inviteToNetwork(cell: self)
    }
    
    func configure() {
        guard let user = user else {
            return }
        userImage.sd_setImage(with: user.profileImageUrl)
        usernameLabel.text = user.username
    }
    
    func checkUserExists() {
        guard let userExists = userExists else { return }
        if userExists == false {
            usernameLabel.text = "Username does not exist"
            usernameLabel.centerX(inView: self)
            inviteButton.isHidden = true
            userImage.isHidden = true
        } else if userExists == true {
            inviteButton.isHidden = false
            userImage.isHidden = false
        }
    }
    
    func checkUserNetwork() {
        guard let inNetwork = inNetwork else { return }
        if inNetwork == true {
            inviteButton.setTitle("In Network", for: .normal)
            inviteButton.isEnabled = false
        } else {
            inviteButton.setTitle("Invite", for: .normal)
            inviteButton.isEnabled = true
        }
        
    }
    
    func fetchUserToken() {
        guard let user = user else { return }
        UserService.shared.fetchUserToken(uid: user.uid) { token in
            self.token = token
        }
    }
    

}

protocol ResultTableViewCellDelegate {
    func inviteToNetwork(cell: ResultTableViewCell)
}
