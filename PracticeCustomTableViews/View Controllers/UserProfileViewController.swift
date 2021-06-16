//
//  UserProfileViewController.swift
//  PracticeCustomTableViews
//
//  Created by John McCants on 5/11/21.
//

import UIKit

class UserProfileViewController: UIViewController, UINavigationBarDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var aboutText: UITextView!
    @IBOutlet weak var nameLabel: UILabel!
    var titleString : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func updateViews() {
        guard let titleString = titleString else {return}
        self.title = titleString
    }

}
