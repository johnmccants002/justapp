//
//  AppDelegate.swift
//  PracticeCustomTableViews
//
//  Created by John McCants on 5/4/21.
//

import UIKit
import Firebase
import UserNotifications
import FirebaseMessaging
@main
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {
    

    var window: UIWindow?
    
    let gcmMessageIDKey = "gcm.message_id"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        
        FirebaseApp.configure()
//        let options = FirebaseOptions(googleAppID: "1:155572442941:ios:b1be7105ca3a0001e79754", gcmSenderID: "155572442941")
//        options.bundleID = "com.john.JustAppBeta"
//        options.apiKey = "AIzaSyAUW3uulJnJu626EMzYHHgAPNzlKmXFxOU"
//        options.projectID = "justapp-e9937"
//        options.clientID = "155572442941-qhvlsf6bjut13j8oca5je9gjkpg95uob.apps.googleusercontent.com"
//        FirebaseApp.configure(options: options)
        Messaging.messaging().delegate = self

        
        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
    if let messageID = userInfo[gcmMessageIDKey] {
    print("Message ID: \(messageID)")
    }
    print(userInfo)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
    fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        Messaging.messaging().appDidReceiveMessage(userInfo)
    if let messageID = userInfo[gcmMessageIDKey] {
    print("Message ID: \(messageID)")
    }
        print(userInfo)
        completionHandler(UIBackgroundFetchResult.newData)
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func application(
      _ application: UIApplication,
      didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        
        Messaging.messaging().apnsToken = deviceToken
//        print("APNs token retrieved: \(deviceToken)")
//        guard var apnsToken = Messaging.messaging().apnsToken else { return }
//        apnsToken = deviceToken
//        print("This is the token: \(apnsToken)")
    }
    
    func application(
      _ application: UIApplication,
      didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
      print("Failed to register: \(error)")
    }


}

@available(iOS 10, *)
extension AppDelegate {
func userNotificationCenter(_ center: UNUserNotificationCenter,willPresent notification: UNNotification,withCompletionHandler completionHandler: @escaping(UNNotificationPresentationOptions) -> Void) {
let userInfo = notification.request.content.userInfo
    Messaging.messaging().appDidReceiveMessage(userInfo)
if let messageID = userInfo[gcmMessageIDKey] {
print("Message ID: \(messageID)")
}
    completionHandler([[.banner, .sound]])
}
func userNotificationCenter(_ center: UNUserNotificationCenter,didReceive response: UNNotificationResponse,withCompletionHandler completionHandler: @escaping () -> Void) {
let userInfo = response.notification.request.content.userInfo
if let messageID = userInfo[gcmMessageIDKey] {
print("Message ID: \(messageID)")
}
print(userInfo)
completionHandler()
}
}

extension AppDelegate {

func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
print("Firebase registration token: \(fcmToken)")
    
    
    Messaging.messaging().token { token, error in
      if let error = error {
        print("Error fetching FCM registration token: \(error)")
      } else if let token = token {
        print("FCM registration token: \(token)")
        let dataDict:[String: String] = ["token": token]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
      } else {
        guard let fcmToken = fcmToken else { return }
        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(
          name: Notification.Name("FCMToken"),
          object: nil,
          userInfo: dataDict
        )
      }
    }
    
        
    
}
}

