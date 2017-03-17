//
//  NewFocusPointController.swift
//  GymnazoAIM
//
//  Created by Austin McInnis on 3/14/17.
//  Copyright © 2017 Austin McInnis. All rights reserved.
//

import UIKit
import Firebase

class NewCategoryCell: UITableViewCell {
    @IBOutlet var textField: UITextField!
    
}

class NewFocusPointController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIGestureRecognizerDelegate {
    
    var categories = [String]() {
        didSet {
            valuesChanged()
        }
    }
    
    @IBOutlet var nameField: UITextField!
    @IBOutlet var categoryTableView: UITableView!
    @IBOutlet var doneButton: UIButton!

    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.categoryTableView.delegate = self
        self.categoryTableView.dataSource = self
        self.nameField.delegate = self
        self.nameField.addTarget(self, action: #selector(NewFocusPointController.valuesChanged), for: .editingChanged)
        self.nameField.becomeFirstResponder()
        
//        let tap = UITapGestureRecognizer(target: self, action: #selector(NewFocusPointController.tappedOutside))
//        self.view.addGestureRecognizer(tap)
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    func valuesChanged() {
        if !(nameField.text?.isEmpty)! && self.categories.count > 0 {
            doneButton.isEnabled = true
        }
        else {
            doneButton.isEnabled = false
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.view.endEditing(true)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func done(_ sender: Any) {
        let databaseRef = FIRDatabase.database().reference()
        let categoryNamesRef = databaseRef.child("category_names")
        if let focusPointName = nameField.text {
            if (focusPointName.rangeOfCharacter(from: NSCharacterSet.alphanumerics) != nil) {
                //Remove empty cells
                var set: IndexSet?
                for (index, category) in categories.enumerated() {
                    if category.rangeOfCharacter(from: NSCharacterSet.alphanumerics) == nil {
                        if set == nil {
                            set = IndexSet(integer: index)
                        }
                        else {
                            set?.insert(index)
                        }
                    }
                }
                if let set = set {
                    var indexPaths = [IndexPath]()
                    for index in set.reversed() {
                        self.categories.remove(at: index)
                        indexPaths.append(IndexPath(row: index, section: 0))
                    }
                    self.categoryTableView.deleteRows(at: indexPaths, with: .automatic)
                }
                //Rejects numeric only categories
                var valid = true
                for category in categories {
                    if let range = category.rangeOfCharacter(from: .decimalDigits) {
                        if category == category.substring(with: range) {
                            valid = false
                            let alert = UIAlertController(title: "Invalid Category Name: \"\(category)\"", message: "Category names must contain at least one character.", preferredStyle: .alert)
                            let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
                            alert.addAction(dismissAction)
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                }
                if categories.count > 0 && valid {
                    let focusPoint = FocusPoint(name: focusPointName, values: categories)
                    categoryNamesRef.child(focusPointName).setValue(focusPoint.firebase)
                    dismiss(animated: true, completion: nil)
                }
            }
            else {
                //UIAlertView "Enter valid Focus Point Name"
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Text Field Delegate
    
    @IBAction func nameFieldChanged(_ sender: UITextField) {
        self.categoryTableView.headerView(forSection: 0)?.textLabel?.text = sender.text?.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    @IBAction func categoryNameEntered(_ sender: UITextField) {
        if let cell = sender.superview?.superview as? NewCategoryCell {
            if let indexPath = self.categoryTableView.indexPath(for: cell) {
                self.categories[indexPath.row] = sender.text!.trimmingCharacters(in: .whitespacesAndNewlines)
                print("Categories: \(self.categories)")
            }
        }
    }
    
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        if !(textField.text?.isEmpty)!{
//            self.editButtonItem.isEnabled = true
//        }
//        else {
//            self.editButtonItem.isEnabled = false
//        }
//        
//        return true
//    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.nameField {
            self.nameField.resignFirstResponder()
        }
        else {
            textField.resignFirstResponder()
            if let cell = textField.superview?.superview as? NewCategoryCell {
                if let indexPath = self.categoryTableView.indexPath(for: cell) {
                    let nextIndexPath = IndexPath(row: indexPath.row + 1, section: indexPath.section)
                    if let nextCell = self.categoryTableView.cellForRow(at: nextIndexPath) as? NewCategoryCell {
                        nextCell.textField.becomeFirstResponder()
                    }
                    else {
                        insertNewCategoryCell()
                    }
                }
            }
        }
        return false
    }

    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == categories.count {
            insertNewCategoryCell()
        }
    }
    
    func insertNewCategoryCell() {
        self.categories.append("")
        print("Categories.count: \(self.categories.count)")
        self.categoryTableView.insertRows(at: [IndexPath(row: categories.count-1, section: 0)], with: .automatic)
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
            return self.nameField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
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
            cell.textField.becomeFirstResponder()
            
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
            if let cell = tableView.cellForRow(at: indexPath) as? NewCategoryCell {
                cell.textField.text = nil
            }
            self.categories.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view

        }    
    }
    
    // Override to support rearranging the table view.
    func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let category = categories.remove(at: fromIndexPath.row)
        categories.insert(category, at: to.row)
    }
    
    // Override to support conditional rearranging of the table view.
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        if indexPath.row == categories.count {
            return false
        }
        return true
    }
    
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        if proposedDestinationIndexPath.row == categories.count {
            return IndexPath(row: proposedDestinationIndexPath.row - 1, section: 0)
        }
        return proposedDestinationIndexPath
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
