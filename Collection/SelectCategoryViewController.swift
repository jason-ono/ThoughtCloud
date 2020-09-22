//
//  SelectCategoryViewController.swift
//  WordCloudTest
//
//  Created by Kotaro Ono on 2020/08/20.
//  Copyright © 2020 Kotaro. All rights reserved.
//

import UIKit
import CoreData

class SelectCategoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
    
    // table view declaration
    var tableView = UITableView()
    
    // row component prep
    var categoryArray:[Category] = []
    
    // CoreData
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let indexPath =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray4
        createTableView()
        setupNaviBar()
        loadCategory()
        print(indexPath)
    }
    
    @objc func addTapped(_ sender: UIBarButtonItem){
        var textField = UITextField()
        let alert = UIAlertController(title: "Create a new category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Create", style: .default) { (action) in
            let newCategory = Category(context: self.context)
            newCategory.name = textField.text!
            self.categoryArray.append(newCategory)
            self.saveCategory()
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "type here"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - TableView methods
    
    func createTableView(){
        // create UITableView
        tableView = UITableView(frame: self.view.bounds, style: UITableView.Style.plain)
        print(indexPath)
        // extension parameters
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = UIColor.white
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "myCell")
        
        // add to a view
        view.addSubview(tableView)
    }
    
    // number of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }

    // dequeue operation
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "myCell")
        tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath)
//        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath)
        cell.textLabel?.text = "\(categoryArray[indexPath.row].name ?? "")"
        cell.detailTextLabel?.text = "\(categoryArray[indexPath.row].ccs?.count ?? 0)"
        cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        return cell
    }

    //  Operation when a row is selected
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        cc.parentCategory?.removeFromCcs(cc)
        categoryArray[indexPath.row].addToCcs(cc)
        saveCategory()
        self.dismiss(animated: true, completion: nil)
//        // create a new VC to push
//        let listVC = ListViewController()
//        listVC.selectedCategory = categoryArray[indexPath.row]
//        navigationController?.pushViewController(listVC, animated: true)
//        // deselect the row at the end
//        tableView.deselectRow(at: indexPath, animated: true)
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
    var cc = CloudCollection()
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
}


