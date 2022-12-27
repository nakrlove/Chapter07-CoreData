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
    
    func fetch(entity: String) -> [NSManagedObject] {
        
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
        
        let alert = UIAlertController(title: "게시글 수정", message: nil, preferredStyle: .alert)
        alert.addTextField(){ $0.text = title }
        alert.addTextField(){ $0.text = contents }
        
        alert.addAction(UIAlertAction(title: "Cancal", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save", style: .default){ (_) in
            guard let title = alert.textFields?.first?.text , let contents = alert.textFields?.last?.text else
            {
                return
            }
            
            if self.edit(object: record ,title: title , contents: contents) == true {
                self.tableView.reloadData()
            }
            
        })
        
        self.present(alert, animated: false)
    }
    
    func edit(object: NSManagedObject,title: String, contents: String) -> Bool {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext

//        let object = NSEntityDescription.insertNewObject(forEntityName: "Board", into: context)
        object.setValue(title, forKey: "title")
        object.setValue(contents, forKey: "contents")
        object.setValue(Date(), forKey: "regdate")
        
        do {
            try context.save()
//            self.list.append(object)
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
        
        do {
            try context.save()
            self.list.append(object)
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
        let alert = UIAlertController(title: "게시글 등록", message: nil, preferredStyle: .alert)
        alert.addTextField(){ $0.placeholder = "제목" }
        alert.addTextField(){ $0.placeholder = "내용" }
        
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
