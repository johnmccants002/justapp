//
//  Network.swift
//  PracticeCustomTableViews
//
//  Created by John McCants on 8/12/21.
//

import Foundation

struct Network {
    let networkID: String
    let user: User
    var checked: Int
    
    init(networkID: String, checked: Int, user: User) {
        self.networkID = networkID
        self.user = user
        self.checked = checked
    }
}
