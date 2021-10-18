//
//  AuthService.swift
//  PracticeCustomTableViews
//
//  Created by John McCants on 8/10/21.
//

import Foundation
import Firebase
import UIKit

struct AuthCredentials {
    let email: String
    let password: String
    let username: String
    let firstName: String
    let lastName: String
}

struct AuthService {
    
    static let shared = AuthService()
    func logUserIn(withEmail email: String, password: String, completion: AuthDataResultCallback?) {
        
        Auth.auth().signIn(withEmail: email, password: password, completion: completion)
    }
    
    func registerUser(credentials: AuthCredentials, completion: @escaping(Error?, DatabaseReference) -> Void) {
        let email = credentials.email
        let password = credentials.password
        let username = credentials.username
        let firstName = credentials.firstName
        let lastName = credentials.lastName
        let aboutText = ""

                Auth.auth().createUser(withEmail: email, password: password) { result, error in
                    if let error = error {
                        print("DEBUG: Error creating user: \(error)")
                    }
                    guard let uid = result?.user.uid else { return }
                    let network = REF_USERS.child(uid).childByAutoId()
                    guard let networkID = network.key else { return }
                    let values = ["email": email, "username": username, "firstName": firstName, "lastName": lastName,  "networkID": networkID, "aboutText": aboutText]
                    
                    REF_USERS.child(uid).updateChildValues(values, withCompletionBlock: completion)
//                        NetworkService.shared.createNetworkDetails(networkId: networkID, user: User(uid: uid, dictionary: values), completion: completion)
 
                }
    }
    
    
    func logoutUser() {
            do { try Auth.auth().signOut()
            } catch {
                print("Error:")
            }
    }
    
    func updateUserImage(image: UIImage, completion: @escaping(Error?, DatabaseReference) -> Void) {
        guard let compressedImage = image.jpegData(compressionQuality: 0.3) else { return }
        let filename = NSUUID().uuidString
        let storageRef = STORAGE_PROFILE_IMAGES.child(filename)
        
        storageRef.putData(compressedImage, metadata: nil) { (meta, error) in
            if let error = error {
                print("DEBUG: Error putting image data to database \(error)")
            }
            storageRef.downloadURL { url, error in
                guard let profileImageUrl = url?.absoluteString else { return }
                guard let uid = Auth.auth().currentUser?.uid else { return }
                let values = ["profileImageUrl": profileImageUrl]
                
                REF_USERS.child(uid).updateChildValues(values, withCompletionBlock: completion)
                
            }
        }
    }
    
    func updateAboutText(aboutText: String, completion: @escaping(Error?, DatabaseReference) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        REF_USERS.child(uid).updateChildValues(["aboutText": aboutText])
    }
    
    func checkIfUsernameExists(username: String, completion: @escaping(Int) -> Void) {
        REF_USERS.queryOrdered(byChild: "username").queryEqual(toValue: username).observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                completion(1)
            } else {
                completion(0)
            }
        }
    }
    
    func checkIfEmailExists(email: String, completion: @escaping(Int) -> Void) {
        REF_USERS.queryOrdered(byChild: "email").queryEqual(toValue: email).observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                completion(1)
            } else {
                completion(0)
            }
        }
        
    }
 
}
