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
    var values: [String]
    
    init(name: String, values: [String]) {
        self.focusPoint = name
        self.values = values
    }
}
