//
//  ToDoController.swift
//  CoreDataDemo
//
//  Created by Arken Sarsenov on 26.04.2022.
//

import UIKit
import CoreData

final class ToDoController: UIViewController {
    //MARK: - Properties
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var selectedCategory: CategoryModel?
    private var tasks = [Item]()
    private var filteredTasks = [Item]()
    private var searchBarIsEmpty: Bool {
        guard let text = search.searchBar.text else {return false}
        return text.isEmpty
    }
    private var isFiltering: Bool {
        return search.isActive && !searchBarIsEmpty
    }
    private let tableView = UITableView()
    private let search = UISearchController(searchResultsController: nil)
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = selectedCategory?.name
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
        setupSearchController()
        setupTableView()
        fetchData()
    }
    
    //MARK: - Actions
    @objc private func addTapped() {
        let alert = UIAlertController(title: "Add task", message: "", preferredStyle: .alert)
        alert.addTextField()
        let submitButton = UIAlertAction(title: "Add", style: .default) { (action) in
            let textfiled = alert.textFields?.first
            let newToDo = Item(context: self.context)
            if textfiled?.text?.count != 0 {
            newToDo.title = textfiled?.text
            newToDo.done = false
            newToDo.parentCategory = self.selectedCategory
            }
            do {
                try self.context.save()
                
            } catch {
                print("DEBUG: Can not save todo: \(error.localizedDescription)")
            }
            self.fetchData()
        }
        alert.addAction(submitButton)
        present(alert, animated: true)
    }
    
    //MARK: - setup UISearchController
    private func setupSearchController() {
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        search.searchBar.sizeToFit()
        search.searchBar.placeholder = "search"
        tableView.tableHeaderView = search.searchBar
        definesPresentationContext = true
    }
    
    
    
    //MARK: - setupTableView
    private func setupTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        tableView.frame = view.bounds
    }
    
    //MARK:  - fetchData from CoreData
    func fetchData() {
        guard let name = selectedCategory?.name else {return}
        let categoryPredicate = NSPredicate(format: "parentCategory.name==%@", name)
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        request.predicate = categoryPredicate
        do {
            self.tasks = try context.fetch(request)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        } catch {
            print("DEBUG: cant fetch ToDo list \(error.localizedDescription)")
        }
    }
}


//MARK: - UITableViewDelegate and DataSource
extension ToDoController: UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(search.searchBar.text!)
    }
    
    private func filterContentForSearchText(_ searchText: String) {
        filteredTasks = tasks.filter({(task: Item) -> Bool in
            return (task.title?.lowercased().contains(searchText.lowercased()))!
        })
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filteredTasks.count
        }
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var task: Item
        if isFiltering {
            task = filteredTasks[indexPath.row]
        } else {
            task = tasks[indexPath.row]
        }
        cell.textLabel?.text = task.title
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction(style: .destructive, title: "Delete") { action, view, completionHandler in
            var task: Item
            if self.isFiltering {
                task = self.filteredTasks[indexPath.row]
            } else {
                task = self.tasks[indexPath.row]
            }
            let removeItem = task
            self.context.delete(removeItem)
            do {
                try self.context.save()
            } catch {
                print("DEBUG: can not update CoreDate after deleting Item")
            }
            self.fetchData()
        }
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
