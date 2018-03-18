//
//  CategorizeNewExerciseViewController.swift
//  GymnazoAIM
//
//  Created by Austin McInnis on 4/8/17.
//  Copyright © 2017 Austin McInnis. All rights reserved.
//

import AVFoundation
import AVKit
import Firebase
import FirebaseStorage
import UIKit

// MARK: - NewExerciseCategoryCell

class NewExerciseCategoryCell: UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var toggleSwitch: UISwitch!
    var catID: String?
    
}

class CategorizeNewExerciseViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var mediaView: UIView!
    @IBOutlet var categorizeTableView: UITableView!
    
    private var doneAction: UIAlertAction?
    private var exercise = Exercise()
    private var focusPoints = [FocusPoint]()
    private var movementIDs = [String:String]()
    var video: Video?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Media Controller Initialization
        let controller = AVPlayerViewController()
        controller.view.frame = CGRect(x: 0, y: 0, width: mediaView.frame.width, height: mediaView.frame.height)
        if let video = video {
            controller.player = AVPlayer(url: video.url)
        }
        self.addChildViewController(controller)
        mediaView.addSubview(controller.view)
    
        // TableView Inititialization
        categorizeTableView.delegate = self
        categorizeTableView.dataSource = self
        
        let categoryNamesRef = Database.database().reference().child("category_names")
        
        categoryNamesRef.observe(.childAdded, with: {
            [weak self] (snapshot) in
            guard let this = self else { return }
            
            let focusPointName = snapshot.key
            let firebase = snapshot.value
            
            let focusPoint = FocusPoint(name: focusPointName, firebase: firebase as! [String:String])
            this.focusPoints.append(focusPoint)
            if focusPoint.name == "Global Movements" {
                for movement in focusPoint.firebase {
                    this.movementIDs[movement.key] = movement.value
                }
            }
            
            let set = IndexSet.init(integer: this.focusPoints.count-1)
            this.categorizeTableView.insertSections(set, with: .automatic)
        })
        
        // Title
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
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func upload(_ sender: Any) {
        self.transferEnabledCategories()
        
        //Check for at least one enabled category.
        guard (self.exercise.enabledCategories != nil) else {
            let failAlert = UIAlertController(title: "Error", message: "Exercises requires at least one category to be enabled before uploading.", preferredStyle: .alert)
            failAlert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: {
                (action) in
                return
            }))
            self.present(failAlert, animated: true, completion: nil)
            return
        }
        
        // Check for Global Movement
        guard self.exercise.globalMovementID != nil else {
            let globalAlert = UIAlertController(title: "Global Movement Required", message: "Please select a global movement to categorize this exercise.", preferredStyle: .alert)
            globalAlert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            self.present(globalAlert, animated: true, completion: nil)
            return
        }
        
        let alert = UIAlertController(title: "Confirmation", message: "Ready to upload '\(self.exercise.name!)'?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Upload", style: .default, handler: {
            [weak self] (action) in
            guard let this = self else { return }
            
            //Firebase Database
            let exercisesRef = Database.database().reference().child("exercises")
            let databaseGlobalRef = exercisesRef.child(this.exercise.globalMovementStr!)
            let exerciseRef = databaseGlobalRef.childByAutoId()
            this.exercise.databaseID = exerciseRef.key
            this.exercise.databasePath = "exercises/" + this.exercise.globalMovementStr! + "/" + exerciseRef.key
            this.exercise.storagePath = this.exercise.databasePath
            
            //Firebase Storage
            if let video = this.video {
                let exerciseVideosRefStorage = Storage.storage().reference().child("exercises")
                let storageGlobalRef = exerciseVideosRefStorage.child(this.exercise.globalMovementStr!)
                let videoRef = storageGlobalRef.child(exerciseRef.key)
                this.video?.name = this.exercise.name
                this.video?.databaseID = exerciseRef.key
                this.video?.databasePath = this.exercise.databasePath
                this.video?.storagePath = this.exercise.databasePath
                
                let uploadTask = videoRef.putFile(from: video.url, metadata: nil, completion: {
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
            
            exerciseRef.setValue([
                "name": this.exercise.name!,
                "enabledCategories": this.exercise.enabledCategories!,
                "globalMovementID": this.exercise.globalMovementID!,
                "globalMovementStr": this.exercise.globalMovementStr!,
                "databasePath": this.exercise.databasePath!,
                "storagePath": this.exercise.storagePath!
                ])
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
                    if self.movementIDs[catID] != nil {
                        self.exercise.globalMovementID = catID
                        self.exercise.globalMovementStr = self.movementIDs[catID]
                    }
                }
            }
        }
    }
    
    @IBAction func toggleChanged(_ sender: UISwitch) {
        if let cell = sender.superview?.superview as? NewExerciseCategoryCell {
            if let indexPath = self.categorizeTableView.indexPath(for: cell) {
                let focusPoint = focusPoints[indexPath.section]
                focusPoint.togglevalues[cell.catID!] = sender.isOn
            }
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Text Field Delegate
    
    @objc func textChanged(_ sender: UITextField) {
        self.doneAction?.isEnabled = !(sender.text?.isEmpty)!
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return false
    }
    
    // MARK: - TableView Data Source
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return focusPoints[section].name
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return focusPoints.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return focusPoints[section].categories.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewExerciseCategoryCell", for: indexPath) as! NewExerciseCategoryCell
        
        let catName = focusPoints[indexPath.section].categories[indexPath.row]
        cell.title.text = catName
        cell.catID = focusPoints[indexPath.section].ids[catName]
        cell.toggleSwitch.isOn = focusPoints[indexPath.section].togglevalues[cell.catID!]!
        cell.selectionStyle = .none
        
        return cell
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
