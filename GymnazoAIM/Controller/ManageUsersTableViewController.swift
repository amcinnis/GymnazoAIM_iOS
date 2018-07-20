//
//  ManageUsersTableViewController.swift
//  GymnazoAIM
//
//  Created by Austin McInnis on 7/18/18.
//  Copyright © 2018 Austin McInnis. All rights reserved.
//

import Firebase
import UIKit

class UserCell: UITableViewCell {
    var user: User?
}

class ManageUsersTableViewController: UITableViewController {

    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        self.navigationItem.title = "Manage Users"
        
        let usersRef = Database.database().reference().child("users")
        usersRef.observe(.childAdded) { [weak self] (snapshot) in
            guard let this = self else { return }
            
            let uid = snapshot.key
            let name = snapshot.childSnapshot(forPath: "name").value as! String
            let email = snapshot.childSnapshot(forPath: "email").value as! String
            let isAdminInt = snapshot.childSnapshot(forPath: "isAdmin").value as! Int
            let isAdmin = isAdminInt == 0 ? false : true
            let lastLogin = snapshot.childSnapshot(forPath: "lastLogin").value as! String
            let user = User(name: name, uid: uid, email: email, isAdmin: isAdmin, lastLogin: lastLogin)
            this.users.append(user)
            this.tableView.insertRows(at: [IndexPath(row: this.users.count-1, section: 0)], with: .automatic)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.users.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserCell

        // Configure the cell...
        cell.user = self.users[indexPath.row]
        cell.textLabel?.text = cell.user?.name
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowUserDetail" {
            if let cell = sender as? UserCell {
                if let detailVC = segue.destination as? UserDetailsTableViewController {
                    detailVC.user = cell.user
                }
            }
        }
    }

}
