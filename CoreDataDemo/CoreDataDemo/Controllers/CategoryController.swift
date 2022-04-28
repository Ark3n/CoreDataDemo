//
//  ViewController.swift
//  CoreDataDemo
//
//  Created by Arken Sarsenov on 26.04.2022.
//

import UIKit
import CoreData
import SwiftUI

final class CategoryController: UIViewController {
    //MARK: - Properties
    private var categories = [CategoryModel]()
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private let tableView = UITableView()
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemPink
        title = "Category"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTagert))
        configureTableView()
        fetchData()
    }
    //MARK: - Actions
    @objc private func addTagert() {
        //Create alert
        let alert = UIAlertController(title: "Add Category", message: "", preferredStyle: .alert)
        alert.addTextField()
        //Configure button hadler
        let submitButton = UIAlertAction(title: "Add", style: .default) { (action) in
            //Get text field from alert
            let textfield = alert.textFields?.first
            //Create person new object
            let newCategory = CategoryModel(context: self.context)
            newCategory.name = textfield?.text
            //Save new object to CoreData
            do {
                try self.context.save()
            } catch {
                print("DEBUG: issue with creating new object \(error.localizedDescription)")
            }
            // Update tableView
            self.fetchData()
        }
        alert.addAction(submitButton)
        present(alert, animated: true)
    }
    
    //MARK: - Fetch data from the CoreData
    func fetchData() {
        //Fetch data from CoreData to display in the tableview
        do {
            self.categories = try context.fetch(CategoryModel.fetchRequest())
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } catch {
            print("DEBUG: issue with fetching data: \(error.localizedDescription)")
        }
    }
    //MARK: - UITableView Configuration
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)
        tableView.frame = view.bounds
    }
}

//MARK: - UITableViewDelegate & UITableDataSource
extension CategoryController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        categories.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = categories[indexPath.row].name
        return cell
    }
    
    //MARK: - Delete category from the CoreData
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
            //Which category to be remove
            let removeToCategory = self.categories[indexPath.row]
            //Remove Category
            self.context.delete(removeToCategory)
            // save the data to the CoreData
            do {
                try self.context.save()
            } catch {
                print("DEBUG: can not remove data \(error.localizedDescription)")
            }
            self.fetchData()
        }
        return UISwipeActionsConfiguration(actions: [action])
    }
        
    //MARK: - Move to next ViewController
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = ToDoController()
        vc.selectedCategory = categories[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
}
