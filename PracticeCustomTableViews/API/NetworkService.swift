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
    
    func fetchNetworkJustIDs(networkId: String) {
        
    }
    
    func inviteUserToNetwork(toUserUid: String, fromUser: User, completion: @escaping() -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let dict = [uid: fromUser.networkId] as [String: AnyObject]
        REF_NETWORK_INVITES.child(toUserUid).updateChildValues(dict)
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
        let value = [user.uid: user.networkId]
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
    
    func fetchNetworkDetails(networkId: String, completion: @escaping(Network) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        REF_NETWORK_DETAILS.child(networkId).observeSingleEvent(of: .value) { snapshot in
            guard let dictionary = snapshot.value as? [String: AnyObject] else { return }
            let network = Network(networkID: networkId, dictionary: dictionary)
            completion(network)
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
    
    func checkIfUsersInNetwork(networkId: String, userId: String, completion: @escaping(String) -> Void ) {
        guard let currentUser = Auth.auth().currentUser else { return }
        
        REF_NETWORK_USERS.child(networkId).child(userId).observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                completion("Already in the Network")
            } else {
                NetworkService.shared.checkIfUserInvited(toUid: userId, fromUid: currentUser.uid) { string in
                    if string == "Invite Exists" {
                        completion(string)
                    } else {
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
            }
        }
    }

}
