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
import UserNotifications

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
        self.navigationController?.isNavigationBarHidden = false
    }
    
    // MARK: - IBAction Functions
    
    @IBAction func skipButtonTapped(_ sender: UIBarButtonItem) {
        
    }
    @IBAction func acceptButtonTapped(_ sender: UIButton) {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let pushManager = PushNotificationManager(userID: userID)
            pushManager.registerForPushNotifications()
        
        
        registerForPushNotifications()
    }
    
    // MARK: - Helper Functions
    
    func registerForPushNotifications() {
      //1
            UNUserNotificationCenter.current()
              //2
              .requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                DispatchQueue.main.async {
                    self.presentMain()
                }
                //3
                print("Permission granted: \(granted)")
              }
    }
    
    func updateViews() {
        self.acceptButton.layer.borderWidth = 1
        self.acceptButton.layer.borderColor = UIColor.black
            .cgColor
        self.acceptButton.setRoundedView()
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


