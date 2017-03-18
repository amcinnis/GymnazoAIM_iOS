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
        print("\(videoURL)")
        
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
            this.performSegue(withIdentifier: "presentSplit", sender: nil)
        })
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "presentSplit" {
            if let splitVC = segue.destination as? UISplitViewController {
//                splitVC.preferredDisplayMode = .automatic
                if let video = video {
                    let avPlayerVC = AVPlayerViewController()
                    avPlayerVC.player = AVPlayer(url: video.url)
                    splitVC.viewControllers[0] = avPlayerVC
                    if let nav = splitVC.viewControllers[1] as? UINavigationController {
                        if let catTableVC = nav.topViewController as? CategorizeTableViewController {
                            catTableVC.video = video
                        }
                    }
                }
            }
        }
    }

}
