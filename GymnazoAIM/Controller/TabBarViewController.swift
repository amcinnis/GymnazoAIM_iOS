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

protocol UserAdministratorDelegate {
    func isAdminChanged(isAdmin: Bool, forUser: User?)
}

class TabBarViewController: UITabBarController, UITabBarControllerDelegate, QueueDataSourceDelegate {
    
    var adminDelegate:UserAdministratorDelegate?
    var queue = [Exercise]() {
        didSet {
            if let delegate = queueTableDelegate {
                delegate.updateTable()
            }
        }
    }
    var queueTableDelegate:QueueTableDelegate?
    var userIsAdmin = false {
        didSet {
            if let delegate = adminDelegate {
                delegate.isAdminChanged(isAdmin: userIsAdmin, forUser: nil)
            }
        }
    }
    
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
                            "lastLogin": Date().description(with: .current)
                            ])
                        this.userIsAdmin = false
                    }
                    else {
                        //Returning user, only update last login
                        usersRef.child(user.uid).child("lastLogin").setValue(Date().description(with: .current))
                        let isAdmin = snapshot.childSnapshot(forPath: user.uid).childSnapshot(forPath: "isAdmin").value as! Int
                        this.userIsAdmin = isAdmin == 0 ? false : true
                    }
                })
            }
            else {
                this.performSegue(withIdentifier: "Show Login", sender: nil)
            }
        }
        
        //Firebase Admin Management for current user
        let auth = Auth.auth()
        if let user = auth.currentUser {
            let selfAdminRef = Database.database().reference().child("users").child(user.uid).child("isAdmin")
            selfAdminRef.observe(.value) { [weak self] (snapshot) in
                guard let this = self else { return }
                let adminInt = snapshot.value as! Int
                this.userIsAdmin = adminInt == 0 ? false : true
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

}
