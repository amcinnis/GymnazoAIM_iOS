//
//  NewFocusPointController.swift
//  GymnazoAIM
//
//  Created by Austin McInnis on 3/14/17.
//  Copyright © 2017 Austin McInnis. All rights reserved.
//

import UIKit

class NewCategoryCell: UITableViewCell {
    @IBOutlet var textField: UITextField!
    
}

class NewFocusPointController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    var categories = [String]()
    
    @IBOutlet var nameField: UITextField!
    @IBOutlet var categoryTableView: UITableView!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.categoryTableView.delegate = self
        self.categoryTableView.dataSource = self
        self.nameField.delegate = self
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func done(_ sender: Any) {
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        print("Edit")
        if !(textField.text?.isEmpty)!{
            self.editButtonItem.isEnabled = true
        }
        else {
            self.editButtonItem.isEnabled = false
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.nameField {
            self.categoryTableView.headerView(forSection: 0)?.textLabel?.text = self.nameField.text
            self.nameField.resignFirstResponder()
        }
        else {
            textField.resignFirstResponder()
        }
        return false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == categories.count {
            self.categories.append("Placeholder")
            self.categoryTableView.insertRows(at: [IndexPath(row: categories.count-1, section: 0)], with: .automatic)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return categories.count + 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (self.nameField.text?.isEmpty)! {
            return "New Focus Point"
        }
        else {
            return self.nameField.text
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Configure the cell...
        if indexPath.row == categories.count {
            return tableView.dequeueReusableCell(withIdentifier: "AddCategoryCell", for: indexPath)
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewCategoryCell", for: indexPath) as! NewCategoryCell
            cell.textField.delegate = self
            
            return cell
        }
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        self.categoryTableView.setEditing(editing, animated: animated)
    }
    
    // Override to support conditional editing of the table view.
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        if indexPath.row == categories.count {
            return false
        }
        return true
    }
    

    
    // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    

    
    // Override to support rearranging the table view.
    func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
