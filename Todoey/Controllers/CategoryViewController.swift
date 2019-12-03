//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Tan Vinh Phan on 11/25/19.
//  Copyright © 2019 PTV. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    
    var categories: Results<ItemCategory>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = 80
        self.tableView.separatorStyle = .none
        
        loadCategories()
    }
    
    // MARK: - Table view Data source methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return categories?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let category = categories?[indexPath.row] {
            cell.textLabel?.text = category.name
            
            let color =  UIColor(hexString: category.hexColor)
            
            cell.backgroundColor = color
            cell.textLabel?.textColor = UIColor.init(contrastingBlackOrWhiteColorOn: color ?? UIColor.white, isFlat: true)
        } else {
             cell.textLabel?.text = "No category added yet"
        }
        
        return cell
    }
    
      //MARK: - Table View Delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "goToItems", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToItems" {
            let toDoListVC = segue.destination as! ToDoListViewController
            
            if let selectedIndex = tableView.indexPathForSelectedRow {
                toDoListVC.selectedCategory = self.categories?[selectedIndex.row]
            }
        }
    }
    
    //MARK: - Data Manipulation Methods
    
    func save(category: ItemCategory) {
        do {
            try realm.write {
                realm.add(category)
            }
            
        } catch {
            print("Error saving to Realm: - \(error)")
        }
        
        self.tableView.reloadData()
    }
    
    func loadCategories() {

         //realm.objects -> categories will auto sync in real time (Realm func)
        categories = realm.objects(ItemCategory.self)
        
        self.tableView.reloadData()
    }
    
    //MARK: - Delete Data From Swipe
    
    override func updateModel(at indexPath: IndexPath) {
        if let category = self.categories?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(category)
                }
                
            } catch {
                print("Error with update Model: \(error)")
            }
        }
    }
    
    //MARK: - Add New Categories
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new Category", message: "", preferredStyle: .alert)
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new Category"
            textField = alertTextField
        }
        
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            
            if textField.text?.count != 0 {
                let newCategory = ItemCategory()
                newCategory.name = textField.text!
                newCategory.hexColor = UIColor.randomFlat().hexValue()
              
                self.save(category: newCategory)
            }
        }
        
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
    }
}


