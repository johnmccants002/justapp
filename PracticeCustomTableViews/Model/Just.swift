//
//  Just.swift
//  PracticeCustomTableViews
//
//  Created by John McCants on 8/13/21.
//

import Foundation


struct Just {
    var justText: String
    var uid: String
    var timestamp: Date!
    var didRespect: Bool = false
    var firstName: String
    var lastName: String
    var justID: String
    var profileImageUrl: URL?
    var respects: Int = 0
    
    init(justID: String, dictionary: [String: Any]) {
        self.justID = justID
        self.uid = dictionary["uid"] as? String ?? ""
        self.justText = dictionary["justText"] as? String ?? ""
        self.firstName = dictionary["firstName"] as? String ?? ""
        self.lastName = dictionary["lastName"] as? String ?? ""
        self.respects = dictionary["respects"] as? Int ?? 0
        
        if let profileImageUrl = dictionary["profileImageUrl"] as? String {
            guard let url = URL(string: profileImageUrl) else { return }
            self.profileImageUrl = url
        }
        
        if let timestamp = dictionary["timestamp"] as? Double {
            self.timestamp = Date(timeIntervalSince1970: timestamp)
        }
        
    }
    
}
