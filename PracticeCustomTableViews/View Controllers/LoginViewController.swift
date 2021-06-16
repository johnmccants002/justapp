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

    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var emailTextField: UITextField!
    let shared = FirebaseController.shared
   

    override func viewDidLoad() {
        super.viewDidLoad()
        shared.delegate = self
        updateViews()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        //Firebase Code Login
        guard let emailText = emailTextField.text, !emailText.isEmpty, let passwordText = passwordTextField.text, !passwordText.isEmpty else { return }
        shared.loginUser(email: emailText, password: passwordText)
        self.loadingIndicator.isHidden = false
        self.loadingIndicator.startAnimating()
        sendInfoToDB()
        
    }
    
    func sendInfoToDB() {
        let _ : Timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.myPerformCode), userInfo: nil, repeats: false)
    }
    
    @objc func myPerformCode() {
        self.navigationController?.popViewController(animated: true)
        self.loadingIndicator.stopAnimating()
    }
    
    func updateViews() {
        self.loadingIndicator.isHidden = true
    }
    
    func presentMain(user : User) {
        DispatchQueue.main.async {
            let mainStoryBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let centerVC = mainStoryBoard.instantiateViewController(identifier: "MainJustViewController") as! MainJustViewController
            centerVC.user = user
            UserDefaults.standard.set(true, forKey: "isUserLoggedIn")
            UserDefaults.standard.set("uid", forKey: "uid")
            UserDefaults.standard.synchronize()
            let nav = UINavigationController(rootViewController: centerVC)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
        }
    }
    
    @IBAction func signUpButtonTapped(_ sender: UIButton) {
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
    
    func presentLoginAlert() {
        let alert = UIAlertController(title: "Invalid Login Info", message: "Please Enter Valid Info", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        
        alert.addAction(action)
        self.present(alert, animated: true) {
            self.emailTextField.text?.removeAll()
            self.passwordTextField.text?.removeAll()
            self.loadingIndicator.isHidden = true
            self.resignFirstResponder()
        }
        
    }
}

extension LoginViewController: FirebaseControllerDelegate {
    func logoutUser(firebaseController: FirebaseController) {
    }
    
    func loginUser(firebaseController: FirebaseController) {
        guard let user = shared.currentUser else {
            return }
        self.presentMain(user: user)
        UserDefaults.standard.set(true, forKey: "isUserLoggedIn")
        UserDefaults.standard.set(user.uid, forKey: "uid")
        UserDefaults.standard.synchronize()
    }
    
    func presentAlert(firebaseController: FirebaseController) {
        print("present Alert Firebase working")
        self.presentLoginAlert()
        self.resignFirstResponder()
    }
}
