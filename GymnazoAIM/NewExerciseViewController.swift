//
//  NewExerciseViewController.swift
//  GymnazoAIM
//
//  Created by Local Account 123-28 on 3/12/17.
//  Copyright © 2017 Austin McInnis. All rights reserved.
//

import AVKit
import AVFoundation
import UIKit

class NewExerciseViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

//    private var avController = AVPlayerViewController()
    private var imagePicker = UIImagePickerController()
//    private var player = AVPlayer()
    private var video: Video?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.mediaTypes = ["public.movie"]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func recordExercise(_ sender: Any) {
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func importExercise(_ sender: Any) {
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

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
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
