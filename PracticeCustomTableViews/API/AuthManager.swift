//
//  AuthManager.swift
//  PracticeCustomTableViews
//
//  Created by John McCants on 12/1/21.
//

import Foundation
import Firebase

class AuthManager {
    static let shared = AuthManager()
    
    private let auth = Auth.auth()
    
    private var verificationId: String?
    
    
    public func startAuth(phoneNumber: String, completion: @escaping(Bool) -> Void) {
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { verificationId, err in
            guard let verificationId = verificationId else {
                completion(false)
                return }
            
        }
    }
    
    public func verifyCode(smsCode: String, completion: @escaping(Bool) -> Void) {
        if let verificationId = verificationId {
            let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationId, verificationCode: smsCode)
            
            auth.signIn(with: credential) { result, error in
                guard result != nil, error == nil else { completion(false)
                    return
                }
                completion(true)
            }
        }
    }
}
