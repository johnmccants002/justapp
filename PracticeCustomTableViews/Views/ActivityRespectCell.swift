//
//  ActivityRespectCell.swift
//  PracticeCustomTableViews
//
//  Created by John McCants on 8/20/21.
//

import UIKit

class ActivityRespectCell: UICollectionViewCell {

    var respectNotification: RespectNotification? {
        didSet {
            fetchUser()
        }
    }
    var user: User? {
        didSet {
            configure()
            setupImageView()
        }
    }
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var imageView: UIImageView!
    var delegate: ActivityRespectCellDelegate?
    
    @IBOutlet weak var captionLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let tapGesture = UITapGestureRecognizer(target: self,
                                                           action: #selector(imageTapped))
                   containerView.isUserInteractionEnabled = true
                   imageView.addGestureRecognizer(tapGesture)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func setupImageView() {
        let tap = UIGestureRecognizer(target: self, action: #selector(imageTapped))
        imageView.clipsToBounds = true
        imageView.addGestureRecognizer(tap)
        imageView.layer.cornerRadius = imageView.viewHeight / 2
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.backgroundColor = .lightGray
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 4
        imageView.isUserInteractionEnabled = true
    }
    
    @objc func imageTapped() {
        delegate?.cellImageTapped(cell: self)
        print("image tapped")
    }
    
    func configure() {
        contentView.isUserInteractionEnabled = true
        guard let respectNotification = respectNotification else { return }
        captionLabel.text = "\(respectNotification.firstName) respected your just"
        guard let user = user else { return }
        guard let url = user.profileImageUrl else {return
        }
        imageView.sd_setImage(with: url, completed: nil)
    }
    
    func fetchUser() {
        guard let respectNotification = respectNotification else { return }
        UserService.shared.fetchUser(uid: respectNotification.fromUserUid) { user in
            self.user = user
        }
    }

}

protocol ActivityRespectCellDelegate: AnyObject {
    func cellImageTapped(cell: ActivityRespectCell)
}

