//
//  PushNotificationService.swift
//  PracticeCustomTableViews
//
//  Created by John McCants on 10/5/21.
//

import UIKit
class PushNotificationSender {
    
    static let shared = PushNotificationSender()
    
    func sendPushNotification(to token: String, title: String, body: String, id: String) {
        let urlString = "https://fcm.googleapis.com/fcm/send"
        let url = NSURL(string: urlString)!
        let paramString: [String : Any] = ["to" : token,
                                           "notification" : ["title" : title, "body" : body],
                                           "data" : ["user" : id]
        ]
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject:paramString, options: [.prettyPrinted])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("key=AAAAJDjXFz0:APA91bG4VIqtpyNQX_bfynOd0d4rKlQCx6bc3y9gA5dxUZTbT7bn3pYLQdrSE3BwT8Mze2q-4ODtHrmstmvunbVcD9vHLb1jvZqs7x6TUfIbNOruGb8T4sd1fYyuUd13T2wjTZGGlNvA", forHTTPHeaderField: "Authorization")
        let task =  URLSession.shared.dataTask(with: request as URLRequest)  { (data, response, error) in
            do {
                if let jsonData = data {
                    if let jsonDataDict  = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] {
                        NSLog("Received data:\n\(jsonDataDict))")
                    }
                }
            } catch let err as NSError {
                print(err.debugDescription)
            }
        }
        task.resume()
    }
}
