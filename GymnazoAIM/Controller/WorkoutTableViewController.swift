//
//  WorkoutTableViewController.swift
//  GymnazoAIM
//
//  Created by Austin McInnis on 6/7/18.
//  Copyright © 2018 Austin McInnis. All rights reserved.
//

import Firebase
import UIKit

protocol WorkoutTableDataSourceDelegate {
    func didSelectExercise(exercise: Exercise)
}

class WorkoutTableViewController: UITableViewController {
    
    var exercises = [Exercise]()
    var workout: Workout?
    var workoutDataDelegate:WorkoutTableDataSourceDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        //Get workout from split view controller
        if let splitVC = self.splitViewController as? WorkoutSplitViewController, let workout = splitVC.workout {
            self.workout = workout
            workoutDataDelegate = splitVC
        }
        
        if let workout = self.workout {
            if let paths = workout.exercisePaths {
                let databaseRef = Database.database().reference()
                for path in paths {
                    databaseRef.child(path).observeSingleEvent(of: .value, with: {
                        [weak self] (snapshot) in
                        guard let this = self else { return }

                        let name = snapshot.childSnapshot(forPath: "name").value as! String
                        let databaseID = snapshot.key
                        let databasePath = snapshot.childSnapshot(forPath: "databasePath").value as! String
                        let enabledCategories = snapshot.childSnapshot(forPath: "enabledCategories").value as! [String:String]
                        let globalMovementID = snapshot.childSnapshot(forPath: "globalMovementID").value as! String
                        let globalMovementStr = snapshot.childSnapshot(forPath: "globalMovementStr").value as! String
                        let storagePath = snapshot.childSnapshot(forPath: "storagePath").value as! String
                        let exercise = Exercise(databaseID: databaseID, name: name, globalMovementID: globalMovementID, globalMovementStr: globalMovementStr, databasePath: databasePath, storagePath: storagePath, enabled: enabledCategories)
                        this.exercises.append(exercise)
                        this.tableView.insertRows(at: [IndexPath(row: this.exercises.count-1, section: 0)], with: .automatic)
                    })
                }
            }
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return exercises.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "exerciseCell", for: indexPath) as! ExerciseCell

        // Configure the cell...
        let exercise = exercises[indexPath.row]
        cell.textLabel?.text = exercise.name
        cell.detailTextLabel?.text = exercise.globalMovementStr

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let exercise = exercises[indexPath.row]
        workoutDataDelegate?.didSelectExercise(exercise: exercise)
    }
}
