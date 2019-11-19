//
//  ViewController.swift
//  Todoey
//
//  Created by Tan Vinh Phan on 11/18/19.
//  Copyright © 2019 PTV. All rights reserved.
//

import UIKit

class ToDoListViewController: UITableViewController {
    
    var itemArray = [Item]()
    
    //userDefault: file .plist in folder Data of a physical device or virtual device
    let userDefault = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let newItem = Item(title: "Learn on Udemy", done: false)
        itemArray.append(newItem)
        
        let newItem2 = Item(title: "Find Mike", done: false)
        itemArray.append(newItem2)
        
        let newItem3 = Item(title: "Go to Library", done: false)
        itemArray.append(newItem3)
        
        if let items = userDefault.array(forKey: "ToDoListArray") as? [Item] {
            itemArray = items
        }
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
    
    }
    
    //MARK: - TableView Datasource methods
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoListCell", for: indexPath)
        
        let item = itemArray[indexPath.row]
        
        cell.textLabel?.text = item.title
        cell.accessoryType = item.done == true ? .checkmark : .none
    
        return cell
    }
    
    //MARK: - TableView Delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        itemArray[indexPath.row].done = !itemArray[indexPath.row].done

        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK: - Add New Items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
        
        alert.addTextField { (alertTextView) in
            alertTextView.placeholder = "Create new item"
            textField = alertTextView
        }
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            //what will happen once the user clicks the Add Item
            
            if textField.text != "" {
                
                let newItem = Item(title: textField.text!, done: false)
    
                self.itemArray.append(newItem)
    
                self.userDefault.set(self.itemArray, forKey: "ToDoListArray")
                self.tableView.reloadData()
            }
        }
        
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
    }
}

