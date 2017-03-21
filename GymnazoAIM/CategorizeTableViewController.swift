//
//  CategorizeTableViewController.swift
//  GymnazoAIM
//
//  Created by Local Account 123-28 on 3/17/17.
//  Copyright © 2017 Austin McInnis. All rights reserved.
//

import Firebase
import FirebaseStorage
import UIKit

// MARK: - NewExerciseCategoryCell

class NewExerciseCategoryCell: UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var toggleSwitch: UISwitch!
    var catID: String?
    
}

// MARK: - CategorizeViewController

class CategorizeTableViewController: UITableViewController, UITextFieldDelegate {

    private var exercise = Exercise()
    private var focusPoints = [FocusPoint]()
    private var movementIDs = [String]()
    private var doneAction: UIAlertAction?
    var video: Video?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        let alert = UIAlertController(title: "Enter Exercise Title", message: "Please enter the title of the exercise", preferredStyle: .alert)
        alert.addTextField(configurationHandler: {
            [weak self] (textField) in
            guard let this = self else { return }
            textField.delegate? = this
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
            
            let textField = alert.textFields!.first
            this.exercise.name = textField?.text
            print("Exercise name: \(this.exercise.name!)")
        })
        doneAction?.isEnabled = false
        alert.addAction(doneAction!)
        self.present(alert, animated: true, completion: nil)
        
        let categoryNamesRef = FIRDatabase.database().reference().child("category_names")
        
        categoryNamesRef.observe(.childAdded, with: {
            [weak self] (snapshot) in
            guard let this = self else { return }
            
            let focusPointName = snapshot.key
            let firebase = snapshot.value
            
            let focusPoint = FocusPoint(name: focusPointName, firebase: firebase as! [String:String])
            this.focusPoints.append(focusPoint)
            if focusPoint.name == "Global Movements" {
                for movement in focusPoint.firebase {
                    this.movementIDs.append(movement.key)
                }
            }
            
            let set = IndexSet.init(integer: this.focusPoints.count-1)
            this.tableView.insertSections(set, with: .automatic)
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func toggleChanged(_ sender: UISwitch) {
        if let cell = sender.superview?.superview as? NewExerciseCategoryCell {
            if let indexPath = self.tableView.indexPath(for: cell) {
                let focusPoint = focusPoints[indexPath.section]
                focusPoint.togglevalues[cell.catID!] = sender.isOn
            }
            
        }
    }
    
    @IBAction func upload(_ sender: Any) {
        self.transferEnabledCategories()
        guard (self.exercise.enabledCategories != nil) else {
            let failAlert = UIAlertController(title: "Error", message: "Exercises requires at least one category to be enabled before uploading.", preferredStyle: .alert)
            failAlert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: {
                (action) in
                return
            }))
            self.present(failAlert, animated: true, completion: nil)
            return
        }
        
        let alert = UIAlertController(title: "Confirmation", message: "Ready to upload '\(self.exercise.name!)'?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Upload", style: .default, handler: {
            [weak self] (action) in
            guard let this = self else { return }
            
            //Firebase Database
            let exercisesRef = FIRDatabase.database().reference().child("exercises")
            let exerciseRef = exercisesRef.childByAutoId()
            this.exercise.id = exerciseRef.key
            this.video?.id = exerciseRef.key
            this.video?.name = this.exercise.name
            
            //Firebase Storage
            if let video = this.video {
                let exerciseVideosRefStorage = FIRStorage.storage().reference().child("exercises")
                let videoRef = exerciseVideosRefStorage.child(video.id!)
                let uploadTask = videoRef.putFile(video.url, metadata: nil, completion: {
                    [weak self] (metadata, error) in
                    guard let this = self else { return }
                    if let error = error {
                        print("Error!: \(error.localizedDescription)")
                    }
                    else {
                        let successAlert = UIAlertController(title: "Success", message: "'\(video.name!)' uploaded successfully.", preferredStyle: .alert)
                        successAlert.addAction(UIAlertAction(title: "Done", style: .default, handler: {
                            [weak self] (action) in
                            guard let this = self else { return }
                            this.dismiss(animated: true, completion: nil)
                        }))
                        this.present(successAlert, animated: true, completion: nil)
                        print("Upload Success!")
                    }
                })
                
                let progressAlert = UIAlertController(title: "Progress", message: "", preferredStyle: .alert)
                let progressBar = UIProgressView(progressViewStyle: .bar)
                
                uploadTask.observe(.resume, handler: {
                    (snapshot) in
                    progressAlert.message = "0% Uploaded"
                    let margin = 8.0
                    let frame = CGRect(x: margin, y: 72.0, width: Double(progressAlert.view.frame.width) - margin * 2.0, height: 2.0)
                    progressBar.frame = frame
                    progressAlert.view.addSubview(progressBar)
                })
                
                uploadTask.observe(.progress, handler: {
                    (snapshot) in
                    let progress = Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
                    progressBar.setProgress(Float(progress), animated: true)
                    progressAlert.message = "\(String(format: "%3.1f", 100.0*progress))% Uploaded"
                })
                
                uploadTask.observe(.success, handler: {
                    [weak self] (snapshot) in
                    guard let this = self else { return }
                    this.dismiss(animated: true, completion: nil)
                })
                this.present(progressAlert, animated: true, completion: nil)
            }
            
            exerciseRef.setValue(["name": this.exercise.name!, "enabledCategories": this.exercise.enabledCategories!, "globalMovement": this.exercise.globalMovement!])
        }))
        self.present(alert, animated: true, completion: nil)
    }

    func transferEnabledCategories() {
        for focusPoint in focusPoints {
            for (catID, toggleValue) in focusPoint.togglevalues {
                if toggleValue == true {
                    if let name = focusPoint.firebase[catID] {
                        self.exercise.addEnabledCategory(categoryID: catID, value: name)
                    }
                    if self.movementIDs.contains(catID) {
                        self.exercise.globalMovement = catID
                    }
                }
            }
        }
    }
    
    // MARK: - Text Field Delegate
    
    func textChanged(_ sender: UITextField) {
        self.doneAction?.isEnabled = !(sender.text?.isEmpty)!
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return false
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return focusPoints.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return focusPoints[section].categories.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewExerciseCategoryCell", for: indexPath) as! NewExerciseCategoryCell

        // Configure the cell...
        let catName = focusPoints[indexPath.section].categories[indexPath.row]
        cell.title.text = catName
        cell.catID = focusPoints[indexPath.section].ids[catName]
        cell.toggleSwitch.isOn = focusPoints[indexPath.section].togglevalues[cell.catID!]!
        cell.selectionStyle = .none

        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return focusPoints[section].name
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
