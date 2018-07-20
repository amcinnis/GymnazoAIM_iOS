//
//  User.swift
//  GymnazoAIM
//
//  Created by Austin McInnis on 7/18/18.
//  Copyright © 2018 Austin McInnis. All rights reserved.
//

import Foundation

public class User {
    
    var name: String
    var uid: String
    var email: String
    var isAdmin: Bool
    var lastLogin: String
    
    init(name: String, uid: String, email: String, isAdmin: Bool, lastLogin: String) {
        self.name = name
        self.uid = uid
        self.email = email
        self.isAdmin = isAdmin
        self.lastLogin = lastLogin
    }
}
