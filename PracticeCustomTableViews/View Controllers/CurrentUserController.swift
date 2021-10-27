//
//  CurrentUserController.swift
//  PracticeCustomTableViews
//
//  Created by John McCants on 8/24/21.
//

import Foundation
import UIKit

private let reuseIdentifier = "networkJustCell"
private let headerIdentifier = "ProfileHeader"

class CurrentUserController: UICollectionViewController, UINavigationControllerDelegate {
    
    // MARK - Properties
    
    var currentUser: User {
        didSet {
            collectionView.reloadData()
        }
    }
    var justs = [Just]() {
        didSet {
            collectionView.reloadData()
        }
    }
    let justNibName = "NetworkJustCell"
    var editMode : Bool = false {
        didSet {
            collectionView.reloadData()
            print("just set editMode to true")
        }
    }
    var pickedImage: UIImage? {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var user: User? {
        didSet {
            collectionView.reloadData()
        }
    }
    var isUser: Bool?
    
    var photoSelected = false
    var imagePicker = UIImagePickerController()
    
    private let cache = NSCache<NSNumber, Just>()
    private let utilityQueue = DispatchQueue.global(qos: .utility)
    
    
    // MARK - Initializer
    
    init(currentUser: User, isUser: Bool) {
        self.currentUser = currentUser
        self.isUser = isUser
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK - Lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        updateViews()
        fetchUserJusts()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.isHidden = true
        updateViews()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.cache.removeAllObjects()
    }
    
    
    // MARK: - Firebase Functions
    
    func fetchUserJusts() {
        if isUser == true {
            guard let user = user else { return }
            JustService.shared.fetchUserJusts(networkId: user.networkId, userUid: user.uid) { justs in
                self.justs = justs
                self.checkIfUserRespectedJusts(justs: self.justs)
            }
        } else if isUser == false {
            JustService.shared.fetchUserJusts(networkId: currentUser.networkId, userUid: currentUser.uid) { justs in
                self.justs = justs
                self.checkIfUserRespectedJusts(justs: self.justs)
        }
        }
    }
    
    func checkIfUserRespectedJusts(justs: [Just]) {
        for (index, just) in justs.enumerated() {
            JustService.shared.checkIfUserRespected(just: just) {
                didRespect in
                guard didRespect == true else { return }
                self.justs[index].didRespect = true
            }
        }
    }
    
    func fetchUser(uid: String) {
        UserService.shared.fetchUser(uid: uid) { user in
            self.user = user
        }
    }
    
    // MARK - Helper Functions
    
    func updateViews() {
        configureCollectionView()
        imagePicker.delegate = self
        
    }
    
    func presentLogin() {
        let storyboard = UIStoryboard(name: "SignUp", bundle: nil)
        UserDefaults.standard.set(false, forKey: "isUserLoggedIn")
        UserDefaults.standard.set("", forKey: "uid")
        UserDefaults.standard.synchronize()
        let loginVC = storyboard.instantiateViewController(identifier: "LoginViewController") as! LoginViewController
        loginVC.modalPresentationStyle = .fullScreen
        self.present(loginVC, animated: true) {
        }
        
    }
    
    func setupSettings() -> UIAlertController {
        let settingsAlert = UIAlertController(title: "Settings", message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let logoutAction = UIAlertAction(title: "Logout", style: .destructive) { logoutAction in
            AuthService.shared.logoutUser()
            self.presentLogin()
            
        }
        let editProfile = UIAlertAction(title: "Edit Profile", style: .default) { editProfile in
            self.editMode = true
            self.collectionView.reloadData()
        }
        settingsAlert.addAction(cancelAction)
        settingsAlert.addAction(logoutAction)
        settingsAlert.addAction(editProfile)
        
        return settingsAlert
    }
    
    func loadJust(completion: @escaping(Just?) -> ()) {
        
    }
    
    
    // MARK: UICollectionView Functions

    
    func configureCollectionView() {
        navigationController?.navigationBar.isHidden = true
        collectionView.delegate = self
        self.title = "\(currentUser.firstName) \(currentUser.lastName)"
        let nib = UINib(nibName: justNibName, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "networkJustCell")
        collectionView.backgroundColor = .white
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.backgroundColor = .white
        collectionView.register(ProfileHeader.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)
 
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! NetworkJustCell
            
        let itemNumber = NSNumber(value: indexPath.row)
        cell.currentUserId = currentUser.uid
        cell.delegate = self
        
        if let cachedJust = self.cache.object(forKey: itemNumber) {
            cell.just = cachedJust
            print("we have cachedJust")
        } else {
            print("we do not have cachedJust")
            cell.just = justs[indexPath.row]
            self.cache.setObject(justs[indexPath.row], forKey: itemNumber)
        }
        cell.tag = indexPath.row
        
        if justs[indexPath.row].uid == currentUser.uid {
            cell.setupRespectButton()
        }
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return justs.count
    }
    
    
}

// MARK: - ProfileHeaderDelegate

extension CurrentUserController: ProfileHeaderDelegate {
    
    func handleEditTapped(_ header: ProfileHeader) {
    }
    
    func handleDoneTapped(_ header: ProfileHeader, bioText: String?, newImage: UIImage?) {
        print("CurrentUserController: handleDoneTapped")
        if let bioText = bioText, !bioText.isEmpty {
            print("handleDoneTapped -> Passed bioText iflet")
            header.biotTextView.text = bioText
            AuthService.shared.updateAboutText(aboutText: bioText) { error, ref in
                print("handled updating about text")
            }
            
        }
        
        if let newImage = newImage {
            AuthService.shared.updateUserImage(image: newImage) { error, ref in
                print("handled updating image")
            }
        }
        self.editMode = false
    }
    
    func handleSettingsTapped(_ header: ProfileHeader) {
        let controller = SettingsController(currentUser: currentUser)
        self.navigationController?.pushViewController(controller, animated: true)
        //        let alert = self.setupSettings()
//        self.present(alert, animated: true, completion: nil)
        
    }
    
    func handleBackTapped(_ header: ProfileHeader) {
//        let transition:CATransition = CATransition()
//        transition.duration = 0.5
//        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
//        transition.type = CATransitionType.push
//        transition.subtype = .fromRight
//        self.navigationController?.view.layer.add(transition, forKey: kCATransition)
        self.navigationController?.popViewController(animated: true)
    }
    
    func handleLogout(_ header: ProfileHeader) {
        AuthService.shared.logoutUser()
            self.presentLogin()
    
    }
    
    func imageViewTapped(_ header: ProfileHeader) {
        self.present(imagePicker, animated: true) {
            print("Done with image picker")
        }
    }
    
    @objc func removeCell(cell: NetworkJustCell) {
        let i = cell.tag
        justs.remove(at: i)
        collectionView.reloadData()
    }
    
    // MARK: - Long Press Alert
    
    func longPressAlert(currentUser: Bool, cell: NetworkJustCell) -> UIAlertController {
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        if currentUser == true {
            let alert = UIAlertController(title: "Delete", message: "You sure you want to delete this just?", preferredStyle: .alert)
            let deleteAction = UIAlertAction(title: "Delete", style: .default) { action in
                self.removeCell(cell: cell)
            }
            alert.addAction(deleteAction)
            alert.addAction(cancelAction)
            return alert
            
        } else {
            let alert = UIAlertController(title: "Report", message: "Would you like to report this just?", preferredStyle: .alert)
            let reportAction = UIAlertAction(title: "Report Just", style: .default, handler: nil)
            alert.addAction(reportAction)
            alert.addAction(cancelAction)
            return alert
        }
    }
    
    
}

// MARK: UICollectionViewDelegateFlowLayout

extension CurrentUserController: UICollectionViewDelegateFlowLayout {
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! ProfileHeader
        if isUser == true {
            print("isUser == true")
            header.user = self.user
            header.isUser = true
            header.delegate = self
        } else if isUser == false {
            print("isUser == not true")
            header.isUser = false
            header.editMode = editMode
            header.user = self.currentUser
            header.pickerDelegate = self
            header.delegate = self
            if let pickedImage = pickedImage {
                header.pickedImage = pickedImage
                print("We have picked image in the current user controller")
                header.delegate = self
            }
        }
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.frame.width, height: 300)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: view.frame.width, height: 120)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20.0, left: 1.0, bottom: 1.0, right: 1.0)
    }
}

// MARK: NetworkJustCellDelegate

extension CurrentUserController: NetworkJustCellDelegate {
    func respectCountTapped(cell: NetworkJustCell) {
        guard let just = cell.just else { return }
        let controller = RespectedByViewController(just: just, currentUser: currentUser)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func didLongPress(cell: NetworkJustCell) {
        guard let just = cell.just else { return }
        
        if just.uid == self.currentUser.uid {
            let alert = self.longPressAlert(currentUser: true, cell: cell)
            self.present(alert, animated: true, completion: nil)
        } else if just.uid != self.currentUser.uid {
            let alert = self.longPressAlert(currentUser: false, cell: cell)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func imageTapped(cell: NetworkJustCell) {
    }
    
    func respectTapped(cell: NetworkJustCell) {
    }
    
    
}

// MARK: - UImagePickerControllerDelegate

extension CurrentUserController: UIImagePickerControllerDelegate {
    
func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
    if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
        print("image picked")
//        self.profileImageView.contentMode = .scaleAspectFit
//        self.profileImageView.image = pickedImage
        self.pickedImage = pickedImage
        photoSelected = true
    }
    picker.dismiss(animated: true) {
        self.collectionView.reloadData()
    }
    
    
}

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        photoSelected = false
    }
}


