//
//  MovementsTableViewController.swift
//  GymnazoAIM
//
//  Created by Local Account 123-28 on 3/20/17.
//  Copyright © 2017 Austin McInnis. All rights reserved.
//

import AVKit
import Firebase
import UIKit

class MovementsTableViewController: UITableViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    var exercises = [Exercise]()
    private var imagePicker = UIImagePickerController()
    var movements = [GlobalMovement]()
    @IBOutlet var newExerciseButton: UIBarButtonItem!
    private var selectedMovement: GlobalMovement?
    private var video: Video?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()

        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.mediaTypes = ["public.movie"]
        
        let globalMovementsRef = Database.database().reference().child("category_names").child("Global Movements")
        
        globalMovementsRef.observe(.childAdded, with: {
            [weak self] (snapshot) in
            guard let this = self else { return }
        
            let movement = GlobalMovement(id: snapshot.key, name: snapshot.value as! String)
            this.movements.append(movement)
            this.tableView.insertRows(at: [IndexPath(row: this.movements.count-1, section:0)], with: .automatic)
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
    
    // MARK: - Create New Exercise
    @IBAction func newExercise(_ sender: Any) {
        let optionMenu = UIAlertController(title: nil, message: "Choose Option", preferredStyle: .actionSheet)
        let recordAction = UIAlertAction(title: "Video", style: .default) {
            [weak self] (action) in
            guard let this = self else { return }
            this.recordExercise()
        }
        let importAction = UIAlertAction(title: "Library", style: .default) {
            [weak self] (action) in
            guard let this = self else { return }
            this.importExercise()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) {
            [weak self] (action) in
            guard let this = self else { return }
            this.dismiss(animated: true, completion: nil)
        }
        
        optionMenu.popoverPresentationController?.barButtonItem = self.newExerciseButton
        optionMenu.addAction(recordAction);
        optionMenu.addAction(importAction);
        optionMenu.addAction(cancelAction); // Removed by UIKit. Tap anywhere outside to cancel
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    func recordExercise() {
        let cameraMediaType = AVMediaType.video
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: cameraMediaType)
        
        switch cameraAuthorizationStatus {
        case .denied: break
        case .authorized: presentCamera()
        case .restricted: break
            
        case .notDetermined:
            // Prompting user for the permission to use the camera.
            AVCaptureDevice.requestAccess(for: cameraMediaType) {
                [weak self] granted in
                guard let this = self else { return }
                
                if granted {
                    print("Granted access to \(cameraMediaType)")
                    this.presentCamera()
                } else {
                    print("Denied access to \(cameraMediaType)")
                }
            }
        }
    }
    
    func presentCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera
            present(imagePicker, animated: true, completion: nil)
        }
        else {
            print ("Camera not available")
        }
    }
    
    func importExercise() {
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    //MARK: - Image Picker Controller Delegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let videoURL = info[UIImagePickerControllerMediaURL] as? URL
        
        if let url = videoURL {
            video = Video(url: url)
            //            player = AVPlayer(url: url)
            //            avController.player = player
            
            do {
                let attr = try FileManager.default.attributesOfItem(atPath: url.path)
                let creationDate = attr[FileAttributeKey.creationDate] as? Date
                if let date = creationDate {
                    video?.creationDate = date
                }
            } catch  {
                
            }
        }
        
        imagePicker.dismiss(animated: true, completion: {
            [weak self] in
            guard let this = self else { return }
            this.performSegue(withIdentifier: "CategorizeNewExercise", sender: nil)
        })
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let movement = movements[indexPath.row]
        
        for exercise in exercises {
            if exercise.globalMovementID == movement.id  && exercise.movementOrganized == false {
                movement.exercises.append(exercise)
                exercise.movementOrganized = true
            }
        }
        
        selectedMovement = movement
        
        return indexPath
    }
    
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
        
        if segue.identifier == "CategorizeNewExercise" {
            if let nav = segue.destination as? UINavigationController {
                if let dest = nav.topViewController as? CategorizeNewExerciseViewController {
                    if let video = video {
                        dest.video = video
                    }
                }
            }
        }
    }


}
