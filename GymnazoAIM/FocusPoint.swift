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
    var ids: [String:String] //key is category, value is id
    var firebase: [String:String] //key is id, value is category
    var edits: [String:String]?
    
    init(name: String, values: [String]) {
        self.name = name
        self.categories = values
        self.ids = [String:String]()
        self.firebase = [String:String]()
        
        let focusPointRef = categoryNamesRef.child(name)
        for cat in values {
            let id =  focusPointRef.childByAutoId().key
            self.ids[cat] = id
            self.firebase[id] = cat
        }
    }
    
    init(name: String, firebase: [String:String]) {
        self.name = name
        self.firebase = firebase
        self.ids = [String:String]()
        
        self.categories = [String]()
        for (category) in Array(firebase).sorted(by: {$0.key < $1.key}) {
            self.categories.append(category.value)
            self.ids[category.value] = category.key
        }
    }
    
    func editCat(indexPath: IndexPath, newName: String) {
        if let id = self.ids[self.categories[indexPath.row]] {
            if self.edits == nil {
                self.edits = [String:String]()
            }
            self.edits?[id] = newName
        }
        else {
            insertNewCat(indexPath: indexPath, newName: newName)
        }
    }
    
    func insertNewCat(indexPath: IndexPath, newName: String) {
        self.categories[indexPath.row] = newName
        let focusPointRef = categoryNamesRef.child(self.name)
        let id =  focusPointRef.childByAutoId().key
        self.ids[newName] = id
        self.firebase[id] = newName
        focusPointRef.setValue(self.firebase)
    }
    
    func removeCat(indexPath: IndexPath) {
        let category = self.categories[indexPath.row]
        let catID = self.ids[category]
        self.categories.remove(at: indexPath.row)
        self.ids.removeValue(forKey: category)
        if let id = catID {
            self.firebase.removeValue(forKey: id)
            let focusPointRef = categoryNamesRef.child(self.name)
            focusPointRef.child(id).removeValue()
        }
        else {
            print("Error deleting category from firebase. ID lookup returned nil.")
        }
    }
    
    func update(firebase: [String:String]) {
        self.firebase = firebase
        self.categories.removeAll()
        self.ids.removeAll()
        for (category) in Array(firebase).sorted(by: {$0.key < $1.key}) {
            self.categories.append(category.value)
            self.ids[category.value] = category.key
        }
    }
}
