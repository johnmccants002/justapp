//
//  SignUpViewController.swift
//  PracticeCustomTableViews
//
//  Created by John McCants on 5/18/21.
//

import UIKit

class SignUpViewController: UIViewController {
    
    
    // MARK: - Properties
    
    var user : User?
    var emailString: String?
    var firstNameString: String?
    var lastNameString: String?
    var usernameString: String?
    var passwordString: String?
    var passwordAgainString: String?
    var count = 0
    var nextButton : UIBarButtonItem?
    var passwordValid = false
    var emailValid = false
    var usernameValid : Bool?

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var signUpTextField: UITextField!
    
    // MARK: - Lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupKeyboard()
        self.signUpTextField.becomeFirstResponder()
    }
    
    // MARK: - Helper Functions
    
    func updateViews() {
        self.signUpTextField.delegate = self
        self.signUpTextField.autocorrectionType = .no
        self.signUpTextField.spellCheckingType = .no
        self.view.backgroundColor = .blue
        self.signUpTextField.backgroundColor = .blue
        self.signUpTextField.borderStyle = .none
        self.label.text = "Enter Email"
        self.label.textColor = .white
        self.signUpTextField.textColor = .white
        self.navigationController?.isNavigationBarHidden = true
    }
    
    func setupKeyboard() {
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.sizeToFit()
        keyboardToolbar.isTranslucent = false
        keyboardToolbar.barTintColor = UIColor.white
        
        let nextButton = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(self.nextButtonPressed(_:)))
        nextButton.width = self.view.viewWidth
        nextButton.tintColor = UIColor.blue
        keyboardToolbar.items = [nextButton]
        keyboardToolbar.layer.borderWidth = 1
        keyboardToolbar.layer.borderColor = UIColor.black.cgColor
        self.signUpTextField.inputAccessoryView = keyboardToolbar
        self.nextButton = nextButton
    }
    
    func labelAnimation() {
        label.slideIn(from: .left, x: 50, y: 1, duration: 1, delay: 0) { _ in
        }
    }
    
    func checkFirstName(firstName: String) -> Bool {
        if firstName.count < 30 && firstName.count >= 2 {
        self.firstNameString = firstName
        count += 1
        clearTextField()
        labelAnimation()
        return true
        } else {
            return false
        }
    }
    
    func checkUsername(username: String, completion: @escaping(Int) -> Void) {
        if username.count < 20 && username.count >= 4 {
            AuthService.shared.checkIfUsernameExists(username: username) { int in
                if int == 0 {
                    self.usernameString = username
                    self.usernameValid = true
                    self.clearTextField()
                    self.labelAnimation()
                    self.count += 1
                    completion(0)
                } else {
                    completion(1)
                }
            }
    }
    }
    
    func checkPassword(password: String) {
        guard let validPassword = validatePassword(password: password) else {
            print("Invalid Password Guard142")
            return
        }
        print(passwordValid)
        self.passwordString = validPassword
        clearTextField()
    }
    
    func checkLastName(lastName: String) -> Bool {
        if lastName.count < 30 && lastName.count >= 2 {
            self.lastNameString = lastName
            count += 1
            clearTextField()
            labelAnimation()
            return true
        } else {
            return false
        }
    }
    
    func checkMatchingPassword(passwordAgain: String) {
        self.passwordAgainString = passwordAgain
        guard let password = self.passwordString else { return }
        
        if password == passwordAgain {
            count += 1
            createUser()
        } else {
            self.presentAlert()
        }
    }
    
    func passwordError(errorMessage: String) {
        let passwordAlert = UIAlertController(title: "Password Invalid", message: errorMessage, preferredStyle: .alert)
        let passwordAction = UIAlertAction(title: "Ok", style: .default) { _ in
            self.signUpTextField.text?.removeAll()
        }
        passwordAlert.addAction(passwordAction)
        
        self.present(passwordAlert, animated: true, completion: nil)
    }
    
    func clearTextField() {
        self.signUpTextField.text?.removeAll()
    }
    
    func presentAlert() {
        let alert = UIAlertController(title: "Invalid Matching Passwords", message: "Please Re-enter Password", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true) {
            self.signUpTextField.text?.removeAll()
        }
    }
    
    func createUser() {
        guard let email = emailString, let username = usernameString, let firstName = firstNameString, let lastName = lastNameString, let password = passwordString else { return }
        let credentials = AuthCredentials(email: email, password: password, username: username, firstName: firstName, lastName: lastName)
        AuthService.shared.registerUser(credentials: credentials) { error, ref in
            UserDefaults.standard.set(true, forKey: "isUserLoggedIn")
            self.presentNotificationController()
        }
       
    }
    
    func presentNotificationController() {
        self.performSegue(withIdentifier: "notificationController", sender: self)
    }
    
    func checkEmailAvailable(email: String?) {
        guard let email = email else { return }
        AuthService.shared.checkIfEmailExists(email: email) { int in
            if int == 0 {
                self.count += 1
                self.clearTextField()
                self.labelAnimation()
                self.label.text = "Enter First Name"
                self.emailString = email
            } else {
                print("Email in use")
            }
        }
    }

    // MARK: - Selectors
    
    @objc func nextButtonPressed(_: UIBarButtonItem) {
        print("Next Button Pressed")
        switch count {
        case 0:
            guard let email = self.validateEmail(email: self.signUpTextField.text) else { return }
            self.checkEmailAvailable(email: email)
        case 1:
            guard let firstName = self.signUpTextField.text else { return }
            if self.checkFirstName(firstName: firstName) {
                self.label.text = "Enter Last Name"
            }
        case 2:
            guard let lastName = self.signUpTextField.text else { return }
            if self.checkLastName(lastName: lastName) {
                self.label.text = "Enter Username"
            }
        case 3:
            guard let username = self.signUpTextField.text else { return }
            self.checkUsername(username: username, completion: { int in
                switch int {
                case 0:
                    self.signUpTextField.isSecureTextEntry = true
                    self.label.text = "Enter Password"
                case 1:
                    self.presentAlert()
                case 2:
                    self.presentAlert()
                default:
                    break
                }
            })
        case 4:
            guard let password = self.signUpTextField.text else { return }
            self.checkPassword(password: password)
        case 5:
            guard let passwordAgain = self.signUpTextField.text else { return }
            self.checkMatchingPassword(passwordAgain: passwordAgain)
            
        default:
            break
        }
    }
    

    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "notificationController" {
            let destination = segue.destination as! NotificationsViewController
            guard let user = user, let password = passwordString else { return }
            destination.user = user
            destination.password = password
            print("Going to Notification Controller")
        }
    }

        

}

