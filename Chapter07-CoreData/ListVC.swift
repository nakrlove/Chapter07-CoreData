//
//  ListVC.swift
//  Chapter07-CoreData
//
//  Created by nakrlove on 2022/12/27.
//

import UIKit
import CoreData

class ListVC: UITableViewController {
    
    lazy var list: [NSManagedObject] = {
        return self.fetch(entity:"Board")
    }()
    
    func fetch(entity: String = "Board") -> [NSManagedObject] {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
//        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Board")
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entity)
        let sort = NSSortDescriptor(key: "regdate", ascending: false)
        fetchRequest.sortDescriptors = [sort]
        let result = try! context.fetch(fetchRequest)
        return result
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        let addBtn = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(add(_:)))
        self.navigationItem.rightBarButtonItem = addBtn
    }

    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.list.count
    }

 
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let record   = self.list[indexPath.row]
        let title    = record.value(forKey: "title") as? String
        let contents = record.value(forKey: "contents") as? String
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        cell?.textLabel?.text = title
        cell?.detailTextLabel?.text = contents
        // Configure the cell...

        return cell!
    }

    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath ) {
    
        let object = self.list[indexPath.row]
        
        if self.delete(object:  object) {
            self.list.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        let record   = self.list[indexPath.row]
        let title    = record.value(forKey: "title") as? String
        let contents = record.value(forKey: "contents") as? String
        
        let alert = UIAlertController(title: "????????? ??????", message: nil, preferredStyle: .alert)
        alert.addTextField(){ $0.text = title }
        alert.addTextField(){ $0.text = contents }
        
        alert.addAction(UIAlertAction(title: "Cancal", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save", style: .default){ (_) in
            guard let title = alert.textFields?.first?.text , let contents = alert.textFields?.last?.text else
            {
                return
            }
            
            if self.edit(object: record ,title: title , contents: contents) == true {
                
                let cell = self.tableView.cellForRow(at: indexPath)
                cell?.textLabel?.text = title
                cell?.detailTextLabel?.text = contents

                let firstIndexPath = IndexPath(item: 0, section: 0)
                self.tableView.moveRow(at: indexPath, to: firstIndexPath)
//                self.tableView.reloadData()
            }
            
        })
        
        self.present(alert, animated: false)
        
//        if self.edit(object: record , title: title!  , contents: contents!) == true {
//
//            let cell = self.tableView.cellForRow(at: indexPath)
//            cell?.textLabel?.text = title
//            cell?.detailTextLabel?.text = contents
//
//            let firstIndexPath = IndexPath(item: 0, section: 0)
//            self.tableView.moveRow(at: indexPath, to: firstIndexPath)
//        }
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let object = self.list[indexPath.row]
        let uvc = self.storyboard?.instantiateViewController(withIdentifier: "LogVC") as! LogVC
        uvc.board = (object as! BoardMO)
        
        self.show(uvc, sender: self)
    }
    
    func edit(object: NSManagedObject,title: String, contents: String) -> Bool {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext

//        let object = NSEntityDescription.insertNewObject(forEntityName: "Board", into: context)
        object.setValue(title, forKey: "title")
        object.setValue(contents, forKey: "contents")
        object.setValue(Date(), forKey: "regdate")
        
        
        
        let logObject = NSEntityDescription.insertNewObject(forEntityName: "Log", into: context) as! LogMO
        logObject.regdate = Date()
        logObject.type = logType.edit.rawValue
        
       
        (object as! BoardMO).addToLogs(logObject)
        do {
            try context.save()
//            self.list.append(object)
            self.list = self.fetch()
            return true
        }catch {
            context.rollback()
            return false
        }
    }
    
    func save(title: String, contents: String) -> Bool {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext

        let object = NSEntityDescription.insertNewObject(forEntityName: "Board", into: context)
        object.setValue(title, forKey: "title")
        object.setValue(contents, forKey: "contents")
        object.setValue(Date(), forKey: "regdate")
        
        let logObject = NSEntityDescription.insertNewObject(forEntityName: "Log", into: context) as! LogMO
        logObject.regdate = Date()
        logObject.type = logType.create.rawValue
        (object as! BoardMO).addToLogs(logObject)
        
        
        do {
            try context.save()
//            self.list.append(object)
            self.list.insert(object, at: 0)
            return true
        }catch {
            context.rollback()
            return false
        }
    }
    
    func delete(object: NSManagedObject) -> Bool {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext

        context.delete(object)
        
        do {
            try context.save()
            return true
        }catch {
            context.rollback()
            return false
        }
    }
    
    @objc func add(_ sender: Any) {
        let alert = UIAlertController(title: "????????? ??????", message: nil, preferredStyle: .alert)
        alert.addTextField(){ $0.placeholder = "??????" }
        alert.addTextField(){ $0.placeholder = "??????" }
        
        alert.addAction(UIAlertAction(title: "Cancal", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save", style: .default){ (_) in
            guard let title = alert.textFields?.first?.text , let contents = alert.textFields?.last?.text else
            {
                return
            }
            
            if self.save(title: title , contents: contents) == true {
                self.tableView.reloadData()
            }
            
        })
        
        self.present(alert, animated: false)
    }
}
