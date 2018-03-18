//
//  SearchViewController.swift
//  GymnazoAIM
//
//  Created by Local Account 123-28 on 3/21/17.
//  Copyright © 2017 Austin McInnis. All rights reserved.
//

import Firebase
import UIKit

class SearchViewController: UITableViewController {

    private var exercises = [Exercise]()
    private var filteredExercises = [Exercise]()
    private let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        self.definesPresentationContext = true
        self.tableView.tableHeaderView = searchController.searchBar
        
        var references = [DatabaseReference]()
        let exercisesRef = Database.database().reference().child("exercises")
        
        let jumpingRef = exercisesRef.child("Jumping")
        references.append(jumpingRef)
        let liftingRef = exercisesRef.child("Lifting")
        references.append(liftingRef)
        let locomotionRef = exercisesRef.child("Locomotion")
        references.append(locomotionRef)
        let lungingRef = exercisesRef.child("Lunging")
        references.append(lungingRef)
        let pullingRef = exercisesRef.child("Pulling")
        references.append(pullingRef)
        let pushingRef = exercisesRef.child("Pushing")
        references.append(pushingRef)
        let reachingRef = exercisesRef.child("Reaching")
        references.append(reachingRef)
        let squattingRef = exercisesRef.child("Squatting")
        references.append(squattingRef)
        let swingingRef = exercisesRef.child("Swinging")
        references.append(swingingRef)
        
        for reference in references {
            setupMovementObserver(reference: reference)
        }
    }
    
    private func setupMovementObserver (reference: DatabaseReference) {
        reference.observe(.childAdded, with: {
            [weak self] (snapshot) in
            guard let this = self else { return }
            
            let id = snapshot.key
            let name = snapshot.childSnapshot(forPath: "name").value as! String
            let movement = snapshot.childSnapshot(forPath: "globalMovementID").value as! String
            let movementStr = snapshot.childSnapshot(forPath: "globalMovementStr").value as! String
            let databasePath = snapshot.childSnapshot(forPath: "databasePath").value as! String
            let storagePath = snapshot.childSnapshot(forPath: "storagePath").value as! String
            let enabled = snapshot.childSnapshot(forPath: "enabledCategories").value as! [String:String]
            let exercise = Exercise(databaseID: id, name: name, globalMovementID: movement, globalMovementStr: movementStr, databasePath: databasePath, storagePath: storagePath, enabled: enabled)
            this.exercises.append(exercise)
            this.tableView.insertRows(at: [IndexPath(row: this.exercises.count-1, section: 0)], with: .automatic)
        })
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filteredExercises = exercises.filter({
            (exercise) in
            return (exercise.name?.lowercased().contains(searchText.lowercased()))!
        })
        self.tableView.reloadData()
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
        if searchController.isActive && !(searchController.searchBar.text?.isEmpty)! {
            return filteredExercises.count
        }
        return exercises.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExerciseCell", for: indexPath) as! ExerciseCell

        // Configure the cell...
        var exercise: Exercise
        if searchController.isActive && !(searchController.searchBar.text?.isEmpty)! {
            exercise = filteredExercises[indexPath.row]
        }
        else {
            exercise = exercises[indexPath.row]
        }
    
        cell.exercise = exercise
        cell.textLabel?.text = exercise.name

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
            if let dest = segue.destination as? ViewExerciseViewController {
                if let cell = sender as? ExerciseCell {
                    if let exercise = cell.exercise {
                        dest.exercise = exercise
                    }
                }
            }
        }
    }
    

}

extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
}
