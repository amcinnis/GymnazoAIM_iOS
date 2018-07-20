//
//  AccountTableViewController.swift
//  GymnazoAIM
//
//  Created by Austin McInnis on 3/17/18.
//  Copyright © 2018 Austin McInnis. All rights reserved.
//

import UIKit
import FirebaseAuth
import GoogleSignIn

class AccountTableViewController: UITableViewController {
    var isAdmin = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        self.navigationItem.title = "Account"
        if let tabBarVC = self.tabBarController as? TabBarViewController {
            isAdmin = tabBarVC.userIsAdmin
            print("isAdmin: \(isAdmin)")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    @IBAction func signOut(_ sender: Any) {
        GIDSignIn.sharedInstance().signOut()
        let auth = Auth.auth()
        do {
            let username = auth.currentUser?.displayName
            try auth.signOut()
            if let username = username {
                print("\(username) successfully signed out.")
            }
        }
        catch let signOutError as NSError {
            print("Error signing out: \(signOutError.localizedDescription)")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return isAdmin == false ? 1 : 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if isAdmin == false {
            if section == 0 {
                return 1
            }
            else {
                return 0
            }
        }
        else {
            switch section {
            case 0:
                return 2
            case 1:
                return 1
            default:
                return 0
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if isAdmin == false {
            return tableView.dequeueReusableCell(withIdentifier: "SignOutCell", for: indexPath)
        }
        else {
            switch indexPath.section {
            case 0:
                switch indexPath.row {
                case 0:
                    return tableView.dequeueReusableCell(withIdentifier: "EditCategoriesCell", for: indexPath)
                case 1:
                    return tableView.dequeueReusableCell(withIdentifier: "ManageUsersCell", for: indexPath)
                default:
                    return tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
                }
            case 1:
               return tableView.dequeueReusableCell(withIdentifier: "SignOutCell", for: indexPath)
            default:
                return tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
            }
        }
    }
}
