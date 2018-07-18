//
//  Exercise.swift
//  GymnazoAIM
//
//  Created by Local Account 123-28 on 3/17/17.
//  Copyright © 2017 Austin McInnis. All rights reserved.
//

import Foundation

class Exercise {
    var name: String? // Name of exercise
    var databaseID: String? // Firebase identifier
    var databasePath: String? // Realtime Database path
    var storagePath: String? // Storage path
    var globalMovementID: String? // Identifier of Global Movement
    var globalMovementStr: String? // String representation of Global Movement
    var enabledCategories: [String:String]? // Dictionary containing enabled categories with identifiers
    var video: Video? // Video object
    var creationDate: Date? // Date created
    var movementOrganized: Bool? // Toggle of movement organization
    var notes: String? // Notes associated with Exercise
    
    init() {
        
    }
    
    init(databaseID: String, name: String, globalMovementID: String,
         globalMovementStr: String, databasePath: String, storagePath: String,
         enabled: [String:String]) {
        self.databaseID = databaseID
        self.name = name
        self.enabledCategories = enabled
        self.globalMovementID = globalMovementID
        self.globalMovementStr = globalMovementStr
        self.databasePath = databasePath
        self.storagePath = storagePath
        self.movementOrganized = false
    }
    
    func addEnabledCategory(categoryID: String, value: String) {
        if self.enabledCategories == nil {
            self.enabledCategories = [String:String]()
        }
        self.enabledCategories?[categoryID] = value
    }
}
