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
    var checked: Int?
    var user: User? 
    var network: Network? {
        didSet {
            configure()
            checkNetworkActivity()
        }
    }
    var delegate : NetworkTableViewCellDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    
    func configure() {
        guard let user = user else { return }
        setupImageTap()
        friendsNameLabel.text = "\(user.firstName) \(user.lastName)"
        if let url = user.profileImageUrl {
            friendsImageView.sd_setImage(with: url, completed: nil)
        } else {
            friendsImageView.image = UIImage(named: "blank")
        }
        
        friendsImageView.layer.cornerRadius = friendsImageView.viewWidth / 2
    }
    
    func checkNetworkActivity() {
        guard let network = network else { return }
        if network.checked == 1 {
            checkedImageView.isHidden = false
        } else if network.checked == 0 {
            checkedImageView.isHidden = true
        }
    }
    
    func setupImageTap() {
        let tap = UIGestureRecognizer(target: self, action: #selector(imageTapped))
        friendsImageView.addGestureRecognizer(tap)
        friendsImageView.isUserInteractionEnabled = true
        
    }
    
    @objc func imageTapped() {
        delegate?.imageTapped(cell: self)
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
    func imageTapped(cell: NetworksTableViewCell)
}
