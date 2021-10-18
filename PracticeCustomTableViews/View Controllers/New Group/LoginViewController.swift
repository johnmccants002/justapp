//
//  LoginViewController.swift
//  PracticeCustomTableViews
//
//  Created by John McCants on 5/18/21.
//

import UIKit
import Firebase
import FirebaseAuth

class LoginViewController: UIViewController {

    
    // MARK: - Properties
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var emailTextField: UITextField!
   

    // MARK: - Lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
        // Do any additional setup after loading the view.
    }
    
    // MARK: - IBActions
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        //Firebase Code Login
        guard let emailText = emailTextField.text, !emailText.isEmpty, let passwordText = passwordTextField.text, !passwordText.isEmpty else { return }
            self.loadingIndicator.isHidden = false
            self.loadingIndicator.startAnimating()
            self.sendInfoToDB()
    }
    
    @IBAction func signUpButtonTapped(_ sender: UIButton) {
    }
    
    
    // MARK: - Helper Functions
    
    func updateViews() {
        self.loadingIndicator.isHidden = true
    }
    
    func sendInfoToDB() {
        let _ : Timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.myPerformCode), userInfo: nil, repeats: false)
    }
    
    func presentMain(user : User) {
        DispatchQueue.main.async {
            let mainStoryBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let centerVC = mainStoryBoard.instantiateViewController(identifier: "MainJustViewController") as! MainJustViewController
            centerVC.currentUser = user
            UserDefaults.standard.set(true, forKey: "isUserLoggedIn")
            UserDefaults.standard.set("uid", forKey: "uid")
            UserDefaults.standard.synchronize()
            let nav = UINavigationController(rootViewController: centerVC)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
        }
    }
    
    func presentLoginAlert() {
        let alert = UIAlertController(title: "Invalid Login Info", message: "Please Enter Valid Info", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        DispatchQueue.main.async {
            self.present(alert, animated: true) {
                self.emailTextField.text?.removeAll()
                self.passwordTextField.text?.removeAll()
                self.loadingIndicator.isHidden = true
                self.resignFirstResponder()
            }
        }

        
        print("Success Present Login Alert")
        
    }
    
    // MARK: - Selectors
    
    @objc func myPerformCode() {
        self.loadingIndicator.stopAnimating()
    }
    

    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
}

