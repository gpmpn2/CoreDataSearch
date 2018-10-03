//
//  Document+CoreDataClass.swift
//  CoreDataSearch
//
//  Created by Grant Maloney on 10/2/18.
//  Copyright © 2018 Grant Maloney. All rights reserved.
//
//

import CoreData
import UIKit

@objc(Document)
public class Document: NSManagedObject {

    var modifiedDate: Date? {
        get {
            return dateModified as Date?
        }
        set {
            dateModified = newValue as NSDate?
        }
    }
    
    convenience init?(name: String, content: String) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate  //UIKit is needed to access UIApplication
        guard let managedContext = appDelegate?.persistentContainer.viewContext else { return nil }
        self.init(entity: Document.entity(), insertInto: managedContext)
        
        self.name = name
        self.size = Int64(content.count)
        self.content = content
        self.modifiedDate = Date()
    }
    
    func update(name: String, content: String) {
        self.name = name
        self.size = Int64(content.count)
        self.content = content
    }
    
}
