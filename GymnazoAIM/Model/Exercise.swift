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
    var databaseID: String?
    var databasePath: String?
    var storagePath: String?
    var globalMovementID: String?
    var globalMovementStr: String?
    var enabledCategories: [String:String]?
    var video: Video?
    var creationDate: Date?
    var movementOrganized: Bool?
    var notes: String?
    
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
