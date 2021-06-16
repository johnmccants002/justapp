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

    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var skipButton: UIBarButtonItem!
    var user : User?
    var password: String?
    let shared = FirebaseController.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.shared.delegate = self
        updateViews()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func skipButtonTapped(_ sender: UIBarButtonItem) {
        
    }
    @IBAction func acceptButtonTapped(_ sender: UIButton) {
        createUser()
        print("accept pressed")
    }
    
    func updateViews() {
        
    }
    
    func presentMain(user: User) {
        let mainStoryBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let centerVC = mainStoryBoard.instantiateViewController(identifier: "MainJustViewController") as! MainJustViewController
        centerVC.user = user
        
        let nav = UINavigationController(rootViewController: centerVC)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
    }
    
    func createUser() {
        guard let user = user, let password = password else {
            print("No user, No Password")
            return }
        shared.createUser(email: user.email, password: password, username: user.username, firstName: user.firstName, lastName: user.lastName) { bool in
            if bool == true {
                guard let currentUser = self.shared.currentUser else { return }
                self.presentMain(user: currentUser)
            } else {
                let alert = UIAlertController(title: "Error", message: "Unable to Create Profile", preferredStyle: .alert)
                let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    

    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }


}

extension NotificationsViewController: FirebaseControllerDelegate {
    func logoutUser(firebaseController: FirebaseController) {
    }
    
    func loginUser(firebaseController: FirebaseController) {
        UserDefaults.standard.set(true, forKey: "isUserLoggedIn")
        guard let currentUser = shared.currentUser else { return }
        UserDefaults.standard.set(currentUser.uid, forKey: "uid")
        UserDefaults.standard.synchronize()
        print("login user delegate firing")
        
    }
    
    func presentAlert(firebaseController: FirebaseController) {
    }
    
    
}
