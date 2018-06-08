//
//  Workout.swift
//  GymnazoAIM
//
//  Created by Austin McInnis on 6/4/18.
//  Copyright © 2018 Austin McInnis. All rights reserved.
//


import Foundation

public class Workout {
    
    var name: String?
    var databaseID: String?
    var databasePath: String?
    var storagePath: String?
    var exercises: [Exercise]?
    var exercisePaths: [String]?
    var video: Video?
    var creationDate: Date?
    var notes: String?
    
    init(name: String, exercises:[Exercise]) {
        self.name = name
        self.exercises = exercises
    }
    
    init(name: String, databaseID: String, databasePath: String, exercisePaths:[String]) {
        self.name = name
        self.databaseID = databaseID
        self.databasePath = databasePath
        self.exercisePaths = exercisePaths
    }
    
    func getExercisePaths() -> [String] {
        var paths = [String]()
        
        if let exercises = exercises {
            for exercise in exercises {
                if let path = exercise.databasePath {
                    paths.append(path)
                }
            }
        }
        
        return paths
    }
}
