//
//  ProfileViewController.swift
//  PracticeCustomTableViews
//
//  Created by John McCants on 5/14/21.
//

import UIKit

class ProfileViewController: UIViewController, UINavigationControllerDelegate {

    
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var editButton: UIBarButtonItem!
    @IBOutlet weak var addPhotoImageView: UIImageView!
    @IBOutlet weak var aboutTextView: UITextView!
    @IBOutlet weak var profileImageView: UIImageView!
    var editMode : Bool = false
    var imagePicker = UIImagePickerController()
    let dummyData = DummyData()
    var user : User?
    let shared = FirebaseController.shared
    
    @IBOutlet weak var tableView: UITableView!
    var userJusts = ["1", "2", "3"]
    var photoSelected = false
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViews()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.imagePicker.delegate = self
    }
    
    func updateViews() {
        self.navigationItem.hidesBackButton = true
        self.view.backgroundColor = .white
        self.profileImageView.isUserInteractionEnabled = false
        self.aboutTextView.isUserInteractionEnabled = false
        self.aboutTextView.text = self.user?.aboutText
        self.profileImageView.setRounded()
        self.addPhotoImageView.setRounded()
        self.addPhotoImageView.isHidden = true
        self.addPhotoImageView.isUserInteractionEnabled = false
        self.editButton.title = "Settings"
        self.backButton.isEnabled = true
        shared.delegate = self
        self.aboutTextView.autocorrectionType = .no
        self.aboutTextView.layer.cornerRadius = 7
    }
    
    func setupSettings() -> UIAlertController {
        let settingsAlert = UIAlertController(title: "Settings", message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let logoutAction = UIAlertAction(title: "Logout", style: .destructive) { logoutAction in
            self.shared.logout()
        }
        let editProfile = UIAlertAction(title: "Edit Profile", style: .default) { editProfile in
            self.editMode.toggle()
            self.editModeSetup()
            self.editButton.title = "Done"
        }
        settingsAlert.addAction(cancelAction)
        settingsAlert.addAction(logoutAction)
        settingsAlert.addAction(editProfile)
        
        return settingsAlert
    }
    
    func presentLogin() {
        let storyboard = UIStoryboard(name: "SignUp", bundle: nil)
        UserDefaults.standard.set(false, forKey: "isUserLoggedIn")
        UserDefaults.standard.set("", forKey: "uid")
        UserDefaults.standard.synchronize()
        let loginVC = storyboard.instantiateViewController(identifier: "LoginViewController") as! LoginViewController
        loginVC.modalPresentationStyle = .fullScreen
        self.present(loginVC, animated: true) {
            //Firebase Code Here
        }
        
    }
    
    @IBAction func justButtonTapped(_ sender: UIBarButtonItem) {
        let transition:CATransition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        transition.type = CATransitionType.push
        transition.subtype = .fromRight
        self.navigationController?.view.layer.add(transition, forKey: kCATransition)

        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func editButtonTapped(_ sender: UIBarButtonItem) {
        if self.editButton.title == "Done" {
            updateViews()
        } else if self.editButton.title == "Settings" {
            self.present(setupSettings(), animated: true)
        }
        
    }
    
    func editModeSetup() {
        self.profileImageView.isUserInteractionEnabled = true
        self.aboutTextView.isUserInteractionEnabled = true
        self.addPhotoImageView.isHidden = false
        self.addPhotoImageView.isUserInteractionEnabled = true
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(editProfileImage(tapGestureRecognizer:)))
        self.addPhotoImageView.addGestureRecognizer(tapGestureRecognizer)
        self.editButton.title = "Done"
        self.backButton.isEnabled = false
    }
    
    @objc func editProfileImage(tapGestureRecognizer : UITapGestureRecognizer) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
               // Your action
        print("ImageTapped Function Firing")
    }
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dummyData.johnJustArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "profileJustCell", for: indexPath) as! PracticeTableViewCell
        
        cell.usernameButton.setTitle("You", for: .normal)
        cell.justLabel.text = dummyData.johnJustArray[indexPath.row]
        cell.usernameButton.isUserInteractionEnabled = false
        cell.respectButton.setTitle(dummyData.johnRespectArray[indexPath.row], for: .normal)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Your Justs"
        } else {
            return nil
        }
    }
    
    
}

extension ProfileViewController: UIImagePickerControllerDelegate {
// MARK: - UIImagePickerControllerDelegate Methods
func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
    if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
        print("image picked")
        self.profileImageView.contentMode = .scaleAspectFit
        self.profileImageView.image = pickedImage
        photoSelected = true
    }
    

    dismiss(animated: true, completion: nil)
}

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

extension ProfileViewController: FirebaseControllerDelegate {
    func logoutUser(firebaseController: FirebaseController) {
        presentLogin()
    }
    
    func loginUser(firebaseController: FirebaseController) {
        
    }
    
    func presentAlert(firebaseController: FirebaseController) {
        
    }
    
    
}

extension UIImageView {

    func setRounded() {
        self.layer.cornerRadius = (self.frame.width / 2)
        self.layer.masksToBounds = true
        self.contentMode = .scaleAspectFill
    }
}

