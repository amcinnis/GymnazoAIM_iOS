//
//  GlobalMovement.swift
//  GymnazoAIM
//
//  Created by Local Account 123-28 on 3/21/17.
//  Copyright © 2017 Austin McInnis. All rights reserved.
//

import Foundation

class GlobalMovement {
    var name: String
    var id: String
    var exercises: [Exercise]
    
    init(id: String, name: String) {
        self.id = id
        self.name = name
        self.exercises = [Exercise]()
    }
}
