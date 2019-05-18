//
//  Track+CoreDataProperties.swift
//  TinyMVVMDemo
//
//  Created by Aleksei Artamonov on 5/12/19.
//  Copyright © 2019 test. All rights reserved.
//
//

import Foundation
import CoreData


extension Track {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Track> {
        return NSFetchRequest<Track>(entityName: "Track")
    }

    @NSManaged public var endDate: NSDate?
    @NSManaged public var name: String?
    @NSManaged public var note: String?
    @NSManaged public var startDate: NSDate?
    @NSManaged public var relationship: NSSet?
    @NSManaged public var relationship1: NSSet?

}

// MARK: Generated accessors for relationship
extension Track {

    @objc(addRelationshipObject:)
    @NSManaged public func addToRelationship(_ value: Location)

    @objc(removeRelationshipObject:)
    @NSManaged public func removeFromRelationship(_ value: Location)

    @objc(addRelationship:)
    @NSManaged public func addToRelationship(_ values: NSSet)

    @objc(removeRelationship:)
    @NSManaged public func removeFromRelationship(_ values: NSSet)

}

// MARK: Generated accessors for relationship1
extension Track {

    @objc(addRelationship1Object:)
    @NSManaged public func addToRelationship1(_ value: Note)

    @objc(removeRelationship1Object:)
    @NSManaged public func removeFromRelationship1(_ value: Note)

    @objc(addRelationship1:)
    @NSManaged public func addToRelationship1(_ values: NSSet)

    @objc(removeRelationship1:)
    @NSManaged public func removeFromRelationship1(_ values: NSSet)

}
