//
//  NotificationsViewController.swift
//  PracticeCustomTableViews
//
//  Created by John McCants on 5/18/21.
//

import UIKit
import UserNotifications
import Firebase
import FirebaseAuth

class NotificationsViewController: UIViewController, UINavigationControllerDelegate, UINavigationBarDelegate {

    // MARK: - Properties
    
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var skipButton: UIBarButtonItem!
    var user : User?
    var password: String?
    
    // MARK: - Lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
        // Do any additional setup after loading the view.
    }
    
    // MARK: - IBAction Functions
    
    @IBAction func skipButtonTapped(_ sender: UIBarButtonItem) {
        
    }
    @IBAction func acceptButtonTapped(_ sender: UIButton) {
        presentMain()
        print("accept pressed")
    }
    
    // MARK: - Helper Functions
    
    func updateViews() {
        
    }
    
    func presentMain() {
       
        let mainStoryBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let centerVC = mainStoryBoard.instantiateViewController(identifier: "MainJustViewController") as! MainJustViewController
        let nav = UINavigationController(rootViewController: centerVC)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)

    }
 
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
}


