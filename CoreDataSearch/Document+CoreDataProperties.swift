//
//  Document+CoreDataProperties.swift
//  CoreDataSearch
//
//  Created by Grant Maloney on 10/2/18.
//  Copyright © 2018 Grant Maloney. All rights reserved.
//
//

import Foundation
import CoreData


extension Document {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Document> {
        return NSFetchRequest<Document>(entityName: "Document")
    }

    @NSManaged public var content: String?
    @NSManaged public var name: String?
    @NSManaged public var size: Int64
    @NSManaged public var dateModified: NSDate?

}
