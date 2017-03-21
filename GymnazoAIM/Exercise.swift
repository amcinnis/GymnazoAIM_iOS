//
//  Exercise.swift
//  GymnazoAIM
//
//  Created by Local Account 123-28 on 3/17/17.
//  Copyright © 2017 Austin McInnis. All rights reserved.
//

import Foundation

class Exercise {
    var name: String?
    var id: String?
    var enabledCategories: [String:String]?
    var globalMovement: String?
    var video: Video?
    var creationDate: Date?
    var movementOrganized: Bool?
    
    init() {
        
    }
    
    init(id: String, name: String, globalMovement: String, enabled: [String:String]) {
        self.id = id
        self.name = name
        self.enabledCategories = enabled
        self.globalMovement = globalMovement
        self.movementOrganized = false
    }
    
    func addEnabledCategory(categoryID: String, value: String) {
        if self.enabledCategories == nil {
            self.enabledCategories = [String:String]()
        }
        self.enabledCategories?[categoryID] = value
    }
}
