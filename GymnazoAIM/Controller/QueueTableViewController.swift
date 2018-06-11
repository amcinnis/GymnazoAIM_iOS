//
//  QueueTableViewController.swift
//  GymnazoAIM
//
//  Created by Austin McInnis on 5/31/18.
//  Copyright © 2018 Austin McInnis. All rights reserved.
//

import AVFoundation
import Firebase
import UIKit

class QueueTableViewController: UITableViewController, QueueTableDelegate, UITextFieldDelegate {

    private var doneAction: UIAlertAction?
    var queue:[Exercise]?
    var videoURLs = [URL]() {
        didSet {
            if let queue = self.queue {
                if videoURLs.count == queue.count {
                    self.downloadAlert.dismiss(animated: true, completion: {
                        self.present(self.rendderAlert, animated: true, completion: nil)
                    })
                    buildWorkoutVideo()
                }
            }
        }
    }
    var workout:Workout?
    
    private var downloadAlert = UIAlertController(title: "Downloading...", message: "Gathering exercise videos...", preferredStyle: .alert)
    private var rendderAlert = UIAlertController(title: "Rendering...", message: "Creating workout video...", preferredStyle: .alert)
    
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
    
    func downloadVideos() {
        guard self.workout != nil else {
            print("Null workout!")
            return
        }
        
        if let exercises = self.queue {
            // Build Workout Video
            
            self.present(self.downloadAlert, animated: true, completion: nil)
            
            //Get each video from Firebase Storage
            let storageRef = Storage.storage().reference()
            for exercise in exercises {
                if let storagePath = exercise.storagePath {
                    let videoRef = storageRef.child(storagePath)
                    videoRef.downloadURL(completion: {
                        [weak self] (url, error) in
                        guard error == nil else {
                            if let error = error {
                                print(error.localizedDescription)
                            }
                            return
                        }
                        guard let this = self else { return }
                        if let url = url {
                            this.videoURLs.append(url)
                        }
                    })
                }
            }
        }
    }
    
    func buildWorkoutVideo() {
        var assets = [AVAsset]()
        for url in videoURLs {
            assets.append(AVAsset(url: url))
        }
        
        KVVideoManager.shared.merge(arrayVideos: assets, completion: {
            [weak self] (outputURL, error) in
            guard let this = self else { return }
            
            if let error = error {
                print("Error:\(error.localizedDescription)")
            }
            else {
                if let url = outputURL {
                    print("Output video file:\(url)")
                    if let workout = this.workout {
                        let video = Video(url: url)
                        workout.video = video
                        this.rendderAlert.dismiss(animated: true, completion: nil)
                        this.pushWorkout()
                    }
                }
            }
        })
    }
    
    func pushWorkout() {
        if let workout = self.workout, let name = workout.name {
            //Firebase
            let workoutsRef = Database.database().reference().child("workouts")
            let workoutRef = workoutsRef.childByAutoId()
            let videoRef = Storage.storage().reference().child("workouts").child(workoutRef.key)
            
            if let workout = self.workout {
                //Database
                workout.databaseID = workoutRef.key
                workout.databasePath = "workouts/" + workout.databaseID!
                
                workoutRef.setValue([
                    "name": name,
                    "databaseID": workoutRef.key,
                    "databasePath": workout.databasePath!,
                    "exercises": workout.getExercisePaths(),
                    "storagePath": workout.databasePath!
                    ])
                
                //Storage
                if let video = workout.video {
                    video.name = workout.name
                    
                    let progressAlert = UIAlertController(title: "Progress", message: "", preferredStyle: .alert)
                    let progressBar = UIProgressView(progressViewStyle: .bar)
                    self.present(progressAlert, animated: true, completion: nil)
                    
                    let uploadTask = videoRef.putFile(from: video.url, metadata: nil) {
                        [weak self] (metadata, error) in
                        guard let this = self else { return }
                        if let error = error {
                            print("Error uploading to Storage!: \(error.localizedDescription)")
                            return
                        }
                        
                        let successAlert = UIAlertController(title: "Success", message: "'\(video.name!)' uploaded successfully.", preferredStyle: .alert)
                        successAlert.addAction(UIAlertAction(title: "Done", style: .default, handler: {
                            [weak self] (action) in
                            guard let this = self else { return }
                            this.dismiss(animated: true, completion: nil)
                        }))
                        this.present(successAlert, animated: true, completion: nil)
                        print("Upload Success!")
                    }
                    
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
//                    self.present(progressAlert, animated: true, completion: nil)
                }
            }
        }
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
            if this.workout == nil, let name = workoutName, let queue = this.queue {
                this.workout = Workout(name: name, exercises: queue)
            }
            this.getQueue()
            this.downloadVideos()
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
