//
//  Announcement.swift
//  PracticeCustomTableViews
//
//  Created by John McCants on 12/8/21.
//

import Foundation
import UIKit
 

struct Announcement {
    var announcementText: String
    var announcementImageUrl: URL?
    var announcementID: String
    var timestamp: Date
    var dateString: String?
    var uid: String
    
    
    init(announcementID: String, dictionary: [String: Any]) {
        self.announcementID = announcementID
        self.uid = dictionary["uid"] as! String
        self.announcementText = dictionary["announcementText"] as! String
        if let timestamp = dictionary["timestamp"] as? Double {
            self.timestamp = Date(timeIntervalSince1970: timestamp)
        } else {
            self.timestamp = Date()
        }
        
        if let timestamp = dictionary["timestamp"] as? Double {
            self.timestamp = Date(timeIntervalSince1970: timestamp)
            let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MM/dd/yy"
            let date = Date()
            let yesterday = date.dayBefore
            let todaysDateString = dateFormatter.string(from: date)
            let yesterdayDateString = dateFormatter.string(from: yesterday)
            let justDateString = dateFormatter.string(from: self.timestamp)
            if todaysDateString == justDateString {
                self.dateString = "Today"
            } else if yesterdayDateString == justDateString {
                self.dateString = "Yesterday"
            } else {
                self.dateString = dateFormatter.string(from: self.timestamp)
            }
           
       
        }
}
}

extension Announcement: Hashable {
    
}
