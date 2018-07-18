//
//  ManageUsersTableViewController.swift
//  GymnazoAIM
//
//  Created by Austin McInnis on 7/18/18.
//  Copyright © 2018 Austin McInnis. All rights reserved.
//

import Firebase
import UIKit

class ManageUsersTableViewController: UITableViewController {

    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        let usersRef = Database.database().reference().child("users")
        usersRef.observe(.childAdded) { [weak self] (snapshot) in
            guard let this = self else { return }
            
            let uid = snapshot.key
            let name = snapshot.childSnapshot(forPath: "name").value as! String
            let email = snapshot.childSnapshot(forPath: "email").value as! String
            let lastLogin = snapshot.childSnapshot(forPath: "lastLogin").value as! String
            
            var user = User(name: name, email: email, lastLogin: lastLogin)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }

}
