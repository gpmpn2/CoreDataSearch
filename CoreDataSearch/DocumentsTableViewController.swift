//
//  DocumentsTableViewController.swift
//  Documents
//
//  Created by Grant Maloney on 8/26/18.
//  Copyright © 2018 Grant Maloney. All rights reserved.
//

import UIKit
import CoreData

class DocumentsTableViewController: UITableViewController {
    
    var documents = [Document]()
    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Document")
    @IBAction func addButton(_ sender: Any) {
        self.performSegue(withIdentifier: "moveToNotepad", sender: nil)
    }
    
    let searchController = UISearchController(searchResultsController: nil)
    var filteredDocuments = [Document]()
    let formatter = DateFormatter()
    
    @IBOutlet weak var addButtonItem: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadDocuments()
        
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        
        self.navigationItem.rightBarButtonItem = addButtonItem
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Documents"
        searchController.searchBar.delegate = self
        
        definesPresentationContext = true
        self.navigationItem.searchController = searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadDocuments()
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredDocuments.count
        } else {
            return documents.count
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        if let cell = cell as? CustomTableViewCell {

            var document: Document
            
            if isFiltering() {
                document = filteredDocuments[indexPath.row]
            } else {
                document = documents[indexPath.row]
            }

            cell.noteTitle.text = document.name
            cell.noteSize.text = "Size: \(document.size) Bytes"
            if let date = document.modifiedDate {
                cell.dateModified.text = "Modified: \(formatter.string(from: date))"
            }
        }

        return cell
    }
    
    func loadDocuments() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Document> = Document.fetchRequest()
        
        do {
            documents = try managedContext.fetch(fetchRequest)
        } catch {
            return
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? NotePadViewController {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let selectedRow = indexPath.row
                
                var givenDocument: Document
                
                if isFiltering() {
                    givenDocument = self.filteredDocuments[selectedRow]
                    destination.viewingDocument = givenDocument
                } else {
                    givenDocument = self.documents[selectedRow]
                }
                
                destination.viewingDocument = givenDocument
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "moveToNotepad", sender: nil)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if isFiltering() {
            return false
        } else {
            return true
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            let managedContext = appDelegate.persistentContainer.viewContext
            managedContext.delete(documents[indexPath.row])
            
            
            documents.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            do {
                try managedContext.save()
            } catch {
                print("Failed to save!")
            }
        }
    }
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredDocuments = documents.filter({( document : Document) -> Bool in
            if let name = document.name {
                if name.lowercased().contains(searchText.lowercased()) {
                    return true
                } else {
                    if let content = document.content {
                        return content.lowercased().contains(searchText.lowercased())
                    } else {
                        return false
                    }
                }
            } else {
                return false
            }
        })
        
        tableView.reloadData()
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
}

extension DocumentsTableViewController: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
}

extension DocumentsTableViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
