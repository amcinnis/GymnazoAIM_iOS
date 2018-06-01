//
//  QueueSplitViewController.swift
//  GymnazoAIM
//
//  Created by Austin McInnis on 5/31/18.
//  Copyright © 2018 Austin McInnis. All rights reserved.
//

import UIKit

class QueueSplitViewController: UISplitViewController, UISplitViewControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        delegate = self
        self.preferredDisplayMode = .allVisible
//        self.preferredPrimaryColumnWidthFraction = 0.33
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        if let nav = secondaryViewController as? UINavigationController {
            if let detail = nav.topViewController as? ViewExerciseViewController {
                if detail.exercise == nil {
                    return true
                }
            }
        }
        
        return false
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
