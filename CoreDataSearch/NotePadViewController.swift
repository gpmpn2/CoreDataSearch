//
//  NotePadViewController.swift
//  Documents
//
//  Created by Grant Maloney on 8/26/18.
//  Copyright © 2018 Grant Maloney. All rights reserved.
//

import UIKit
import CoreData

class NotePadViewController: UIViewController {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    var viewingDocument: Document?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if viewingDocument != nil {
            contentTextView.text = viewingDocument?.content
            titleTextField.text = viewingDocument?.name
            self.navigationItem.title = viewingDocument?.name
        } else {
            contentTextView.text = ""
            titleTextField.text = ""
        }
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(self.saveNote))
        
        titleTextField.addTarget(self, action: #selector(self.textFieldDidChange), for: UIControl.Event.editingChanged)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc
    func saveNote() {
        if titleTextField.text == "" {
            print("Error, empty text field!")
            return
        }
        
        if contentTextView.text == "" {
            print("Error, empty text view!")
            return
        }
        
        if let title = titleTextField.text {
            if viewingDocument != nil {
                viewingDocument?.update(name: title, content: contentTextView.text)
            } else {
                viewingDocument = Document(name: title, content: contentTextView.text)
            }
            
            do {
                if let context = viewingDocument?.managedObjectContext {
                    try context.save()
                }
            } catch {
                print("Error saving document!")
            }
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc
    func textFieldDidChange() {
        self.navigationItem.title = titleTextField.text
    }
}
