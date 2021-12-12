//
//  AnnouncementCell.swift
//  PracticeCustomTableViews
//
//  Created by John McCants on 12/10/21.
//

import UIKit

class AnnouncementCell: UICollectionViewCell {

    var user : User?
    var announcement : Announcement? {
        didSet {
            setupCell()
        }
    }
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var announcementTextView: UITextView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    
    var delegate: AnnouncementCellDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupShadows()
    }
    

    
    func setupShadows() {
        userImageView.layer.cornerRadius = 30 / 2
        layer.borderWidth = 0.0
        layer.shadowColor = UIColor.lightGray.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowRadius = 3.0
        layer.shadowOpacity = 0.75
        layer.masksToBounds = false //<-
    }
    
    func setupCell() {
        announcementTextView.isEditable = false
        self.contentView.isUserInteractionEnabled = true
        fullNameLabel.isUserInteractionEnabled = true
        userImageView.isUserInteractionEnabled = true
        
        guard let announcement = announcement else {
            return
        }
        guard let user = user else { return }
        fullNameLabel.text = "\(user.firstName) \(user.lastName)"
        let tapName = UITapGestureRecognizer(target: self, action: #selector(nameTapped))
        fullNameLabel.addGestureRecognizer(tapName)
        if let url = user.profileImageUrl {
            userImageView.sd_setImage(with: url, completed: nil)
        } else {
            userImageView.image = UIImage(named: "blank")
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        userImageView.addGestureRecognizer(tap)
        
        announcementTextView.text = announcement.announcementText
    
        if let dateString = announcement.dateString {
            timestampLabel.text = dateString
        }

    }
    
    @objc func imageTapped() {
        print("image tapped")
        delegate?.imageTapped(cell: self)
    }
    
    @objc func nameTapped() {
        print("name tapped")
        delegate?.fullNameTapped(cell: self)
    }

}

protocol AnnouncementCellDelegate: AnyObject {
    func imageTapped(cell: AnnouncementCell)
    func fullNameTapped(cell: AnnouncementCell)
}
