//
//  QueueTableViewController.swift
//  GymnazoAIM
//
//  Created by Austin McInnis on 5/31/18.
//  Copyright © 2018 Austin McInnis. All rights reserved.
//

import Firebase
import UIKit

class QueueTableViewController: UITableViewController, QueueTableDelegate, UITextFieldDelegate {

    private var doneAction: UIAlertAction?
    var queue:[Exercise]?
    var workout:Workout?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.leftBarButtonItem = self.editButtonItem
    
        if let tabBarVC = tabBarController as? TabBarViewController {
            tabBarVC.queueTableDelegate = self
        }
        getQueue()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getQueue() {
        if let tabbar = tabBarController as? TabBarViewController {
            queue = tabbar.queue
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        updateTable()
    }
    
    func updateTable() {
        getQueue()
        tableView.reloadData()
    }
    
    @IBAction func upload(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "New Workout", message: "Please enter the title of the workout", preferredStyle: .alert)
        alert.addTextField(configurationHandler: {
            [weak self] (textField) in
            guard let this = self else { return }
            textField.delegate = this
            textField.autocapitalizationType = .words
            textField.addTarget(this, action: #selector(this.textChanged(_:)), for: .editingChanged)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {
            [weak self] (action) in
            guard let this = self else { return }
            this.dismiss(animated: true, completion: nil)
        }))
        doneAction = UIAlertAction(title: "Done", style: .default, handler: {
            [weak self] (action) in
            guard let this = self else { return }
            
            let textField = alert.textFields?.first
            var workoutName:String?
            if let textField = textField {
                workoutName = textField.text!
                print(textField.text!)
            }
            
            if let name = workoutName, let exercises = this.queue {
                this.workout = Workout(name: name, exercises: exercises)
                
                //Firebase Database
                let workoutsRef = Database.database().reference().child("workouts")
                let workoutRef = workoutsRef.childByAutoId()
                
                if let workout = this.workout {
                    workout.databaseID = workoutRef.key
                    workout.databasePath = "workouts/" + workout.databaseID!
                    
                    workoutRef.setValue([
                        "name": name,
                        "databaseID": workoutRef.key,
                        "databasePath": workout.databasePath!,
                        "exercises": workout.getExercisePaths()
                    ])
                }
            }
        })
        doneAction?.isEnabled = false
        alert.addAction(doneAction!)
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Text Field Delegate
    
    @objc func textChanged(_ sender: UITextField) {
        self.doneAction?.isEnabled = !(sender.text?.isEmpty)!
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (queue?.count)!
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "QueueCell", for: indexPath) as! ExerciseCell

        // Configure the cell...
        let exercise = queue![indexPath.row]
        cell.exercise = exercise
        cell.textLabel?.text = exercise.name
        cell.detailTextLabel?.text = exercise.globalMovementStr

        return cell
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }
    
    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if self.queue != nil {
            let movedExercise = queue![sourceIndexPath.row]
            queue!.remove(at: sourceIndexPath.row)
            queue!.insert(movedExercise, at: destinationIndexPath.row)
            print("Moved exercise: \(movedExercise.name ?? "Nil exercise name") from row \(sourceIndexPath.row) to \(destinationIndexPath.row)")
        }
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

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detail" {
            if let nav = segue.destination as? UINavigationController {
                if let dest = nav.topViewController as? ViewExerciseViewController {
                    if let cell = sender as? ExerciseCell {
                        dest.exercise = cell.exercise
                    }
                }
            }
        }
    }
}
