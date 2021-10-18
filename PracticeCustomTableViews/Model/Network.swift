//
//  Network.swift
//  PracticeCustomTableViews
//
//  Created by John McCants on 8/12/21.
//

import Foundation

struct Network {
    let networkID: String
    let uid: String
    var membersCount: Int
    let firstName: String
    let lastName: String
    
    init(networkID: String, dictionary: [String: Any]) {
        self.networkID = networkID
        self.firstName = dictionary["firstName"] as? String ?? ""
        self.lastName = dictionary["lastName"] as? String ?? ""
        self.membersCount = dictionary["membersCount"] as? Int ?? 1
        self.uid = dictionary["uid"] as? String ?? ""
        
    }
}
