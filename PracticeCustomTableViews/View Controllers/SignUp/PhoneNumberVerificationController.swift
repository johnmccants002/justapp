//
//  PhoneNumberVerificationController.swift
//  PracticeCustomTableViews
//
//  Created by John McCants on 11/30/21.
//

import Foundation
import UIKit

class PhoneNumberVerificationController: UINavigationController, UINavigationControllerDelegate {
    
    var mode = "PhoneNumber"
    var topLabel : UILabel = {
        let lbl = UILabel()
        lbl.text = "Enter your phone number"
        lbl.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
        lbl.textAlignment = .left
        return lbl
    }()
    var descriptionLabel = UILabel()
    var phoneNumberTextField : UITextField = {
        let tf = UITextField()
        tf.layer.addBorder(edge: .bottom, color: .black, thickness: 2)
        tf.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
        return tf
    }()
    
    var sendButton : UIBarButtonItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
        setupKeyboard()
    }
    
    func updateViews() {
        self.view.backgroundColor = .white
        self.view.addSubview(topLabel)
        topLabel.anchor(top: self.navigationBar.bottomAnchor, left: self.view.leftAnchor, paddingTop: 80, paddingLeft: 20)
        topLabel.setDimensions(width: 250, height: 30)
        phoneNumberTextField.delegate = self
        self.view.addSubview(phoneNumberTextField)
        phoneNumberTextField.anchor(top: topLabel.bottomAnchor, left: self.view.leftAnchor, paddingTop: 20, paddingLeft: 20)
        phoneNumberTextField.setDimensions(width: 150, height: 30)
        phoneNumberTextField.keyboardType = .phonePad
        phoneNumberTextField.becomeFirstResponder()
        
    }
    
    func setupKeyboard() {
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.sizeToFit()
        keyboardToolbar.isTranslucent = false
        keyboardToolbar.barTintColor = UIColor.white
        let sendButton = UIBarButtonItem(title: "Send", style: .plain, target: self, action: #selector(self.sendButtonPressed(_:)))
        sendButton.width = self.view.viewWidth
        sendButton.tintColor = UIColor.black
        keyboardToolbar.items = [sendButton]
        keyboardToolbar.layer.borderWidth = 1
        keyboardToolbar.layer.borderColor = UIColor.black.cgColor
        self.phoneNumberTextField.autocorrectionType = .no
        self.phoneNumberTextField.inputAccessoryView = keyboardToolbar
        self.sendButton = sendButton
    }
    
    @objc func sendButtonPressed(_ : UIBarButtonItem) {
        phoneNumberTextField.resignFirstResponder()
        if mode == "PhoneNumber" {
            
        if let text = phoneNumberTextField.text, !text.isEmpty {
            let number = "+1\(text)"
            AuthManager.shared.startAuth(phoneNumber: number) { success in
                print("This is the result \(success)")
                DispatchQueue.main.async {
                    self.mode = "Code"
                    self.setupVerificationCodeView()
                }
            }
        }
        } else if mode == "Code" {
            if let text = phoneNumberTextField.text, !text.isEmpty {
                let code = text
                AuthManager.shared.verifyCode(smsCode: code){ success in
                    guard success else { return }
                    DispatchQueue.main.async {
                        let controller = SignUpViewController()
                        self.present(controller, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    func setupVerificationCodeView() {
        phoneNumberTextField.text = ""
        topLabel.slideIn()
        topLabel.text = "Enter 6-digit Code"
        phoneNumberTextField.becomeFirstResponder()
    }

    
    
}

extension PhoneNumberVerificationController: UITextFieldDelegate {
    
}
