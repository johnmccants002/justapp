//
//  NetworkUserCell.swift
//  PracticeCustomTableViews
//
//  Created by John McCants on 11/12/21.
//

import UIKit

class NetworkUserCell: UICollectionViewCell, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userLabel: UILabel!
    var user: User? {
        didSet {
            configure()
        }
    }
    var delegate: NetworkUserCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.userImageView.setRounded()
        setupLongPressGesture()
        setupTapGesture()
        self.layer.addBorder(edge: .bottom, color: .systemGray4, thickness: 0.25)
    }
    
    func configure() {
        guard let user = user else { return }
        userLabel.text = "\(user.firstName) \(user.lastName)"
        
        if let url = user.profileImageUrl {
            userImageView.sd_setImage(with: url, completed: nil)
        } else {
            userImageView.image = UIImage(named: "blank")
        }
    }
    
    func setupLongPressGesture() {
        let longPressGesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.didLongPress))
        longPressGesture.minimumPressDuration = 1.0 // 1 second press
        longPressGesture.delegate = self
        addGestureRecognizer(longPressGesture)
    }
    
    @objc func didLongPress(sender: UILongPressGestureRecognizer) {
        if sender.state == UIGestureRecognizer.State.began {
            delegate?.didLongPress(cell: self)
        }
    }
    
    @objc func cellTapped() {
        delegate?.cellTapped(cell: self)
    }
    
    func setupTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(cellTapped))
        tap.delegate = self
        self.addGestureRecognizer(tap)
    }
    
    

}

protocol NetworkUserCellDelegate {
    func removeUserFromNetwork(cell: NetworkUserCell)
    func didLongPress(cell: NetworkUserCell)
    func cellTapped(cell: NetworkUserCell)
}
