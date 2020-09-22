//
//  ListViewController.swift
//  ThoughtCloud
//
//  Created by Jason Ono on 7/27/20.
//  Copyright © 2020 Jason Ono. All rights reserved.
//

import UIKit
import CoreData

class ListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate{
   
    // root helper variables
    let windowSize: CGRect = UIScreen.main.bounds
    let windowWidth: CGFloat = UIScreen.main.bounds.width
    let windowHeight: CGFloat = UIScreen.main.bounds.height
    
    // table view declaration
    var tableView = UITableView()
    
    // current category
    var selectedCategory = Category()
    
    // row component prep
    var ccArray:[CloudCollection] = []
    
    // CoreData
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let indexPath =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    
    // Table content reloaded each time VC is called
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }       
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGray4
        createTableView()
        setupNaviBar()
        loadCC()
        emptyCheck() // If there is nothing to display, guide to press "+" button for a new category is shown
    }

    // MARK: - TableView methods
    
    // guide to press "+" button to add a new category
    let addSuggestion = UILabel()
    func emptyCheck(){
        if (ccArray.count == 0){
            view.addSubview(addSuggestion)
            addSuggestion.text = "Press + to add a new category."
            addSuggestion.textColor = .systemGray3
            addSuggestion.translatesAutoresizingMaskIntoConstraints = false
            [addSuggestion.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: windowWidth*0.05),
             addSuggestion.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: windowWidth*0.05),
            ].forEach{ $0.isActive = true }
        }
    }
    
    func createTableView(){
        // create UITableView
        tableView = UITableView(frame: self.view.bounds, style: UITableView.Style.plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = UIColor.white
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "myCell")
        view.addSubview(tableView)
    }
    
    // number of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ccArray.count
    }
       
    // dequeue operation
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "myCell")
        tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath)
        cell.textLabel?.text = "\(ccArray[indexPath.row].title ?? "")"
        let lastUpdatedString = ccArray[indexPath.row].dateLastUpdated
        cell.detailTextLabel?.text = "\(dateToString(lastUpdatedString ?? Date()))"
        cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        return cell
    }
    
    //  Operation when a row is selected
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // create a new VC to push
        let typeVC = TypeViewController()
        typeVC.cc = ccArray[indexPath.row]
        navigationController?.pushViewController(typeVC, animated: true)
        // deselect the row at the end
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // deletion of a cell
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            context.delete(ccArray[indexPath.row])
            ccArray.remove(at: indexPath.row)
            saveCC()
        }
    }

    // MARK: - CoreData methods
    func saveCC(){
        do{
            try context.save()
        }catch{
            print("error")
        }
        self.tableView.reloadData()
    }
    
    func loadCC(){
        let ccs = selectedCategory.ccs
        ccArray = ccs?.allObjects as! [CloudCollection]
    }
    
    func dateToString(_ date: Date)->String{
        let dF = DateFormatter()
        dF.dateStyle = .short
        dF.timeStyle = .short
        let result = dF.string(from: date)
        return result
    }
    
// MARK: - NavigationBar methods
    func setupNaviBar(){
        navigationItem.title = selectedCategory.name
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped(_:)))
    }
    
    @objc func addTapped(_ sender: UIBarButtonItem){
           var textField = UITextField()
           let alert = UIAlertController(title: "Create a new collection", message: "", preferredStyle: .alert)
           let action = UIAlertAction(title: "Create", style: .default) { (action) in
               let newCC = CloudCollection(context: self.context)
               newCC.dateCreated = Date() // current date
               newCC.dateLastUpdated = Date()
               newCC.title = textField.text!
               self.selectedCategory.addToCcs(newCC)
               self.ccArray.append(newCC)
               self.saveCC()
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
}
