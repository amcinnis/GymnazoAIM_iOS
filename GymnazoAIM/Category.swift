//
//  Category.swift
//  GymnazoAIM
//
//  Created by Local Account 123-28 on 3/14/17.
//  Copyright © 2017 Austin McInnis. All rights reserved.
//

import Foundation

public class Category {
    
    var name: String
    var values: [String:Bool]
    
    init(name: String, values: [String]) {
        self.name = name
        
        self.values = [String:Bool]()
        for catName in values {
            self.values[catName] = false
        }
    }
    
    func addNewCategoryValue(catName: String) {
        if self.values[catName] == nil {
            self.values[catName] = false
        }
        else {
            //Notify trainer category already exists
        }
    }
}
