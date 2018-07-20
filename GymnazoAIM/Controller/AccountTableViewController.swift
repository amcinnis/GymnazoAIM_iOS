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

class AccountTableViewController: UITableViewController, UserAdministratorDelegate {
    var isAdmin = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        self.navigationItem.title = "Account"
        if let tabBarVC = self.tabBarController as? TabBarViewController {
            tabBarVC.adminDelegate = self
            self.isAdmin = tabBarVC.userIsAdmin
        }
    }
    
    @IBAction func signOut(_ sender: Any) {
        let alert = UIAlertController(title: "Sign Out", message: "Are you sure you want to sign out?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {
            (action) in
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
        }))
        self.present(alert, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - User Administrator Delegate
    
    func isAdminChanged(isAdmin: Bool, forUser: User?) {
        self.isAdmin = isAdmin
        self.tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return isAdmin == false ? 2 : 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            return 2
        }
        else if isAdmin == false {
            if section == 1 {
                return 1
            }
            else {
                return 0
            }
        }
        else {
            switch section {
            case 1:
                return 2
            case 2:
                return 1
            default:
                return 0
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let auth = Auth.auth()
            let userName = auth.currentUser?.displayName
            let email = auth.currentUser?.email
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "UserNameCell", for: indexPath)
                cell.detailTextLabel?.text = userName
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "UserEmailCell", for: indexPath)
                cell.detailTextLabel?.text = email
                return cell
            default:
                return tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
            }
        }
        else if isAdmin == false {
            if indexPath.section == 1 {
                return tableView.dequeueReusableCell(withIdentifier: "SignOutCell", for: indexPath)
            }
            else {
                return tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
            }
        }
        else {
            switch indexPath.section {
            case 1:
                switch indexPath.row {
                case 0:
                    return tableView.dequeueReusableCell(withIdentifier: "EditCategoriesCell", for: indexPath)
                case 1:
                    return tableView.dequeueReusableCell(withIdentifier: "ManageUsersCell", for: indexPath)
                default:
                    return tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
                }
            case 2:
               return tableView.dequeueReusableCell(withIdentifier: "SignOutCell", for: indexPath)
            default:
                return tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
            }
        }
    }
}
