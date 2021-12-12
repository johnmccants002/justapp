//
//  AnnouncementService.swift
//  PracticeCustomTableViews
//
//  Created by John McCants on 12/10/21.
//

import Foundation
import UIKit
import Firebase

struct AnnouncementService {
    
    static let shared = AnnouncementService()
    
    func postAnnouncement(announcementText: String, completion: @escaping() -> Void) {
        guard let uid = Auth.auth().currentUser?.uid  else {
            completion()
            return
        }
        
        let ref = REF_USER_ANNOUNCEMENTS.child(uid).childByAutoId()
        guard let announcementID = ref.key else { return }
        
        let values = ["uid": uid, "timestamp": Int(NSDate().timeIntervalSince1970), "announcementText": announcementText, "announcementID": announcementID] as [String: Any]
        
        ref.updateChildValues(values)
        
        
        completion()
    }
    
    func fetchAnnouncements(uid: String, completion: @escaping([Announcement]?) -> Void) {
        var announcements : [Announcement] = [] {
            didSet {
                completion(announcements)
            }
        }
        REF_USER_ANNOUNCEMENTS.child(uid).observeSingleEvent(of: .value) { snapshot in
            
            guard let dict = snapshot.value as? [String: Any] else {
                completion(nil)
                return }
            
            for (key, value) in dict {
                if let dict = value as? [String: Any] {
                    let announcement = Announcement(announcementID: key, dictionary: dict)
                    announcements.append(announcement)
                } else {
                    completion(announcements)
                }
                
            }
            
        }
    }
    
}
