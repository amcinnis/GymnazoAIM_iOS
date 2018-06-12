//
//  WorkoutSplitViewController.swift
//  GymnazoAIM
//
//  Created by Austin McInnis on 6/7/18.
//  Copyright © 2018 Austin McInnis. All rights reserved.
//

import UIKit

protocol SelectedExerciseDelegate {
    func updateSelectedExercise(exercise: Exercise)
}

class WorkoutSplitViewController: UISplitViewController, UISplitViewControllerDelegate, WorkoutTableDataSourceDelegate {
    
    var workout: Workout?
    var selectedExercise:Exercise? {
        didSet {
            if let delegate = self.selectedExerciseDelegate, let exercise = selectedExercise {
                delegate.updateSelectedExercise(exercise: exercise)
            }
        }
    }
    var selectedExerciseDelegate:SelectedExerciseDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.preferredDisplayMode = .allVisible
        delegate = self
    }
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        if let detail = secondaryViewController as? ViewWorkoutViewController {
            if detail.workout == nil {
                return true
            }
        }
        
        return false
    }
    
    func didSelectExercise(exercise: Exercise) {
        self.selectedExercise = exercise
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
