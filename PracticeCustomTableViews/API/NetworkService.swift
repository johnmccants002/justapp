//
//  NetworkService.swift
//  PracticeCustomTableViews
//
//  Created by John McCants on 8/10/21.
//

import Foundation
import Firebase

struct NetworkService {
    static let shared = NetworkService()
        
    func fetchCurrentUserNetworks(currentUser: User, completion: @escaping([User]) -> Void) {
        print("Fetching current user networks")
        var users : [User] = []
        let myGroup = DispatchGroup()
        REF_CURRENT_USER_NETWORKS.child(currentUser.uid).observeSingleEvent(of: .value) { snapshot in
            print("This is the snapshot \(snapshot)")
            guard let dictionary = snapshot.value as? [String: Any] else { return }
            for (key, value) in dictionary {
                myGroup.enter()
                UserService.shared.fetchUser(uid: key) { user in
                    print("This is user from for loop: \(user)")
                    myGroup.leave()
                    users.append(user)
                }
            }
            myGroup.notify(queue: .main) {
                print("These are the users networks we got \(users)")
            completion(users)
            }
        }
    }
    
    func fetchCurrentUserNetworkUsers(completion:@escaping([String]?) -> Void) {
        var userIds : [String] = []
        guard let uid = Auth.auth().currentUser?.uid else { return }
        REF_CURRENT_USER_NETWORKS.child(uid).observeSingleEvent(of: .value) { snapshot in
            guard let dict = snapshot.value as? [String: Any] else { return }
            print("This is the snapshot in currentUserNetwork: \(dict)")
            for (key,value) in dict {
    
                userIds.append(key)
            }
            completion(userIds)
        }
  
    }
    
    func inviteUserToNetwork(toUserUid: String, fromUser: User, completion: @escaping() -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let dict = [uid: fromUser.networkId] as [String: AnyObject]
        REF_NETWORK_INVITES.child(toUserUid).updateChildValues(dict)
        UserService.shared.checkUncheckInvites(string: "uncheck", uid: toUserUid)
        completion()
    }
    
    func fetchInvites(uid: String, completion: @escaping([User]) -> Void) {
        var users: [User] = []
        let myGroup = DispatchGroup()
        REF_NETWORK_INVITES.child(uid).observeSingleEvent(of: .value) { snapshot in
            guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
     
            for (key, value) in dictionary {
                myGroup.enter()
                UserService.shared.fetchUser(uid: key) { user in
                    myGroup.leave()
                    users.append(user)
                }
            }
            myGroup.notify(queue: .main) {
                completion(users)
            }
            
        }
        
    }
    
    func handleInvite(user: User, choice: Bool, currentUser: User, completion: @escaping(DatabaseCompletion)) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let dict = ["networkId": user.networkId,
        "checked": 0] as [String: Any]
        let value = [user.uid: dict]
        let value2 = [currentUser.uid: 1]
        if choice == true {
            REF_CURRENT_USER_NETWORKS.child(uid).updateChildValues(value) { error, ref in
                REF_NETWORK_USERS.child(user.networkId).updateChildValues(value2)
                REF_NETWORK_INVITES.child(uid).child(user.uid).removeValue(completionBlock: completion)
            }
        } else if choice == false {
            REF_NETWORK_INVITES.child(uid).child(user.uid).removeValue(completionBlock: completion)
        }
    }
    
    func checkedUncheckedNetworks(users: [User], currentUser: User, completion:@escaping([Network]) -> Void) {
        var uncheckedNetworks: [Network] = []
        var checkedNetworks: [Network] = []
        let myGroup = DispatchGroup()
        
        for user in users {
            myGroup.enter()
            REF_CURRENT_USER_NETWORKS.child(currentUser.uid).child(user.uid).child("checked").observeSingleEvent(of: .value) { snapshot in
                guard let value = snapshot.value as? Int else { return }
                if value == 1 {
                    let network = Network(networkID: user.networkId, checked: value, user: user)
                    uncheckedNetworks.append(network)
                } else if value == 0 {
                    let network = Network(networkID: user.networkId, checked: value, user: user)
                    checkedNetworks.append(network)
                }
                myGroup.leave()
            }
            
        }
        myGroup.notify(queue: .main) {
            let allNetworks = uncheckedNetworks + checkedNetworks
            completion(allNetworks)
        }
 
    }
    
    func createNetworkDetails(networkId: String, user: User, completion: @escaping(DatabaseCompletion)) {
        let values = ["uid": user.uid,
                      "firstName": user.firstName,
                      "lastName": user.lastName,
                      "membersCount": 1
        ] as [String: AnyObject]
        REF_NETWORK_DETAILS.child(networkId).updateChildValues(values)
    }
    
    func checkNetwork(network: Network) {
        guard let currentUser = Auth.auth().currentUser else { return }
        let value = 0
        REF_CURRENT_USER_NETWORKS.child(currentUser.uid).child(network.user.uid).child("checked").setValue(value)
    }
    
    func uncheckNetworks(networks: [Network]?, yourNetworkUserIds: [String]?) {
        guard let currentUser = Auth.auth().currentUser else { return }
        let value = 1
        if let networks = networks {
            for network in networks {
                REF_CURRENT_USER_NETWORKS.child(network.user.uid).child(currentUser.uid).child("checked").setValue(value)
            }
        }
        
        
    }
    
    func checkIfUsersInNetwork(networkId: String, userId: String, completion: @escaping(String) -> Void ) {
        guard let currentUser = Auth.auth().currentUser else { return }
        REF_NETWORK_USERS.child(networkId).child(userId).observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                completion("Already in the Network")

            } else {
                
                NetworkService.shared.checkIfUserInvited(toUid: userId, fromUid: currentUser.uid) { string in
                    if string == "Invite Exists" {
                        completion("Invite Exists")
                     
                    } else {
                        print("Not in Network")
                        completion("Not in Network")
                      
                    }
                }
            }
        }
    }
    
    func checkIfUserInvited(toUid: String, fromUid: String, completion: @escaping(String) -> Void) {
        guard let currentUser = Auth.auth().currentUser else { return }
        print("checkifUserInvited called")
        REF_NETWORK_INVITES.child(toUid).child(fromUid).observeSingleEvent(of: .value) { snapshot in
            
            if snapshot.exists() {
                completion("Invite Exists")
            } else {
                completion("Invite Does Not Exist")
            }
        }
    }

}