// MARK: - UITextFieldDelegate

extension SignUpViewController: UITextFieldDelegate {
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if let txt = signUpTextField.text {
            passwordValid = true
            if (txt.rangeOfCharacter(from: CharacterSet.uppercaseLetters) == nil) {
                passwordValid = false
                print("need uppercase")
            }
            if (txt.rangeOfCharacter(from: CharacterSet.lowercaseLetters) == nil) {
                passwordValid = false
            }
            if (txt.rangeOfCharacter(from: CharacterSet.decimalDigits) == nil) {
                passwordValid = false
            }
            if txt.count < 8 {
                passwordValid = false
            }
        }
        
    
    }
 
    func validateEmail(email: String?) -> String? {
        guard let trimmedText = email?.trimmingCharacters(in: .whitespacesAndNewlines) else { return nil }
        guard let dataDetector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else { return nil }
        
        let range = NSMakeRange(0, NSString(string: trimmedText).length)
        let allMatches = dataDetector.matches(in: trimmedText,
                                              options: [],
                                              range: range)
        
        if allMatches.count == 1,
            allMatches.first?.url?.absoluteString.contains("mailto:") == true {
            return trimmedText
        } else {
            let alertController = UIAlertController(title: "Error", message: "Please enter a valid email address.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel) { _ in
                self.clearTextField()
            }
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
            return nil
        }
    }

    func validatePassword(password: String?) -> String? {
        var errorMsg = "Password requires at least "
        
        if let password = password {
            if (password.rangeOfCharacter(from: CharacterSet.uppercaseLetters) == nil) {
                errorMsg += "one upper case letter"
            }
            if (password.rangeOfCharacter(from: CharacterSet.lowercaseLetters) == nil) {
                errorMsg += ", one lower case letter"
            }
            if (password.rangeOfCharacter(from: CharacterSet.decimalDigits) == nil) {
                errorMsg += ", one number"
            }
            if password.count < 8 {
                errorMsg += ", eight characters"
            }
        }
        
        if passwordValid {
            count += 1
            labelAnimation()
            self.label.text = "Re-Enter Password"
            guard let nextButton = self.nextButton else { return nil }
            nextButton.title = "Finish"
            self.passwordString = password!
            return password!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        } else {
            passwordError(errorMessage: errorMsg)
            return nil
        }
    }
}


