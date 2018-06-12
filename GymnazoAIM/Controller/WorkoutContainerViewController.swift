//
//  WorkoutContainerViewController.swift
//  GymnazoAIM
//
//  Created by Austin McInnis on 6/7/18.
//  Copyright © 2018 Austin McInnis. All rights reserved.
//

import UIKit

class WorkoutContainerViewController: UIViewController {

    var workout: Workout?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "presentSplit" {
            if let dest = segue.destination as? WorkoutSplitViewController {
                if let workout = self.workout {
                    dest.workout = workout
                    self.navigationItem.title = workout.name
                }
            }
        }
    }
    

}
