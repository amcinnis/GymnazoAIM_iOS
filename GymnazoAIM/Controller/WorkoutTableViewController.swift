//
//  WorkoutTableViewController.swift
//  GymnazoAIM
//
//  Created by Austin McInnis on 6/7/18.
//  Copyright © 2018 Austin McInnis. All rights reserved.
//

import Firebase
import UIKit

class WorkoutTableViewController: UITableViewController {
    
    var exercises = [Exercise]()
    @IBOutlet var navBar: UINavigationItem!
    var workout: Workout?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        //Get workout from split view controller
        if let splitVC = self.splitViewController as? WorkoutSplitViewController, let workout = splitVC.workout {
            self.workout = workout
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
        
        if let workout = self.workout {
            navBar.title = workout.name
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
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
