//
//  UserDetailsTableViewController.swift
//  GymnazoAIM
//
//  Created by Austin McInnis on 7/19/18.
//  Copyright © 2018 Austin McInnis. All rights reserved.
//

import UIKit

class AdministratorCell: UITableViewCell {
    @IBOutlet var adminButton: UIButton!
    
}

class UserDetailsTableViewController: UITableViewController {
    
    var user: User?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        if let user = user {
            self.navigationItem.title = user.name
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch section {
            case 0: return 4
            case 1: return 1
            default: return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // Configure the cell...
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserDetailCell", for: indexPath)
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Name"
                cell.detailTextLabel?.text = self.user?.name
                return cell
            case 1:
                cell.textLabel?.text = "Email"
                cell.detailTextLabel?.text = self.user?.email
                return cell
            case 2:
                cell.textLabel?.text = "Last Login"
                cell.detailTextLabel?.text = self.user?.lastLogin
                return cell
            case 3:
                cell.textLabel?.text = "Account Type"
                if let user = self.user {
                    cell.detailTextLabel?.text = user.isAdmin ? "Administrator" : "User"
                }
                return cell
            default:
                cell.textLabel?.text = "Error"
                cell.detailTextLabel?.text = "Unexpected Cell"
            }
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "AdministratorCell", for: indexPath) as! AdministratorCell
            if self.user?.isAdmin == true {
//                cell.adminButton.titleLabel?.text = "Remove Admin Status"
                cell.adminButton.setTitle("Remove Admin Status", for: .normal)
                cell.adminButton.tintColor = .red
            }
            else {
//                cell.adminButton.titleLabel?.text = "Make Administrator"
                cell.adminButton.setTitle("Make Administrator", for: .normal)
                cell.adminButton.tintColor = .green
            }
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
            return cell
        }
    }

}
