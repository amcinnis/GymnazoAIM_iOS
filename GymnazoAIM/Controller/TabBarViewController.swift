//
//  TabBarViewController.swift
//  GymnazoAIM
//
//  Created by Local Account 123-28 on 3/12/17.
//  Copyright © 2017 Austin McInnis. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import GoogleSignIn


protocol QueueTableDelegate {
    func updateTable()
}

class TabBarViewController: UITabBarController, UITabBarControllerDelegate, QueueDataSourceDelegate {
    
    var userIsAdmin = false
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
            
            // User Management
            if let user = user {
                
                //Users
                let usersRef = Database.database().reference().child("users")
                usersRef.observeSingleEvent(of: .value, with: { (snapshot) in
                    if !(snapshot.hasChild(user.uid)) {
                        //New user, add to users and update last login
                        usersRef.child(user.uid).setValue([
                            "name": user.displayName!,
                            "email": user.email!,
                            "isAdmin": false,
                            "lastLogin": Date().description
                            ])
                    }
                    else {
                        //Returning user, only update last login
                        usersRef.child(user.uid).child("lastLogin").setValue(Date().description)
                        let isAdmin = snapshot.childSnapshot(forPath: user.uid).childSnapshot(forPath: "isAdmin").value as! Int
                        this.userIsAdmin = isAdmin == 0 ? false : true
                    }
                })
                
                //Admins
//                let adminsRef = Database.database().reference().child("admins")
//                adminsRef.observeSingleEvent(of: .value, with: { (snapshot) in
//                    if snapshot.hasChild(user.uid) {
//                        adminsRef.child(user.uid).child("lastLogin").setValue(Date().description)
//                        this.userIsAdmin = true
//                    }
//                })
            }
            else {
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
