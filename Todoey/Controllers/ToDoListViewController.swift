//
//  ViewController.swift
//  Todoey
//
//  Created by Tan Vinh Phan on 11/18/19.
//  Copyright © 2019 PTV. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class ToDoListViewController: SwipeTableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    let realm = try! Realm()
    
    var todoItems: Results<Item>? {
        didSet {
            tableView.reloadData()
        }
    }
    
    var selectedCategory: ItemCategory? {
        didSet {
            loadItems()
        }
    }
    
    //MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = 80
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let hexCode = selectedCategory?.hexColor
            else { print("Error with selected Category hex code"); return }
        
        setupNavigationBar(withHexCode: hexCode)
        setColorForSearchBar(withHexCode: hexCode)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        setupNavigationBar()
    }
    
    //MARK: - Setup Navigation Bar
    
    func setupNavigationBar(withHexCode hexCode: String = "1D9BF6") {
        
        guard let navBar = navigationController?.navigationBar
            else { fatalError("Navigation controller does not exist!") }
        
            guard let colour = UIColor(hexString: hexCode)
                else { print("Error: the hex code is not exist"); return }
            
            let contrastColour = ContrastColorOf(colour, returnFlat: true)
            
            if #available(iOS 13.0, *) {
                let navBarAppearance = UINavigationBarAppearance()
                
                navBarAppearance.configureWithOpaqueBackground()
                navBarAppearance.backgroundColor = colour
                navBarAppearance.largeTitleTextAttributes =
                    [NSAttributedString.Key.foregroundColor : contrastColour]
                
                navBar.scrollEdgeAppearance = navBarAppearance
                navBar.standardAppearance = navBarAppearance
                navBar.tintColor = contrastColour
                
            } else {
                navBar.barTintColor = contrastColour
                navBar.tintColor = contrastColour
                navBar.largeTitleTextAttributes =
                    [NSAttributedString.Key.foregroundColor : contrastColour]
            }
    }
    
    func setColorForSearchBar(withHexCode hexCode: String = "1D9BF6") {
        
        guard let colour = UIColor(hexString: hexCode)
            else { print("Error: the hex code is not exist"); return }
        
        let contrastColour = ContrastColorOf(colour, returnFlat: true)
        
        searchBar.searchTextField.backgroundColor = contrastColour
        searchBar.barTintColor = colour
    }
    
    //MARK: - Table View Datasource methods
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = todoItems?[indexPath.row] {
            
            cell.textLabel?.text = item.title
            
                let color = UIColor(hexString: selectedCategory!.hexColor)?.darken(byPercentage:
                    CGFloat(indexPath.row) / CGFloat(todoItems!.count))
                
                cell.backgroundColor = color
                cell.textLabel?.textColor = UIColor.init(contrastingBlackOrWhiteColorOn: color ?? UIColor.white, isFlat: true)
                cell.accessoryType = item.done == true ? .checkmark : .none
            
            
        } else {
            cell.textLabel?.text = "No Items Added"
        }
        
        return cell
    }
    
    //MARK: - Table View Delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = todoItems?[indexPath.row] {
            
            do {
                try realm.write {
                    
                    //Update item
                    item.done = !item.done
                }
            } catch {
                print("Error saving done status")
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        tableView.reloadData()
    }
    
    //MARK: - Delete Items
    
    override func updateModel(at indexPath: IndexPath) {
        
          if let item = self.todoItems?[indexPath.row] {
                  do {
                      try self.realm.write {
                          self.realm.delete(item)
                      }
                      
                  } catch {
                      print("Error with update Model: \(error)")
                  }
              }
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
                
                if let currentCategory = self.selectedCategory {
                    
                    do {
                        try self.realm.write {
                
                            let newItem = Item()
                            newItem.title = textField.text!
                            newItem.dateCreated = Date()
                            
                            currentCategory.items.append(newItem)
                            
                            self.realm.add(newItem)
                        }
                    } catch {
                        print("Error saving to do item: - \(error)")
                    }
                    
                }
                self.tableView.reloadData()
            }
        }
        
        alert.addAction(action)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Model Manupulation Methods
    
    func loadItems() {
        todoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
    }
    
}

//MARK: - UISearch Bar Delegate

extension ToDoListViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        todoItems = todoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
        
        DispatchQueue.main.async {
            searchBar.resignFirstResponder()
        }
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

        if searchBar.text?.count == 0 {
            loadItems()

            //perform UI process on main thread
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
