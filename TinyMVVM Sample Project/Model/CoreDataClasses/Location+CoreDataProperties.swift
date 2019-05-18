//
//  Location+CoreDataProperties.swift
//  TinyMVVMDemo
//
//  Created by Aleksei Artamonov on 5/12/19.
//  Copyright © 2019 test. All rights reserved.
//
//

import Foundation
import CoreData


extension Location {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Location> {
        return NSFetchRequest<Location>(entityName: "Location")
    }

    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var name: String?
    @NSManaged public var timestamp: NSDate?

}
