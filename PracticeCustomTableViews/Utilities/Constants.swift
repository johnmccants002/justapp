//
//  Constants.swift
//  PracticeCustomTableViews
//
//  Created by John McCants on 8/10/21.
//

import Foundation
import Firebase
import FirebaseFirestore

let DB_REF = Database.database().reference()
let FIRESTORE_DB_REF = Firestore.firestore()
let REF_USERS = DB_REF.child("users")
let STORAGE_REF = Storage.storage().reference()
let STORAGE_PROFILE_IMAGES = STORAGE_REF.child("profile_images")
let REF_USER_JUSTS = DB_REF.child("user-justs")
let REF_CURRENT_USER_NETWORKS = DB_REF.child("user-networks")
let REF_NETWORK_USERS = DB_REF.child("network-users")
let REF_NETWORK_JUSTS = FIRESTORE_DB_REF.collection("networks")
let REF_NETWORK_INVITES = DB_REF.child("network-invites")
let REF_REPORT_JUSTS = DB_REF.child("report-justs")
let REF_USER_RESPECTS = DB_REF.child("user-respects")
let REF_JUST_RESPECTS = DB_REF.child("just-respects")
//let REF_USER_NETWORKS = DB_REF.child("user-networks")
let REF_NETWORK_DETAILS = DB_REF.child("network-details")


