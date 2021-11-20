//
//  PractiveTableViewCell.swift
//  PracticeCustomTableViews
//
//  Created by John McCants on 5/4/21.
//

import UIKit

class JustTableViewCell: UITableViewCell {
    
    var just: Just?

    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var usernameButton: UIButton!
    @IBOutlet weak var respectButton: UIButton!
    @IBOutlet weak var justLabel: UILabel!
    var username : String?
    var delegate: PracticeTableViewCellDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        overrideUserInterfaceStyle = .light
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    @IBAction func respectButtonTapped(_ sender: UIButton) {
        
        if self.respectButton.currentImage == UIImage(named: "respectbutton") {
            self.respectButton.setImage(UIImage(named: "respecttapped"), for: .normal)
        } else if self.respectButton.currentImage == UIImage(named: "respecttapped") {
            self.respectButton.setImage(UIImage(named: "respectbutton"), for: .normal)
        }
        
        if self.respectButton.currentImage == nil {
            self.delegate?.respectedByTapped(cell: self)
        }

    }
    
    @IBAction func usernameButtonTapped(_ sender: UIButton) {
        self.delegate?.usernameButtonTapped(cell: self)
    }
    
    func updateViews() {
        self.respectButton.setImage(UIImage(named: "respecttapped"), for: .normal)
        
        guard let just = self.just else { return }
        self.justLabel.text = just.justText
        self.username = "\(just.firstName) \(just.lastName)"
        
        self.usernameButton.setTitle(self.username, for: .normal)
    }
    
    func didLongPress(sender: UILongPressGestureRecognizer) {
        print("Cell did Long Press")
        if sender.state == UIGestureRecognizer.State.began {
            delegate?.didLongPress(cell: self)
        }
    }
    
    
}

protocol PracticeTableViewCellDelegate {
    func usernameButtonTapped(cell: JustTableViewCell)
    
    func respectedByTapped(cell: JustTableViewCell)
    
    func didLongPress(cell: JustTableViewCell)
    
}
