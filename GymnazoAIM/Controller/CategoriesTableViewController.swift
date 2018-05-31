//
//  CategoriesTableViewController.swift
//  GymnazoAIM
//
//  Created by Local Account 123-28 on 3/14/17.
//  Copyright © 2017 Austin McInnis. All rights reserved.
//

import UIKit
import Firebase

class CategoryCell: UITableViewCell {
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var textField: UITextField!
    
}

class CategoriesTableViewController: UITableViewController, UITextFieldDelegate, NewFocusPointDelegate {
    
    @IBOutlet var addFocusPointButton: UIBarButtonItem!
    @IBOutlet var cancelButton: UIBarButtonItem!
    @IBOutlet var deleteButton: UIBarButtonItem!
    @IBOutlet var saveButton: UIBarButtonItem!
    private var newFocusPoint = false
    
    var focusPoints = [FocusPoint]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItems = [self.editButtonItem]
//        self.navigationItem.rightBarButtonItems = [addFocusPointButton]
        
        //Firebase
        let database = Database.database().reference()
        let categoryNames = database.child("category_names")
        categoryNames.observe(.childAdded, with: {
            [weak self] (snapshot) in
            guard let this = self else { return }
            
            let focusPointName = snapshot.key
            let firebase = snapshot.value
            
            let focusPoint = FocusPoint(name: focusPointName, firebase: firebase as! [String : String])
            this.focusPoints.append(focusPoint)

            let set = IndexSet.init(integer: this.focusPoints.count-1)
            this.tableView.insertSections(set, with: .automatic)
            if this.newFocusPoint == true {
                this.tableView.scrollToRow(at: IndexPath(row:0, section: this.focusPoints.count-1), at: .top, animated: true)
                this.newFocusPoint = false
            }
        })
        
        categoryNames.observe(.childRemoved, with: {
            [weak self] (snapshot) in
            guard let this = self else { return }
            
            let focusPoint = snapshot.key
            if let index = this.focusPoints.index(where: { $0.name == focusPoint }) {
                this.focusPoints.remove(at: index)
                let set = IndexSet.init(integer: index)
                this.tableView.deleteSections(set, with: .automatic)
            }
        })
        
        categoryNames.observe(.childChanged, with: {
            [weak self] (snapshot) in
            guard let this = self else { return }
            print(snapshot)
            let focusName = snapshot.key
            if let index = this.focusPoints.index(where: { $0.name == focusName }) {
                let focusPoint = this.focusPoints[index]
                focusPoint.update(firebase: snapshot.value as! [String:String])
            }
            
            for i in 0..<this.focusPoints.count {
                let sectionTitle = this.tableView(this.tableView, titleForHeaderInSection: i)
                if focusName == sectionTitle {
                    this.tableView.reloadSections(IndexSet(integer: i), with: .automatic)
                }
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - New Focus Point Delegate
    
    func didCreateNewFocusPoint(newFocusPoint: Bool) {
        self.newFocusPoint = newFocusPoint
    }

    // MARK: - Text Field Delegate
    
    @IBAction func categoryNameEntered(_ sender: UITextField) {
        let cell = sender.superview?.superview as! CategoryCell
        if let indexPath = tableView.indexPath(for: cell) {
            let focusPoint = focusPoints[indexPath.section]
            let modelValue = focusPoint.categories[indexPath.row]
            if sender.text != modelValue {
                if let category = sender.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
                    //Rejects numeric only categories
                    guard CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: category)) == false else {
                        let alert = UIAlertController(title: "Invalid Category Name: \"\(category)\"", message: "Category names must contain at least one character.", preferredStyle: .alert)
                        let dismissAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: nil)
                        alert.addAction(dismissAction)
                        self.present(alert, animated: true, completion: nil)
//                        sender.becomeFirstResponder()
                        return
                    }
                    print("Value changed from \"\(modelValue)\" to \"\(category)\"!")
                    focusPoint.editCatName(indexPath: indexPath, newName: category)
                }
            }
        }
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        print("Here")
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - Table View data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
//        if tableView.isEditing {
//            return self.focusPoints.count + 1
//        }
//
        return self.focusPoints.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
//        if tableView.isEditing {
//            //Insert row for New Focus Point
//            if (section == 0) { return 1 }
//            else {
//                return self.focusPoints[section-1].categories.count + 1
//            }
//        }
        if tableView.isEditing {
            return self.focusPoints[section].categories.count + 1
        }
        return self.focusPoints[section].categories.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if tableView.isEditing && indexPath.section == 0 {
//            return tableView.dequeueReusableCell(withIdentifier: "NewFocusPointCell")!
//        }
//        else {
//            let section = (tableView.isEditing) ? indexPath.section - 1 : indexPath.section
            let section = indexPath.section
            if indexPath.row == focusPoints[section].categories.count {
                let cell = tableView.dequeueReusableCell(withIdentifier: "AddCategoryCell", for: indexPath)
                return cell
            }
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell") as! CategoryCell

                // Configure the cell...
                cell.textField.delegate = self
                if tableView.isEditing {
                    cell.textField.isHidden = false
                    cell.title.isHidden = true
                    cell.textField.text = focusPoints[section].categories[indexPath.row]
                    cell.selectionStyle = .default
                }
                else {
                    cell.textField.isHidden = true
                    cell.title.isHidden = false
                    cell.title.text = focusPoints[section].categories[indexPath.row]
                    cell.selectionStyle = .none
                }
                return cell
            }
//        }
    }

    //MARK: UITableViewDelegate
    
