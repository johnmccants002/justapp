//
//  RespectNotification.swift
//  PracticeCustomTableViews
//
//  Created by John McCants on 9/26/21.
//

import Foundation

struct RespectNotification {
    let firstName: String
    let fromUserUid: String
    let justID: String
    var timestamp : Date!
    let username: String
    let respectID: String
    var user: User?
    
    init(respectID: String, dict: [String: Any]) {
        self.respectID = respectID
        self.fromUserUid = dict["fromUserUid"] as? String ?? ""
        self.username = dict["username"] as? String ?? ""
        self.justID = dict["justID"] as? String ?? ""
        self.firstName = dict["firstName"] as? String ?? ""
        
        if let timestamp = dict["timestamp"] as? Double {
            self.timestamp = Date(timeIntervalSince1970: timestamp)
        }

        
    }
}
