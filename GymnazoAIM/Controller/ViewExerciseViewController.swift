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

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        
        let tabbar = tabBarController as! TabBarViewController
        queue = tabbar.queue
        
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
    
    @IBAction func addToQueue(_ sender: Any) {
        if let exercise = exercise {
            queue?.append(exercise)
            queueButton?.title = "Added To Queue"
            queueButton?.isEnabled = false
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
