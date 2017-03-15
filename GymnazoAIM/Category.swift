//
//  Category.swift
//  GymnazoAIM
//
//  Created by Local Account 123-28 on 3/14/17.
//  Copyright © 2017 Austin McInnis. All rights reserved.
//

import Foundation

public class Category {
    
    var focusPoint: String
    var values: [String:Bool]
    
    init(name: String, values: [String]) {
        self.focusPoint = name
        
        self.values = [String:Bool]()
        for category in values {
            self.values[category] = false
        }
    }
    
    func addNewCategoryValue(category: String) {
        if self.values[category] == nil {
            self.values[category] = false
        }
        else {
            //Notify trainer category already exists
        }
    }
}
