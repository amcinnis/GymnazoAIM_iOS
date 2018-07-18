//
//  User.swift
//  GymnazoAIM
//
//  Created by Austin McInnis on 7/18/18.
//  Copyright © 2018 Austin McInnis. All rights reserved.
//

import Foundation

public class User {
    
    var name: String?
    var email: String?
    var status: String?
    var lastLogin: String?
    
    init(name: String, email: String, lastLogin: String) {
        self.name = name
        self.email = email
    }
}