//    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
//        if tableView.isEditing {
//            if indexPath.section == 0 { return .none }
//        }
//        let section = (tableView.isEditing) ? indexPath.section - 1 : indexPath.section
//        let catCount = focusPoints[section].categories.count
//        if indexPath.row == catCount { return .none }
//
//        return .delete
//    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
            if indexPath.row < focusPoints[indexPath.section].categories.count {
                if let count = tableView.indexPathsForSelectedRows?.count {
                    updateSelectedRowsCount(count: count)
                }
                else {
                    updateSelectedRowsCount(count: 0)
                }
            }
            else {
                insertNewCategoryCell(indexPath: indexPath)
            }
        }
    }
    
    func insertNewCategoryCell(indexPath: IndexPath) {
        let focusPoint = focusPoints[indexPath.section]
        focusPoint.categories.append("")
        self.tableView.insertRows(at: [IndexPath(row: indexPath.row, section: indexPath.section)], with: .automatic)
        if let cell = self.tableView.cellForRow(at: indexPath) as? CategoryCell {
            cell.textField.becomeFirstResponder()
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if tableView.isEditing{
            if let count = tableView.indexPathsForSelectedRows?.count {
                updateSelectedRowsCount(count: count)
            }
            else {
                updateSelectedRowsCount(count: 0)
            }
        }
    }
    
    func updateSelectedRowsCount(count: Int) {
        if count == 0 {
            deleteButton.title = "Delete"
            deleteButton.isEnabled = false
        }
        else {
            deleteButton.title = "Delete (\(count))"
            deleteButton.isEnabled = true
        }
    }
    
    @IBAction func saveEdit(_ sender: Any) {
        let alert = UIAlertController(title: "Save", message: "Are you sure you want to update categorical information for all exercises?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: {
            [weak self] (alert) in
            guard let this = self else { return }
//            this.edited = false
            for focusPoint in this.focusPoints {
                if let edits = focusPoint.edits {
                    let fpRef = Database.database().reference().child("category_names").child(focusPoint.name)
                    fpRef.updateChildValues(edits)
                    focusPoint.edits = nil
                }
            }
            this.setEditing(false, animated: true)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func cancelEdit(_ sender: Any) {
//        edited = false
        self.setEditing(false, animated: true)
    }
    
    @IBAction func deleteRows(_ sender: Any) {
        let alert = UIAlertController(title: "Confirmation", message: "Are you sure you want to delete these categories?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: {
            [weak self] (alert) in
            guard let this = self else { return }
            if let selectedPaths = this.tableView.indexPathsForSelectedRows {
                for indexPath in selectedPaths {
                    this.tableView(this.tableView, commit: .delete, forRowAt: indexPath)
                }
                this.deleteButton.title = "Delete"
                this.deleteButton.isEnabled = false
            }
            this.setEditing(false, animated: true)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        if tableView.isEditing {
//            if section == 0 {
//                return "New Focus Point"
//            }
//            else {
//                return self.focusPoints[section-1].name
//            }
//        }
        return self.focusPoints[section].name
    }
    
//    func reloadSections() {
//        let sectionsSet = IndexSet(integersIn: 0..<tableView.numberOfSections)
//        tableView.reloadSections(sectionsSet, with: .automatic)
//    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if editing == true {
            self.navigationItem.rightBarButtonItems = [cancelButton, deleteButton, saveButton]
            deleteButton.title = "Delete"
            deleteButton.isEnabled = false
        }
        else {
            self.navigationItem.rightBarButtonItems = [editButtonItem]
            
            let sectionsSet = IndexSet(integersIn: 0..<tableView.numberOfSections)
            var deletePaths: [IndexPath]?
            for sect in sectionsSet {
                if sect == 0 { continue }
                let section = sect - 1
                let focusPoint = focusPoints[section]
//                for index in 0..<tableView(tableView, numberOfRowsInSection: section) {
                for index in 0..<focusPoint.categories.count {
                    let indexPath = IndexPath(row: index, section: section)
                    if let cell = tableView(tableView, cellForRowAt: indexPath) as? CategoryCell {
                        print(cell.title.text!)
                        guard cell.title.text?.isEmpty == false else {
                            if deletePaths == nil {
                                deletePaths = [IndexPath]()
                            }
                            // TODO: Find case to use commented line. May need to change due to guard condition.
//                            focusPoint.removeCatName(indexPath: indexPath)
                            deletePaths?.append(indexPath)
                            continue
                        }
                    }
                }
            }
            
            if let deletePaths = deletePaths {
                tableView.deleteRows(at: deletePaths, with: .automatic)
            }
        }
        self.tableView.reloadData()
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        let count = self.focusPoints[indexPath.section].categories.count
        if indexPath.row == count {
            return false
        }
        return true
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let focusPoint = focusPoints[indexPath.section]
            focusPoint.removeCatName(indexPath: indexPath)
            if focusPoints.count == 0 {
                focusPoints.remove(at: indexPath.section)
            }
            
            //Change from array to uniqueid?
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "newFocusPoint" {
            if let nav = segue.destination as? UINavigationController {
                if let newFPVC = nav.topViewController as? NewFocusPointController {
                    newFPVC.delegate = self
                }
            }
        }
    }


}
