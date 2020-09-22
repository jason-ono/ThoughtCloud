//
//  CategoryViewController.swift
//  ThoughtCloud
//
//  Created by Jason Ono on 7/27/20.
//  Copyright © 2020 Jason Ono. All rights reserved.
//


import UIKit
import CoreData

class CategoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource{
    
    // root variables
    let windowSize: CGRect = UIScreen.main.bounds
    let windowWidth: CGFloat = UIScreen.main.bounds.width
    let windowHeight: CGFloat = UIScreen.main.bounds.height
    
    // TableView Content reloaded each time the VC is called
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray4
        createTableView()
        setupNaviBar()
        loadCategory()
        emptyCheck() // If there is nothing to display, guide to press "+" button for a new category is shown
    }
    
    // table view variable
    var tableView = UITableView()
    
    // row component prep
    var categoryArray:[Category] = []
    
    // CoreData variables
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let indexPath =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    
    // MARK: - TableView methods
    
    func createTableView(){
        tableView = UITableView(frame: self.view.bounds, style: UITableView.Style.plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = UIColor.white
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "myCell")
        
        // add to a view
        view.addSubview(tableView)
    }
    
    // label for the guide to press "+" button for a new category
    let addSuggestion = UILabel()
    
    func emptyCheck(){
        if (categoryArray.count == 0){
            view.addSubview(addSuggestion)
            addSuggestion.text = "Press + to add a new category."
            addSuggestion.textColor = .systemGray3
            addSuggestion.translatesAutoresizingMaskIntoConstraints = false
            [addSuggestion.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: windowWidth*0.05),
             addSuggestion.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: windowWidth*0.05),
            ].forEach{ $0.isActive = true }
        }
    }
    
    // number of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }

    // dequeue operation
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "myCell")
        tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath)
        cell.textLabel?.text = "\(categoryArray[indexPath.row].name ?? "")"
        cell.detailTextLabel?.text = "\(categoryArray[indexPath.row].ccs?.count ?? 0)"
        cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        return cell
    }

    // When a row is selected, a new VC is pushed
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // create a new VC to push
        let listVC = ListViewController()
        listVC.selectedCategory = categoryArray[indexPath.row]
        navigationController?.pushViewController(listVC, animated: true)
        // deselect the row at the end
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // deletion of a cell
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            context.delete(categoryArray[indexPath.row])
            categoryArray.remove(at: indexPath.row)
            saveCategory()
        }
    }

    // MARK: - CoreData methods
    func saveCategory(){
        do{
            try context.save()
        }catch{
            print("error")
        }
        self.tableView.reloadData()
    }
    
    func loadCategory(with request: NSFetchRequest<Category> = Category.fetchRequest()){
        do{
            categoryArray = try context.fetch(request)
        }catch{
            print("error, tough luck")
        }
    }
    
    // MARK: - NavigationBar methods
    
    func setupNaviBar(){
        navigationItem.title = "Categories"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped(_:)))
    }
    
    // Operation for adding a new category.
    @objc func addTapped(_ sender: UIBarButtonItem){
        var textField = UITextField()
        let alert = UIAlertController(title: "Create a new category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Create", style: .default) { (action) in
            let newCategory = Category(context: self.context)
            newCategory.name = textField.text!
            self.categoryArray.append(newCategory)
            self.saveCategory()
            self.addSuggestion.removeFromSuperview()
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "type here"
            textField = alertTextField
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (cancel) in }
        alert.addAction(action)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - UIPickerViewDataSource methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        do{
            let request: NSFetchRequest<Category> = Category.fetchRequest()
            categoryArray = try context.fetch(request)
            return categoryArray.count
        }catch{
            return 0
        }
    }
}


