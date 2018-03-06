//
//  MovementsTableViewController.swift
//  GymnazoAIM
//
//  Created by Local Account 123-28 on 3/20/17.
//  Copyright © 2017 Austin McInnis. All rights reserved.
//

import Firebase
import UIKit

class MovementsTableViewController: UITableViewController {
    
    var movements = [GlobalMovement]()
    var exercises = [Exercise]()
    private var selectedMovement: GlobalMovement?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        let globalMovementsRef = Database.database().reference().child("category_names").child("Global Movements")
        
        globalMovementsRef.observe(.childAdded, with: {
            [weak self] (snapshot) in
            guard let this = self else { return }
        
            let movement = GlobalMovement(id: snapshot.key, name: snapshot.value as! String)
            this.movements.append(movement)
            this.tableView.insertRows(at: [IndexPath(row: this.movements.count-1, section:0)], with: .automatic)
        })
        
        let exercisesRef = Database.database().reference().child("exercises")
        
        exercisesRef.observe(.childAdded, with: {
            [weak self] (snapshot) in
            guard let this = self else { return }
            
            let id = snapshot.key
            let name = snapshot.childSnapshot(forPath: "name").value as! String
            let enabledCats = snapshot.childSnapshot(forPath: "enabledCategories").value as! [String:String]
            let globalMovement = snapshot.childSnapshot(forPath: "globalMovement").value as! String
            let exercise = Exercise(id: id, name: name, globalMovement: globalMovement, enabled: enabledCats)
            this.exercises.append(exercise)
        })
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
        return movements.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GlobalMovementCell", for: indexPath)

        // Configure the cell...
        cell.textLabel?.text = movements[indexPath.row].name

        return cell
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let movement = movements[indexPath.row]
        
        for exercise in exercises {
            if exercise.globalMovement == movement.id  && exercise.movementOrganized == false {
                movement.exercises.append(exercise)
                exercise.movementOrganized = true
            }
        }
        
        selectedMovement = movement
        
        return indexPath
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
        if editingdidStyle == .delete {
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
        
        if segue.identifier == "movementSelected" {
            if let exVC = segue.destination as? ExercisesTableViewController {
                exVC.movement = selectedMovement
            }
        }
    }


}
