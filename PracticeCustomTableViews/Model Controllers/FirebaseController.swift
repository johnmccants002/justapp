//
//  FirebaseController.swift
//  PracticeCustomTableViews
//
//  Created by John McCants on 5/26/21.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

enum NetworkError: Error {
    case noData
    case failedSignUp
    case failedSignIn
    case noToken
    case tryAgain
    case failedDecoding
    case failedEncoding
    case failedResponse
    case noIdentifier
    case noRep
    case otherError
}

class FirebaseController {
    
    private let firebaseURL = "https://justapp-e9937-default-rtdb.firebaseio.com/"
    
    let ref = Database.database().reference()
    var currentUser: User?
    var delegate : FirebaseControllerDelegate?
    static let shared = FirebaseController()
    private init() {}
    
    func createUser(email: String, password: String, username: String, firstName: String, lastName: String, completionBlock: @escaping (_ success: Bool) -> Void) {
        print("Firebase Create User Firing")
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let authResult = authResult {
                print("we got an authResult")
                let dict: [String: Any] =
                [
                    "uid" : authResult.user.uid,
                    "username": username,
                    "email": email,
                    "firstName": firstName,
                    "lastName": lastName,
                    "aboutText": ""
                ]
                self.currentUser = User(username: username, email: email, uid: authResult.user.uid, aboutText: "", firstName: firstName, lastName: lastName)
                Database.database().reference().child("users").child(authResult.user.uid).updateChildValues(dict) { error, _ in
                    if error == nil {
                        print("User Signed Up")
                    }
                }
                completionBlock(true)
            } else {
                completionBlock(false)
                print("Create User Block False")
            }
        }
        
    }
    
    func loginUser(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { authDataResult, error in
            if error != nil {
                self.delegate?.presentAlert(firebaseController: self)
            }
            guard let authDataResult = authDataResult else { return }
            self.ref.child("users/\(authDataResult.user.uid)").getData { (error, snapshot) in
                if let error = error {
                    print("Error getting data \(error)")
                    self.delegate?.presentAlert(firebaseController: self)
                }
                else if snapshot.exists() {
                    print("Got data \(snapshot.value!)")
                    let userDict = snapshot.value as? [String: Any] ?? [:]
                    self.currentUser = User(username: userDict["username"] as! String, email: userDict["email"] as! String, uid: userDict["uid"] as! String, aboutText: userDict["aboutText"] as! String, firstName: userDict["firstName"] as! String, lastName: userDict["lastName"] as! String)
                    self.delegate?.loginUser(firebaseController: self)
                }
                else {
                    print("No data available")
                }
            }
        }
    }
    
    func logout() {
        do { try Auth.auth().signOut()
            self.delegate?.logoutUser(firebaseController: self)
        } catch {
            print("Error:")
        }
}
}

protocol FirebaseControllerDelegate {
    func loginUser(firebaseController: FirebaseController)
    
    func presentAlert(firebaseController: FirebaseController)
    
    func logoutUser(firebaseController: FirebaseController)
}

