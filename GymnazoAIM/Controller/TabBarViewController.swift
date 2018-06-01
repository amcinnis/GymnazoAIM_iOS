//
//  TabBarViewController.swift
//  GymnazoAIM
//
//  Created by Local Account 123-28 on 3/12/17.
//  Copyright © 2017 Austin McInnis. All rights reserved.
//

import UIKit
import FirebaseAuth
import GoogleSignIn


protocol QueueTableDelegate {
    func updateTable()
}

class TabBarViewController: UITabBarController, UITabBarControllerDelegate, QueueDataSourceDelegate {
    
    var queue = [Exercise]() {
        didSet {
            if let delegate = queueTableDelegate {
                delegate.updateTable()
            }
        }
    }
    var queueTableDelegate:QueueTableDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.delegate = self
        
        //Google Sign-in
        Auth.auth().addStateDidChangeListener() {
            [weak self] (auth, user) in
            guard let this = self else { return }
            if user == nil {
                this.performSegue(withIdentifier: "Show Login", sender: nil)
            }
        }
    }
    
    func queueHasChanged(queue: [Exercise]) {
        self.queue = queue
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Tab Bar Controller Delegate
//    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
//        
//        if let selectedNav = viewController as? UINavigationController {
//            if let movementsTableVC = selectedNav.topViewController as? MovementsTableViewController {
//                movementsTableVC.queueDataDelegate = self
//            }
//            else if let searchVC = selectedNav.topViewController as? SearchViewController {
//                searchVC.queueDataDelegate = self
//            }
//        }
//        else if let splitVC = viewController as? QueueSplitViewController {
//            splitVC.queueDataDelegate = self
//        }
//    }

}
