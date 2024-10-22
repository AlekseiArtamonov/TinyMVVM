//
//  Note+CoreDataProperties.swift
//  TinyMVVMDemo
//
//  Created by Aleksei Artamonov on 5/18/19.
//  Copyright © 2019 test. All rights reserved.
//
//

import Foundation
import CoreData


extension Note {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Note> {
        return NSFetchRequest<Note>(entityName: "Note")
    }

    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var text: String?
    @NSManaged public var timestamp: NSDate?
    @NSManaged public var trackName: String?
    @NSManaged public var type: Int16

}
