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
    
    func uploadJust(user: User, justText: String, justImage: UIImage?, networks: [Network]?, friendsNetworks: Bool, completion: @escaping(Error?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let ref = REF_USER_JUSTS.childByAutoId()
        guard let justID = ref.key else { return }
        
        let values = ["uid": uid, "timestamp": Int(NSDate().timeIntervalSince1970), "justText": justText, "respects": 0, "firstName": user.firstName, "lastName": user.lastName, "justID": justID, "profileImageUrl": user.profileImageUrl?.absoluteString ?? "blank"] as [String: Any]
        
        
        ref.updateChildValues(values)
        print("this is the user network id : \(user.networkId)")
            REF_NETWORK_JUSTS.document(user.networkId).collection("justs").document(justID).setData(values)
            REF_NETWORK_JUSTS.document(user.networkId).collection("last-justs").document(uid).setData(values)
        
        if let justImage = justImage {
            print("we have justimage")
            uploadJustImage(image: justImage, friendsNetworks: friendsNetworks, networks: networks, justID: justID, user: user) { err in
                print(err)
            }
        }
   
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
    
    func uploadJustImage(image: UIImage, friendsNetworks: Bool, networks: [Network]?, justID: String, user: User, completion: @escaping(Error?) -> Void) {
        guard let compressedImage = image.jpegData(compressionQuality: 0.3) else { return }
        let filename = NSUUID().uuidString
        let storageRef = STORAGE_JUST_IMAGES.child(filename)
        
        storageRef.putData(compressedImage, metadata: nil) { (meta, error) in
            if let error = error {
                print("DEBUG: Error putting image data to database \(error)")
            }
            storageRef.downloadURL { url, error in
                guard let justImageUrl = url?.absoluteString else { return }
                guard let uid = Auth.auth().currentUser?.uid else { return }
                let values = ["justImageUrl": justImageUrl]
                let ref = REF_USER_JUSTS.child(justID)
                ref.updateChildValues(values)
                
                REF_NETWORK_JUSTS.document(user.networkId).collection("justs").document(justID).updateData(values)
                REF_NETWORK_JUSTS.document(user.networkId).collection("last-justs").document(uid).updateData(values)
                
                if friendsNetworks == true {
                    guard let networks = networks else { return }
                    print("passed the first loop guard")
                for network in networks {
                    print("in the first loop")
                    REF_NETWORK_JUSTS.document(network.networkID).collection("last-justs").document(uid).updateData(values) { err in
                        REF_NETWORK_JUSTS.document(network.networkID).collection("justs").document(justID).updateData(values)
                    }
                }
                    completion(nil)
                } else {
                    completion(nil)
                }
                
            }
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
    
    func deleteJust(networkIDs: [String], justID: String, uid: String, currentUserNetworkID: String, completion: @escaping()-> (Void)) {
       
        print("these are the networkIDs : \(networkIDs)")
        let firstGroup = DispatchGroup()
        let secondGroup = DispatchGroup()
        firstGroup.enter()
        DispatchQueue.main.async {
        for networkID in networkIDs {
            print("1")
            REF_NETWORK_JUSTS.document(networkID).collection("justs").document(justID).getDocument { snapshot, err in
                guard let snapshot = snapshot else { return }
                if snapshot.exists {
                    REF_NETWORK_JUSTS.document(networkID).collection("justs").document(justID).delete { error in
                        if let error = error {
                            print("DEBUG Error Deleting: \(error)")
                        }
                    }
                }
                
            
            }
            REF_NETWORK_JUSTS.document(networkID).collection("last-justs").document(justID).delete { error in
                if let error = error {
                    print(error.localizedDescription)
                }
           
            }
        }
        firstGroup.leave()
    }
            
            
        REF_NETWORK_JUSTS.document(currentUserNetworkID).collection("justs").document(justID).delete()
        REF_NETWORK_JUSTS.document(currentUserNetworkID).collection("last-justs").document(justID).delete()
        REF_USER_JUSTS.child(justID).removeValue()
        
        REF_JUST_RESPECTS.child(justID).removeValue()
      

        REF_USER_RESPECTS.child(uid).observeSingleEvent(of: .value) { snapshot in
            
            guard let dict = snapshot.value as? [String: [String: Any]] else { return }
            
            for (key, value) in dict {
                secondGroup.enter()
                for (key2, value2) in value {
                    print("2")
                    if let value2 = value2 as? String {
                        if key2 == "justID" && value2 == justID {
                            print("This is what should be deleted: \(key2), \(value2)")
                            REF_USER_RESPECTS.child(uid).child(key).removeValue()
                        }
                    }
                }
               
            }
            secondGroup.leave()
        }
            
        
        secondGroup.notify(queue: .main) {
            completion()
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
            let firstString = "just "
            guard let snapshot = snapshot else { return }
            if snapshot.isEmpty {
                completion([])
            }
            for document in snapshot.documents {
                let dict = document.data() as [String: AnyObject]
                var just = Just(justID: dict["justID"] as! String, dictionary: dict)
                just.dateString = "Justs"
                let secondString = just.justText
                just.justText = firstString + secondString
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
        print("This is the justID: \(just.justID)")
        
        
        var users: [User] = []
        let myGroup = DispatchGroup()
        REF_JUST_RESPECTS.child(just.justID).observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() == false {
                completion([])
            }
            print("this is the snapshot: \(snapshot.value)")
            guard let dict = snapshot.value as? [String: Any] else { return }
            print("passed respected by guard")
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
    
    func fetchSingleJust(justID: String, completion: @escaping(Just?) -> Void) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        REF_USER_JUSTS.child(justID).observeSingleEvent(of: .value) { snapshot in
            guard let dict = snapshot.value as? [String: Any] else { return }
            let just = Just(justID: justID, dictionary: dict)
            completion(just)
        }
    }
    
    func fetchAllNetworkJusts(networkId: String, completion: @escaping([Just]) -> Void) {
        var networkJusts: [Just] = []
        var lastJustIds : [String] = ["", "", ""]
        
        REF_NETWORK_JUSTS.document(networkId).collection("justs").getDocuments { snapshot, error in
            
           
            
            guard let snapshot = snapshot else { return }
           
            for document in snapshot.documents {
                let dict = document.data() as [String: Any]
                let just = Just(justID: document.documentID, dictionary: dict)
                networkJusts.append(just)
                
            }
        }
            let sortedJusts = networkJusts.sorted(by: {
                $0.timestamp.compare($1.timestamp) == .orderedDescending
            })
            completion(sortedJusts)
        
    }
    
    func testGrabAllJusts(lastJustIds: [String], networkId: String, completion: @escaping([Just]) -> Void) {
        print("These are the lastJustIds: \(lastJustIds)")
        var allJusts: [Just] = []
        REF_NETWORK_JUSTS.document(networkId).collection("justs").whereField("justID", notIn: lastJustIds).getDocuments { snapshot, error in
            print("These are the snapshot documents: \(snapshot?.documents)")
            guard let snapshot = snapshot else { return }
            for document in snapshot.documents {
                let dict = document.data() as [String: Any]
                let just = Just(justID: document.documentID, dictionary: dict)
                allJusts.append(just)
            }
            let sortedJusts = allJusts.sorted(by: {
                $0.timestamp.compare($1.timestamp) == .orderedDescending
            })
            completion(sortedJusts)
        }
        
    }
    
    func grabAllJusts(networkId: String, completion: @escaping([Just]) -> Void) {
        var allJusts: [Just] = []
        REF_NETWORK_JUSTS.document(networkId).collection("justs").getDocuments { snapshot, error in
            guard let snapshot = snapshot else { return }
            for document in snapshot.documents {
                let dict = document.data() as [String: Any]
                let just = Just(justID: document.documentID, dictionary: dict)
                allJusts.append(just)
            }
            let sortedJusts = allJusts.sorted(by: {
                $0.timestamp.compare($1.timestamp) == .orderedDescending
            })
            completion(sortedJusts)
        }
    }
    
    func fetchTodaysJustsCount(networkId: String, uid: String, completion: @escaping(Int) -> Void) {
        var count = 0
        let beginningToday = NSCalendar.current.startOfDay(for: Date()).timeIntervalSince1970
        let double = Double(beginningToday)
        
       REF_NETWORK_JUSTS.document(networkId).collection("justs").whereField("uid", isEqualTo: uid).getDocuments(completion: { snapshot, error in
        if error != nil {
            completion(0)
        }
        if let snapshot = snapshot {
            for document in snapshot.documents {
                if let dict = document.data() as? [String: Any] {
                    if dict["timestamp"] as! Double >= double {
                      print("This dict passes the argument: \(dict)")
                       count += 1
                        if count >= 3 {
                            completion(3)
                        }
                    }
                }
            }
            completion(count)
            
        } else {
            completion(count)
        }
        })
    }
}

