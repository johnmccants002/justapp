//
//  User.swift
//  PracticeCustomTableViews
//
//  Created by John McCants on 5/11/21.
//

import Foundation
import Firebase

struct User {
    var username: String
    var email: String
    var uid: String
    var aboutText: String
    var firstName: String
    var lastName: String
    var profileImageUrl: URL?
    var networkId: String
    var userNetworks: [String] = []
    var lastJustMyNetwork: String?
    var lastJustFriendsNetworks: String?
    var respectCount: Int = 0
    var inviteCount: Int = 0
    var changedImage: Bool = false
    var twitterUsername: String?
    var instagramUsername: String?
    var networks: [Network]?
    
    init(uid: String, dictionary: [String: Any]) {
        self.uid = uid
        self.email = dictionary["email"] as? String ?? ""
        self.username = dictionary["username"] as? String ?? ""
        self.aboutText = dictionary["aboutText"] as? String ?? ""
        self.firstName = dictionary["firstName"] as? String ?? ""
        self.lastName = dictionary["lastName"] as? String ?? ""
        self.networkId = dictionary["networkID"] as? String ?? ""
        self.respectCount = dictionary["respectCount"] as? Int ?? 0
        self.inviteCount = dictionary["inviteCount"] as? Int ?? 0
        self.instagramUsername = dictionary["instagram"] as? String ?? ""
        self.twitterUsername = dictionary["twitter"] as? String ?? ""
        
        
        if let profileImageUrl = dictionary["profileImageUrl"] as? String {
            guard let url = URL(string: profileImageUrl) else { return }
            self.profileImageUrl = url
        }
        
    }
}

extension User: Equatable {
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.uid == rhs.uid
    }
    
    
}


