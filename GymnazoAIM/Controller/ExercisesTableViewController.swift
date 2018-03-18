//
//  ExercisesTableViewController.swift
//  GymnazoAIM
//
//  Created by Local Account 123-28 on 3/21/17.
//  Copyright © 2017 Austin McInnis. All rights reserved.
//
import Firebase
import UIKit

class ExerciseCell: UITableViewCell {
    var exercise: Exercise?
}

class ExercisesTableViewController: UITableViewController {
    
    var movement: GlobalMovement?
    var selectedExercise: Exercise?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        if let movement = movement {
            let exercisesRef = Database.database().reference().child("exercises").child(movement.name)
            
            //Zero out exercises array
            movement.exercises.removeAll()
            
            exercisesRef.observe(.childAdded, with: {
                [weak self] (snapshot) in
                guard let this = self else { return }
                
                let id = snapshot.key
                
                //Ask Bellardo
                //1. Check to see if exercise array is populated
                //2. Throw contents away
                //3. Move observer into Global Movement Model class
                //guard !(this.movement?.exercises.contains(where: {$0.databaseID == id}))! else { return }
                let name = snapshot.childSnapshot(forPath: "name").value as! String
                let enabledCats = snapshot.childSnapshot(forPath: "enabledCategories").value as! [String:String]
                let globalMovement = snapshot.childSnapshot(forPath: "globalMovementID").value as! String
                let globalMovementStr = snapshot.childSnapshot(forPath: "globalMovementStr").value as! String
                let databasePath = snapshot.childSnapshot(forPath: "databasePath").value as! String
                let storagePath = snapshot.childSnapshot(forPath: "storagePath").value as! String
                let exercise = Exercise(databaseID: id, name: name, globalMovementID: globalMovement, globalMovementStr: globalMovementStr, databasePath: databasePath, storagePath: storagePath, enabled: enabledCats)
                if let innerMovement = this.movement {
                    innerMovement.exercises.append(exercise)
                    this.tableView.insertRows(at: [IndexPath(row: innerMovement.exercises.count-1, section:0)], with: .automatic)
                }
            })
            
            exercisesRef.observe(.childRemoved, with: {
                [weak self] (snapshot) in
                guard let this = self else { return }
                
                let id = snapshot.key
                if let index = this.movement?.exercises.index(where: {$0.databaseID == id}) {
                    this.movement?.exercises.remove(at: index)
                    this.tableView.deleteRows(at: [IndexPath(row: index, section:0)], with: .automatic)
                }
            })
        }
        
        self.navigationItem.title = movement?.name
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
        if let movement = movement {
            return movement.exercises.count
        }
        return 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "exerciseCell", for: indexPath) as! ExerciseCell

        // Configure the cell...
        cell.exercise = movement?.exercises[indexPath.row]
        cell.textLabel?.text = cell.exercise?.name!

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
        
        if segue.identifier == "ViewExercise" {
            if let viewExerciseVC = segue.destination as? ViewExerciseViewController {
                if let cell = sender as? ExerciseCell {
                    if let exercise = cell.exercise {
                        viewExerciseVC.exercise = exercise
                    }
                }
            }
        }
    }
    

}
