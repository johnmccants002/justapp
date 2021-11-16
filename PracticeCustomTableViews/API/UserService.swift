//
//  UserService.swift
//  PracticeCustomTableViews
//
//  Created by John McCants on 8/10/21.
//

import Foundation
import Firebase

struct UserService {
    static let shared = UserService()
    
    func fetchUser(uid: String, completion: @escaping(User) -> Void) {
        print("DEBUG: Fetch Current User Info")
        REF_USERS.child(uid).observeSingleEvent(of: .value) { (snapshot) in
            
            guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
            
            let user = User(uid: uid, dictionary: dictionary)
            completion(user)
        }
    }
    
    
    func searchUsername(username: String, completion:@escaping(User?, Bool) -> Void) {
        
        REF_USERS.queryOrdered(byChild: "username").queryEqual(toValue: username).observeSingleEvent(of: .value) { snapshot in
            
            if snapshot.exists() == false {
                completion(nil, false)
            }
            for item in snapshot.children {

                     guard let item = item as? DataSnapshot else {
                        break
                     }

                     //"name" is a key for name in FirebaseDatabese model
                     if let dict = item.value as? [String: Any], let username = dict["username"] as? String {
                        if username == username {
                            let user = User(uid: item.key, dictionary: dict)
                            completion(user, true)
                            print("This is the usernames first and last name: \(user.firstName) \(user.lastName)")
                        } else {
                            completion(nil, false)
                        }
                        
                     }
                 }
        }
    }
    
    func fetchUserRespect(uid: String, completion: @escaping([RespectNotification]) -> Void) {
        
        var respectNotifications : [RespectNotification] = []
        
        REF_USER_RESPECTS.child(uid).observeSingleEvent(of: .value) { snapshot in
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            print("This is respect dictionary: \(dictionary)")
            for (key, value) in dictionary {
                guard let dict = value as? Dictionary<String, Any> else {return}
                print("this is the dict passed the guard statement : \(dict)")
                var respectNotification = RespectNotification(respectID: key, dict: dict)
                respectNotifications.append(respectNotification)
            }
            completion(respectNotifications)
        }
        
    }
    
    func fetchUserToken(uid: String, completion: @escaping(String) -> Void) {
        FIRESTORE_DB_REF.collection("users_table").document(uid).getDocument { snapshot, err in
            if let err = err {
                print("ERROR FETCHING USER TOKEN: \(err)")
            }
            
            let dict = snapshot?.data() as? [String: String]
            
            let token = dict?["fcmToken"]
            print(dict)
            completion(token ?? "Nothing")
        }
    }
    
    func fetchProfileImage(uid: String, completion: @escaping(URL?) -> Void) {
        
        REF_USERS.child(uid).child("profileImageUrl").observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() == false {
                completion(nil)
            }
            let imageUrlString = snapshot.value as? String
            
            guard let imageUrlString = imageUrlString else { return }
            let imageURL = URL(string: imageUrlString)
            
            guard let imageURL = imageURL else {
                return }
            
            completion(imageURL)
        }
        
    }
    
    func checkUncheckInvites(string: String, uid: String) {
        if string == "check" {
            REF_CHECKED_INVITES.child(uid).setValue(true)
            
        } else if string == "uncheck" {
            REF_CHECKED_INVITES.child(uid).setValue(false)
        }
        
    }
    
    func checkUncheckRespects(string: String, uid: String) {
        if string == "check" {
            REF_CHECKED_RESPECT.child(uid).setValue(true)
        } else if string == "uncheck" {
            REF_CHECKED_RESPECT.child(uid).setValue(false)
        }
        
    }
    
    func fetchCheckedRespect(uid: String, completion: @escaping(String) -> Void) {
        REF_CHECKED_RESPECT.child(uid).observeSingleEvent(of: .value) { snapshot in
            let value = snapshot.value as? Bool
            
            if value == false {
                completion("New Respects!")
            } else if value == true {
                completion("Respects")
            }
        }
        
    }
    
    func fetchCheckedInvites(uid: String, completion: @escaping(String) -> Void) {
        REF_CHECKED_INVITES.child(uid).observeSingleEvent(of: .value) { snapshot in
            let value = snapshot.value as? Bool
            
            if value == false {
                completion("New Invites!")
            } else if value == true {
                completion("Invites")
            }
        }
        
    }
    
    func fetchTotalRespect(uid: String, completion:@escaping(String) -> Void) {
        REF_USER_RESPECTS.child(uid).observeSingleEvent(of: .value) { snapshot in
            let count = snapshot.childrenCount
            
            let countString = "\(count)"
            completion(countString)
        }
    }
    
    func fetchSharedNetworks(currentUserArray: [User], user: User, completion:@escaping([User]) -> Void) {
      
        var sharedArray: [User] = []
     
        
        NetworkService.shared.fetchCurrentUserNetworks(currentUser: user) { users in
            if users.isEmpty {
                completion(sharedArray)
            }
            for user in currentUserArray {
                
                if users.contains(user) {
                    sharedArray.append(user)
                }
           
            }
            completion(sharedArray)
            
        }
   
            print("This is the shared array: \(sharedArray)")
            
        
        
        
    }
    
}
