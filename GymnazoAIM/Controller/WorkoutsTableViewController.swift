//
//  WorkoutsTableViewController.swift
//  GymnazoAIM
//
//  Created by Austin McInnis on 6/5/18.
//  Copyright © 2018 Austin McInnis. All rights reserved.
//

import Firebase
import UIKit

class WorkoutCell: UITableViewCell {
    var workout: Workout?
}

class WorkoutsTableViewController: UITableViewController {
    
    var workouts = [Workout]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        let databaseRef = Database.database().reference()
        let workoutsRef = databaseRef.child("workouts")
        
        workoutsRef.observe(.childAdded, with: {
            [weak self] (snapshot) in
            guard let this = self else { return }
            
            let name = snapshot.childSnapshot(forPath: "name").value as! String
            let databaseID = snapshot.childSnapshot(forPath: "databaseID").value as! String
            let databasePath = snapshot.childSnapshot(forPath: "databasePath").value as! String
            let paths = snapshot.childSnapshot(forPath: "exercises").value as! [String]
            let storagePath = snapshot.childSnapshot(forPath: "storagePath").value as! String
        
            let workout = Workout(name: name, databaseID: databaseID, databasePath: databasePath, exercisePaths:paths)
            workout.databaseID = databaseID
            workout.databasePath = databasePath
            workout.storagePath = storagePath
            this.workouts.append(workout)
            this.tableView.insertRows(at: [IndexPath(row: this.workouts.count-1, section: 0)], with: .automatic)
        })
        
        workoutsRef.observe(.childRemoved) {
            [weak self] (snapshot) in
            guard let this = self else { return }
            
            let id = snapshot.key
            if let index = this.workouts.index(where: { $0.databaseID == id}) {
                this.workouts.remove(at: index)
                this.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
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
        return self.workouts.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "workoutCell", for: indexPath) as! WorkoutCell

        // Configure the cell...
        let workout = self.workouts[indexPath.row]
        cell.textLabel?.text = workout.name
        cell.workout = workout

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

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "workoutSelected" {
            if let dest = segue.destination as? WorkoutContainerViewController {
                if let cell = sender as? WorkoutCell {
                    dest.workout = cell.workout
                }
            }
        }
    }
    

}
