//
//  ViewExerciseViewController.swift
//  GymnazoAIM
//
//  Created by Local Account 123-28 on 3/21/17.
//  Copyright © 2017 Austin McInnis. All rights reserved.
//

import AVKit
import AVFoundation
import FirebaseStorage
import UIKit

class ViewExerciseViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var mediaView: UIView!
    @IBOutlet weak var categoryTable: UITableView!
    @IBOutlet var queueButton: UIBarButtonItem!
    
    var exercise: Exercise?
    var enabledCats = [String]()
    var queue:[Exercise]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Queue data source
        let tabbar = tabBarController as! TabBarViewController
        queue = tabbar.queue
        if let exercise = exercise {
            if (queue?.contains(where: {$0.databaseID == exercise.databaseID}))! {
                queueButton.title = "Remove From Queue"
                queueButton.tintColor = .red
            }
        }
        
        let controller = AVPlayerViewController()
        controller.view.frame = CGRect(x: 0, y: 0, width: mediaView.frame.width, height: mediaView.frame.height)
        self.addChildViewController(controller)
        mediaView.addSubview(controller.view)
        
        if let exercise = exercise {
            self.navigationItem.title = exercise.name
            let videoRef = Storage.storage().reference().child("exercises").child(exercise.globalMovementStr!).child(exercise.databaseID!)
            videoRef.downloadURL(completion: {
                (url, error) in
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
            })
        }
        
        if let categories = exercise?.enabledCategories {
            for entry in categories {
                enabledCats.append(entry.value)
            }
        }
        self.categoryTable.reloadData()
    }
    
    @IBAction func toggleInQueue(_ sender: Any) {
        if let exercise = exercise {
            if (queue?.contains(where: {$0.databaseID == exercise.databaseID}))! {
                //Remove from queue
                queue = queue?.filter() { $0.databaseID != exercise.databaseID }
                queueButton.title = "Add To Queue"
                queueButton.tintColor = .blue
            }
            else {
                //Add to queue
                queue?.append(exercise)
                queueButton?.title = "Remove From Queue"
                queueButton.tintColor = .red
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if let tabbar = tabBarController as? TabBarViewController {
            if let queue = queue {
                tabbar.queue = queue
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if let exercise = exercise {
            return (exercise.enabledCategories?.count)!
        }
        return 0
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExerciseCategoryCell", for: indexPath)

        // Configure the cell...
        cell.textLabel?.text = enabledCats[indexPath.row]

        return cell
    }
    
}
