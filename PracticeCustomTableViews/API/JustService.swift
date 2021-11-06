//
//  JustService.swift
//  PracticeCustomTableViews
//
//  Created by John McCants on 8/10/21.
//

import Foundation
import Firebase

typealias DatabaseCompletion = ((Error?, DatabaseReference) -> Void)

struct JustService {
    static let shared = JustService()
    
    func uploadJust(user: User, justText: String, networks: [Network]?, friendsNetworks: Bool, completion: @escaping(Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let ref = REF_USER_JUSTS.childByAutoId()
        guard let justID = ref.key else { return }
        
        let values = ["uid": uid, "timestamp": Int(NSDate().timeIntervalSince1970), "justText": justText, "respects": 0, "firstName": user.firstName, "lastName": user.lastName, "justID": justID, "profileImageUrl": user.profileImageUrl?.absoluteString ?? "blank"] as [String: Any]
        
        
        ref.updateChildValues(values)
        print("this is the user network id : \(user.networkId)")
            REF_NETWORK_JUSTS.document(user.networkId).collection("justs").document(justID).setData(values)
            REF_NETWORK_JUSTS.document(user.networkId).collection("last-justs").document(uid).setData(values)
        
   
            if friendsNetworks == true {
                guard let networks = networks else { return }
                print("passed the first loop guard")
            for network in networks {
                print("in the first loop")
                REF_NETWORK_JUSTS.document(network.networkID).collection("last-justs").document(uid).setData(values) { err in
                    REF_NETWORK_JUSTS.document(network.networkID).collection("justs").document(justID).setData(values)
                }
            }
                completion(nil)
            } else {
                completion(nil)
            }
        
        
     

    }
    
    func fetchJusts(networkID: String, completion:@escaping ([Just], Error?) -> Void) {
        var userJusts = [Just]()
        REF_NETWORK_JUSTS.document(networkID).collection("justs").getDocuments { snapshot, error in
            if let error = error {
                print("DEBUG: Error getting Justs: \(error)")
            } else {
                for document in snapshot!.documents {
                    let dict = document.data() as [String: Any]
                    let just = Just(justID: dict["justID"] as! String, dictionary: dict)
                    userJusts.append(just)
                }
                completion(userJusts, nil)
            }
        }
    }
    
    func fetchUserJusts(networkId: String, userUid: String, completion:@escaping ([Just]) -> Void) {
        var userJusts = [Just]()
        REF_NETWORK_JUSTS.document(networkId).collection("justs").whereField("uid", isEqualTo: userUid).getDocuments { snapshot, error in
            guard let snapshot = snapshot else { return }
            for document in snapshot.documents {
                let dict = document.data() as [String: Any]
                let just = Just(justID: document.documentID, dictionary: dict)
                userJusts.append(just)
            }
            completion(userJusts)
        }
    }
    
    func deleteJust(networkIDs: [String], justID: String, uid: String) {
        for networkID in networkIDs {
            REF_NETWORK_JUSTS.document(networkID).collection("justs").document(justID).delete { error in
                if let error = error {
                    print("DEBUG Error Deleting: \(error)")
                }
                
                REF_USER_JUSTS.child(uid).child(justID).removeValue()
            }
        }
    }
    
    func reportJust(justID: String, uid: String) {
        let values = [justID: uid]
        REF_REPORT_JUSTS.child(justID).updateChildValues(values)
        
    }
    
    func respectJust(just: Just, currentUser: User, completion: @escaping(DatabaseCompletion)) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        if just.didRespect {
            // remove respect from firebase
            print("removing respect from db")
            REF_USER_RESPECTS.child(just.uid).child(uid).removeValue() { error, ref in
                REF_JUST_RESPECTS.child(just.justID).removeValue()
            }
            
            
        } else {
            print("adding respect to db")
            REF_JUST_RESPECTS.child(just.justID).updateChildValues([uid: 1]) { error, ref in
                if just.uid != currentUser.uid {
                    postToUserRespects(just: just, currentUser: currentUser)
                    UserService.shared.checkUncheckRespects(string: "uncheck", uid: just.uid)
                    
                }
            }
            }
            
        }
    
    func checkIfUserRespected(just: Just, completion: @escaping(Bool) -> Void) {
        print("Checking if user repected")
        guard let uid = Auth.auth().currentUser?.uid else { return }
        REF_JUST_RESPECTS.child(just.justID).child(uid).observeSingleEvent(of: .value) { snapshot in
            print(snapshot)
            completion(snapshot.exists())
        }
        
    }
    
    func fetchLastJusts(networkID: String, completion: @escaping([Just]) -> Void) {
        var lastJusts : [Just] = []
        REF_NETWORK_JUSTS.document(networkID).collection("last-justs").getDocuments { snapshot, error in
            guard let snapshot = snapshot else { return }
            for document in snapshot.documents {
                let dict = document.data() as [String: AnyObject]
                let just = Just(justID: dict["justID"] as! String, dictionary: dict)
                lastJusts.append(just)
            }
            completion(lastJusts)
        }
    
        
    }
    
    func updateLastJusts(networkId: String, justID: String, dict: [String: Any]) {
        REF_NETWORK_JUSTS.document(networkId).collection("last-justs").document(justID).delete { error in
            if let error = error {
                print("DEBUG Error Updating Last Just: \(error)")
            }
            REF_NETWORK_JUSTS.document(networkId).collection("justs").document(justID).setData(dict)
        }
    }
    
    func postToUserRespects(just: Just, currentUser: User) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let values: [String: Any] = ["timestamp": Int(NSDate().timeIntervalSince1970),
                                     "fromUserUid": uid,
                                     "username": currentUser.username,
                                     "firstName": currentUser.firstName,
                                     "justID": just.justID]
        REF_USER_RESPECTS.child(just.uid).childByAutoId().updateChildValues(values)
    }
    
    
    func fetchJustRespects(just: Just, completion: @escaping(Double?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        REF_JUST_RESPECTS.child(just.justID).observeSingleEvent(of: .value) { snapshot in
            print("this is the snapshot from fetchJustRespects: \(snapshot)")
            let sum = snapshot.childrenCount
            let count = Double(exactly: sum)
            
            completion(count)
            
        }
    }
    
    func fetchRespectedBy(just: Just, completion: @escaping([User]) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        var users: [User] = []
        let myGroup = DispatchGroup()
        REF_JUST_RESPECTS.child(just.justID).observeSingleEvent(of: .value) { snapshot in
            guard let dict = snapshot.value as? [String: Any] else { return }
            
            for (key, value) in dict {
                myGroup.enter()
                UserService.shared.fetchUser(uid: key) { user in
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
}

