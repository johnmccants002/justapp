//
//  AnnouncementCell.swift
//  PracticeCustomTableViews
//
//  Created by John McCants on 12/10/21.
//

import UIKit
import SwiftLinkPreview

class AnnouncementCell: UICollectionViewCell {

    var user : User?
    var announcement : Announcement? {
        didSet {
            setupCell()
        }
    }
    var result: Response?
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var announcementTextView: UITextView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    
    let slp = SwiftLinkPreview(session: URLSession.shared, workQueue: SwiftLinkPreview.defaultWorkQueue, responseQueue: .main, cache: DisabledCache.instance)
    
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
        let preview = slp.preview(announcement.announcementText) { result in
//            self.anchor(height: self.viewHeight + 140)
//            self.contentView.anchor(height: self.contentView.viewHeight + 140)
            self.printResult(result)
        } onError: { error in
            print("This is the error \(error.localizedDescription)")
        }

        announcementTextView.text = announcement.announcementText
    
        if let dateString = announcement.dateString {
            timestampLabel.text = dateString
        }

    }
    
    func printResult(_ result: Response) {
        print("url: ", result.url ?? "no url")
        print("finalUrl: ", result.finalUrl ?? "no finalUrl")
        print("canonicalUrl: ", result.canonicalUrl ?? "no canonicalUrl")
        print("title: ", result.title ?? "no title")
        print("images: ", result.images ?? "no images")
        print("image: ", result.image ?? "no image")
        print("video: ", result.video ?? "no video")
        print("icon: ", result.icon ?? "no icon")
        print("description: ", result.description ?? "no description")
//        createLinkPreview(result: result)
    }
    
    func createLinkPreview(result: Response) {
        let linkView = UIView()
        let linkTitleLabel = UILabel()
        let cannonicalUrlLabel = UILabel()
        let descriptionLabel = UILabel()
        self.addSubview(linkView)
        linkView.addSubview(linkTitleLabel)
        linkView.addSubview(cannonicalUrlLabel)
        linkView.addSubview(descriptionLabel)
        linkView.anchor(top: self.announcementTextView.bottomAnchor, left: self.leftAnchor, right: self.rightAnchor)
        linkView.setDimensions(width: self.viewWidth, height: 140)
        linkTitleLabel.anchor(top: linkView.topAnchor, left: linkView.leftAnchor, right: linkView.rightAnchor, paddingLeft: 10, paddingRight: 10, height: 25)
        
        let imageView = UIImageView()
        linkView.addSubview(imageView)
        imageView.anchor(top: linkTitleLabel.bottomAnchor, left: linkView.leftAnchor, paddingTop: 5, paddingLeft: 10)
        imageView.anchor(width: 40, height: 40)
        cannonicalUrlLabel.anchor(left: imageView.rightAnchor, right: linkView.rightAnchor, paddingLeft: 5, paddingRight: 5, height: 20)
        cannonicalUrlLabel.centerY(inView: imageView)
        descriptionLabel.anchor(top: imageView.bottomAnchor, left: linkView.leftAnchor, right: linkView.rightAnchor, paddingLeft: 5, paddingRight: 5, height: 75)
        
//        if let icon = result.icon, let url = URL(string: icon) {
//            imageView.sd_setImage(with: url, completed: nil)
//        } else {
            if let imageString = result.image, let url = URL(string: imageString) {
                imageView.sd_setImage(with: url, completed: nil)
            }
        
        
        if let cannonicalUrl = result.canonicalUrl {
            cannonicalUrlLabel.text = cannonicalUrl
        }
        
        if let linkTitle = result.title {
            linkTitleLabel.text = linkTitle
        }
        
        if let description = result.description {
            descriptionLabel.text = description
        }
        self.isUserInteractionEnabled = true
        self.contentView.isUserInteractionEnabled = true
        linkView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(openWithAction))
        linkView.addGestureRecognizer(tap)
        cannonicalUrlLabel.addGestureRecognizer(tap)
        imageView.addGestureRecognizer(tap)
       
    }
    
    @objc func imageTapped() {
        print("image tapped")
        delegate?.imageTapped(cell: self)
    }
    
    @objc func nameTapped() {
        print("name tapped")
        delegate?.fullNameTapped(cell: self)
    }
    
    @objc func openWithAction() {
        print("yooooo")
        if let result = self.result, let url = result.finalUrl {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)

        }

    }

}

protocol AnnouncementCellDelegate: AnyObject {
    func imageTapped(cell: AnnouncementCell)
    func fullNameTapped(cell: AnnouncementCell)
}
