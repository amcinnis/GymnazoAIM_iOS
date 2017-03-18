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
    var enabledCategories: [String:Bool]?
    var video: Video?
    var creationDate: Date?
    
    func addEnabledCategory(categoryID: String, value: Bool) {
        if self.enabledCategories == nil {
            self.enabledCategories = [String:Bool]()
        }
        self.enabledCategories?[categoryID] = value
    }
}

class Category {
    var name: String
    var id: String?
    var value: Bool
    
    init(name: String) {
        self.name = name
        self.value = false
    }
    
    init(name: String, value: Bool) {
        self.name = name
        self.value = value
    }
}
