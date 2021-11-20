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
    var status: String? {
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
        overrideUserInterfaceStyle = .light
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
        guard let status = status else { return }
        print("This is the current status \(status)")
        switch status {
        case "Already in the Network":
            inviteButton.setTitle("In Network", for: .normal)
            inviteButton.isHidden = false
            inviteButton.isEnabled = false
        case "Not in Network":
            inviteButton.setTitle("Invite", for: .normal)
            inviteButton.isHidden = false
            inviteButton.isEnabled = true
        case "Invite Exists":
            inviteButton.setTitle("Invited", for: .normal)
            inviteButton.isHidden = false
            inviteButton.isEnabled = false
            
        default:
            break
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
