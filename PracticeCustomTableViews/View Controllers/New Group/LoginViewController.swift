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
    @IBOutlet weak var signUpButton: UIButton!
    

    // MARK: - Lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
        self.hideKeyboardWhenTappedAround()
        overrideUserInterfaceStyle = .light
        // Do any additional setup after loading the view.
    }
    
    // MARK: - IBActions
    
    @IBAction func loginButtonTapped(_ sender: UIButton) {
        //Firebase Code Login
        guard let emailText = emailTextField.text, !emailText.isEmpty, let passwordText = passwordTextField.text, !passwordText.isEmpty else { return }
            self.loadingIndicator.isHidden = false
            self.loadingIndicator.startAnimating()
        self.sendInfoToDB(email: emailText, password: passwordText)
    }
    
    @IBAction func signUpButtonTapped(_ sender: UIButton) {
        let controller = PhoneNumberVerificationController()
        controller.modalPresentationStyle = .overFullScreen
        self.present(controller, animated: true, completion: nil)
    }
    
    
    // MARK: - Helper Functions
    
    func updateViews() {
        self.loadingIndicator.isHidden = true
        self.emailTextField.autocorrectionType = .no
        self.passwordTextField.autocorrectionType = .no
        self.signUpButton.layer.borderWidth = 1
        self.signUpButton.layer.borderColor = UIColor.black.cgColor
        self.signUpButton.setRoundedView()
        self.loginButton.setRoundedView()
    }
    
    func sendInfoToDB(email: String, password: String) {
        let _ : Timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.myPerformCode), userInfo: nil, repeats: false)
        
        AuthService.shared.logUserIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                self.presentLoginAlert()
            } else {
                print("This is the result from firebase")
                self.presentMain()
            }
            
        }
    }
    
    func presentMain() {
        DispatchQueue.main.async {
            let mainStoryBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let centerVC = mainStoryBoard.instantiateViewController(identifier: "MainJustViewController") as! MainJustViewController
            
            UserDefaults.standard.setValue(true, forKey: "isUserLoggedIn")
            UserDefaults.standard.synchronize()
            let nav = UINavigationController(rootViewController: centerVC)
            nav.modalPresentationStyle = .fullScreen
            self.window?.rootViewController = nav
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

extension LoginViewController {
        var appDelegate: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    var sceneDelegate: SceneDelegate? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let delegate = windowScene.delegate as? SceneDelegate else { return nil }
         return delegate
    }
}

extension LoginViewController {
    var window: UIWindow? {
        if #available(iOS 13, *) {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                let delegate = windowScene.delegate as? SceneDelegate, let window = delegate.window else { return nil }
                   return window
        }
        
        guard let delegate = UIApplication.shared.delegate as? AppDelegate, let window = delegate.window else { return nil }
        return window
    }
}

