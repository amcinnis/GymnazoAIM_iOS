//
//  ViewWorkoutViewController.swift
//  GymnazoAIM
//
//  Created by Austin McInnis on 6/11/18.
//  Copyright © 2018 Austin McInnis. All rights reserved.
//

import AVKit
import Firebase
import UIKit

class ViewWorkoutViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, SelectedExerciseDelegate {

    var enabledCats = [String]()
    @IBOutlet var mediaView: UIView!
    var selectedExercise:Exercise? {
        didSet {
            if let cats = selectedExercise?.enabledCategories {
                enabledCats.removeAll()
                for entry in cats {
                    enabledCats.append(entry.value)
                }
                self.tableView.reloadData()
            }
        }
    }
    @IBOutlet var tableView: UITableView!
    var workout:Workout?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let splitVC = self.splitViewController as? WorkoutSplitViewController, let workout = splitVC.workout {
            self.workout = workout
            splitVC.selectedExerciseDelegate = self
        }
        
        let controller = AVPlayerViewController()
        controller.view.frame = CGRect(x: 0, y: 0, width: mediaView.frame.width, height: mediaView.frame.height)
        self.addChildViewController(controller)
        mediaView.addSubview(controller.view)
        
        if let workout = self.workout {
            let videoRef = Storage.storage().reference().child(workout.storagePath!)
            videoRef.downloadURL { (url, error) in
                guard error == nil else {
                    if let error = error {
                        print(error.localizedDescription)
                    }
                    return
                }
                
                if let url = url {
                    let player = AVPlayer(url: url)
                    DispatchQueue.main.async {
                        controller.player = player
                    }
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Selected Workout Delegate
    
    func updateSelectedExercise(exercise: Exercise) {
        self.selectedExercise = exercise
    }
    
    // MARK: TableView Data Source
    
    
    
    // MARK: TableView Delegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.selectedExercise != nil {
            return enabledCats.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExerciseCategoryCell", for: indexPath)
        
        cell.textLabel?.text = enabledCats[indexPath.row]
        
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
