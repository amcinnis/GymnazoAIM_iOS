//
//  FocusPoint.swift
//  GymnazoAIM
//
//  Created by Local Account 123-28 on 3/14/17.
//  Copyright © 2017 Austin McInnis. All rights reserved.
//

import Foundation
import Firebase

public class FocusPoint {
    
    let categoryNamesRef = FIRDatabase.database().reference().child("category_names")
    var name: String
    var categories: [String]
    var ids: [String:String]
    
    init(name: String, values: [String]) {
        self.name = name
        self.categories = values
        self.ids = [String:String]()
        
        let focusPointRef = categoryNamesRef.child(name)
        for cat in values {
            self.ids[cat] = focusPointRef.childByAutoId().key
        }
    }
    
    init(name: String, ids: [String:String]) {
        self.name = name
        self.ids = ids
        
        self.categories = [String]()
        for (category) in Array(ids).sorted(by: {$0.value < $1.value}) {
            self.categories.append(category.key)
        }
    }
    
    func removeCat(indexPath: IndexPath) {
        let category = self.categories[indexPath.row]
        self.categories.remove(at: indexPath.row)
        self.ids.removeValue(forKey: category)
        let focusPointRef = categoryNamesRef.child(self.name)
        focusPointRef.child(category).removeValue()
    }
}
