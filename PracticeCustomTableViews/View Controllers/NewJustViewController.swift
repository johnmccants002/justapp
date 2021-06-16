//
//  NewJustViewController.swift
//  PracticeCustomTableViews
//
//  Created by John McCants on 5/14/21.
//

import UIKit
import Firebase
import FirebaseAuth

class NewJustViewController: UIViewController, UINavigationControllerDelegate {

    @IBOutlet weak var navigation: UINavigationItem!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet var selectButton : UIButton!
    @IBOutlet weak var countLabel: UILabel!
    var postButtonKeyboard: UIBarButtonItem {
        let nextButton = UIBarButtonItem(title: "Post", style: .plain, target: self, action: #selector(self.postButtonPressed(_:)))
        nextButton.width = self.view.viewWidth
        nextButton.tintColor = UIColor.blue
        return nextButton
    }
    var keyboardToolBar: UIToolbar {
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.sizeToFit()
        keyboardToolbar.isTranslucent = false
        keyboardToolbar.barTintColor = UIColor.white
        keyboardToolbar.items = [self.postButtonKeyboard]
        keyboardToolbar.layer.borderWidth = 1
        keyboardToolbar.layer.borderColor = UIColor.black.cgColor
        return keyboardToolbar
    }
    @IBOutlet weak var justTextView: UITextView!
    var widthConstraint : NSLayoutConstraint?
    let justMaxLength = 75
    let imagePicker = UIImagePickerController()
    var photoSelected = false
    override func viewDidLoad() {
        super.viewDidLoad()
        self.justTextView.delegate = self
        updateViews()
        self.imagePicker.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.justTextView.becomeFirstResponder()
    }
    
    func updateViews() {
        self.loadingIndicator.isHidden = true
        networkButtonSetUp()
        self.justTextView.tintColor = .black
        self.justTextView.autocapitalizationType = .none
        self.justTextView.isScrollEnabled = false
        self.justTextView.inputAccessoryView = keyboardToolBar
        self.keyboardToolBar.isHidden = true
    }
    
    func networkButtonSetUp() {
        selectButton.layer.cornerRadius = 5
        selectButton.layer.borderColor = UIColor.blue.cgColor
        selectButton.layer.borderWidth = 1
        selectButton.layer.backgroundColor = UIColor.white.cgColor
        let width = selectButton.widthAnchor.constraint(equalToConstant: 130)
        self.widthConstraint = width
        guard let widthConstraint = widthConstraint else { return }
        selectButton.addConstraint(widthConstraint)
    }

    @objc func postButtonPressed(_: UIButton) {
        self.loadingIndicator.isHidden = false
        self.loadingIndicator.startAnimating()
        sendInfoToDB()
    }
    
    func presentAlertSelection() {
        let alert = UIAlertController(title: "Choose where to send your Just", message: nil, preferredStyle: .actionSheet)
        let action = UIAlertAction(title: "Your Network", style: .default) { _ in
            self.selectButton.setTitle("To: Your Network", for: .normal)
            guard let widthConstraint = self.widthConstraint else { return }
            self.selectButton.removeConstraint(widthConstraint)
            let width = self.selectButton.widthAnchor.constraint(equalToConstant: 130)
            self.selectButton.addConstraint(width)
            self.widthConstraint = width
        }
        let action2 = UIAlertAction(title: "Your Network and Friends Networks", style: .default) { _ in
            self.selectButton.setTitle("To: Your Network + Friends Networks", for: .normal)
            guard let widthConstraint = self.widthConstraint else { return }
            self.selectButton.removeConstraint(widthConstraint)
            let widthPlus = self.selectButton.widthAnchor.constraint(equalToConstant: 225)
            self.selectButton.addConstraint(widthPlus)
            self.widthConstraint = widthPlus
            
        }
            alert.addAction(action)
            alert.addAction(action2)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func selectButtonTapped(_ sender: UIButton) {
        presentAlertSelection()
    }
    
    func sendInfoToDB() {
        let _ : Timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.myPerformCode), userInfo: nil, repeats: false)
    }
    
    @objc func myPerformCode() {
        self.navigationController?.popViewController(animated: true)
        self.loadingIndicator.stopAnimating()
    }

}

extension NewJustViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        
        self.keyboardToolBar.isHidden = true
        if textView.text.count > 1 {
                self.keyboardToolBar.isHidden = false
            print("textview greater than 1")
            }
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if textView == self.justTextView {
            return textView.text.count + (text.count - range.length) <= justMaxLength
        }
        
        return false
         
    }
        
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.justTextView.text = ""
    }
    
}

extension NewJustViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            print("image picked")
            photoSelected = true
        }
        

        dismiss(animated: true, completion: nil)
    }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            dismiss(animated: true, completion: nil)
        }
}

extension NewJustViewController {
    open override func awakeFromNib() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
}
