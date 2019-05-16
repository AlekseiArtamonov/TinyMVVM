//
//  CoreDataManager.swift
//  PhotoMaps
//
//  Created by Aleksei Artamonov on 7/3/18.
//  Copyright © 2018 test. All rights reserved.
//

import Foundation
import CoreData
import MapKit

public protocol DataStorageManaging {
    func getAllLocations(withCompletion completion: @escaping ([Location]) -> Void)
    func getAllLocations(by trackName: String, completion: @escaping ([Location]) -> Void)
    func saveLocations(_ locations: [CLLocation], withCompletion copmletion:@escaping () -> Void)
    func saveLocation(_ location: CLLocation, timestamp: Date, name: String)
    func saveTrack(with name: String, description: String, startDate: Date, endDate: Date, completion: @escaping (Bool) -> Void)
    func clearTrack(by Name: String)
    var persistentContainer: NSPersistentContainer { get }
}

class DataStorageManager {
    private enum Constants {
        static let untitled = "untitled"
    }
    static let sharedInstance = DataStorageManager()
    
    lazy var backgroundContext :NSManagedObjectContext = {
        return persistentContainer.newBackgroundContext()
    }()
    
    private init() {
        
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "TinyMVVMDemo")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    public func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

extension DataStorageManager: DataStorageManaging {
    //Location
    public func getAllLocations(withCompletion completion: @escaping ([Location]) -> Void) {
        self.persistentContainer.performBackgroundTask { (context) in 
            var elements = [Location]()
            do {
                elements = try context.fetch(Location.fetchRequest())
            } catch {
                print("CoreDataManager fetching locations failed")
            }
            completion(elements);
        }
    }
    
    public func getAllLocations(by trackName: String, completion: @escaping ([Location]) -> Void) {
        self.persistentContainer.performBackgroundTask { (context) in
            var elements = [Location]()
            do {
                elements = try context.fetch(Location.fetchRequest())
            } catch {
                print("CoreDataManager fetching locations failed")
            }
            completion(elements);
        }
    }
    
    public func saveLocations(_ locations: [CLLocation], withCompletion copmletion:@escaping () -> Void) {
        self.persistentContainer.performBackgroundTask { (context) in
        let context = self.persistentContainer.viewContext
            do {
                for location in locations {
//                    let object = try context.fetch(Location.fetchBy(location.timestamp))
//                    if object.isEmpty { //avoid dupication of objects in data storage
                        let loc = Location(context: context)
                        loc.name = Constants.untitled
                        loc.latitude = location.coordinate.latitude
                        loc.longitude = location.coordinate.longitude
                        loc.timestamp = location.timestamp as NSDate
//                    }
                }
                try context.save()
            } catch {
                print("CoreDataManager saving locations failed")
            }
            copmletion()
        }
    }
    
    public func saveLocation(_ location: CLLocation, timestamp: Date, name: String) {
        self.persistentContainer.performBackgroundTask { (context) in
            do {
                    let loc = Location(context: context)
                    loc.name = name
                    loc.latitude = location.coordinate.latitude
                    loc.longitude = location.coordinate.latitude
                    loc.timestamp = location.timestamp as NSDate
                    try context.save()
            } catch {
                print("CoreDataManager saving locations failed")
            }
        }
    }
    
//Track
    public func saveTrack(with name: String, description: String, startDate: Date, endDate: Date, completion: @escaping (Bool) -> Void) {
        self.persistentContainer.performBackgroundTask { (context) in
            do {
                //Todo check name
                let track = Track(context: context)
                track.name = name
                track.note = description
                track.startDate = NSDate(timeIntervalSince1970: startDate.timeIntervalSince1970)
                track.endDate = NSDate(timeIntervalSince1970: endDate.timeIntervalSince1970)
                
                let fetchRequest: NSFetchRequest<Location> = Location.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "name == %@", Constants.untitled)
                let result = try? context.fetch(fetchRequest)
                if let resultData = result, !resultData.isEmpty {
                    for location in resultData {
                        print(location.name ?? "")
                        location.setValue(name, forKey: "name")
                    }
                } else {
                    completion(false)
                }
                try context.save()
                completion(true)
            } catch {
                completion(false)
                print("CoreDataManager saving locations failed")
            }
        }
    }
    
    public func clearTrack(by name: String) {
        self.persistentContainer.performBackgroundTask { (context) in
            do {
                //Todo check name
                let fetchRequest: NSFetchRequest<Track> = Track.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "name == %@", name)
                let result = try? context.fetch(fetchRequest)
                if let resultData = result, !resultData.isEmpty {
                    for track in resultData {
                        print(track.name ?? "")
                        context.delete(track)
                    }
                }

                let fetchRequest2: NSFetchRequest<Location> = Location.fetchRequest()
                fetchRequest2.predicate = NSPredicate(format: "name == %@", name)
                let result2 = try? context.fetch(fetchRequest2)
                if let resultData = result2, !resultData.isEmpty {
                    for location in resultData {
                        print(location.name ?? "")
                        context.delete(location)
                    }
                }

                
                try context.save()
//                completion(true)
            } catch {
//                completion(false)
                print("CoreDataManager saving locations failed")
            }
        }
    }
    
    
//    func getLocationBy(_ name: String) -> [Location] {
//        
//        do {
//            var fetchRequest = Location.fetchRequest()
//            fetchRequest
//            let result = try self.persistentContainer.viewContext.fetch()
//            if !result.isEmpty {
//                if let title = result[0].name {
//                    location = LocationModel(title, result[0].lat, result[0].lon)
//                }
//            }
//        } catch {
//            print("CoreDataManager fetching locations failed")
//        }
//        return location;
//    }
    
    
//    //Note methods
//    func getAllNotes() -> Array<Note> {
//        let context = self.persistentContainer.viewContext
//        var elements: Array<Note> = []
//            do {
//                elements = try context.fetch(Note.fetchRequest())
//            } catch {
//                print("CoreDataManager fetching locations failed")
//            }
//            return elements;
//    }
//    func getNoteBy(_ name: String) -> Note? {
//        var note: Note? = nil
//        do {
//            let result = try self.persistentContainer.viewContext.fetch(Note.fetchBy(name))
//            if !result.isEmpty {
//                note = result[0] as Note
//            }
//
//        } catch {
//            print("CoreDataManager fetching locations failed")
//        }
//        return note;
//    }
//
//
//    func updateNote(_ noteToSave: Note) {
//        self.persistentContainer.performBackgroundTask { (context) in
//            do {
//                if let name = noteToSave.locationName {
//                    let object = try context.fetch(Note.fetchBy(name))
//                    if object.isEmpty { //avoid dupication of objects in data storage
//                        let note = Note(context: context)
//                        note.locationName = noteToSave.locationName
//                        note.noteValue = noteToSave.noteValue
//                        try context.save()
//                    }
//                }
//            } catch {
//                print("CoreDataManager saving locations failed")
//            }
//        }
//    }
//
//
//    func saveNewNote(_ locationName: String, _ noteText: String) {
//        self.persistentContainer.performBackgroundTask { (context) in
//            do {
//                let object = try context.fetch(Note.fetchBy(locationName))
//                if object.isEmpty { //avoid dupication of objects in data storage
//                    let note = Note(context: context)
//                    note.locationName = locationName
//                    note.noteValue = noteText
//                    try context.save()
//                }
//            } catch {
//                print("CoreDataManager saving locations failed")
//            }
//        }
//    }
//
//
//    // Clearing
//    func clearStorage(withCompletion completion: @escaping () -> Void) {
//        self.persistentContainer.performBackgroundTask { (context) in
//            do {
//                let result: Array<Location> = try context.fetch(Location.fetchRequest())
//
//                for fetchedObject: Location in result
//                {
//                    context.delete(fetchedObject)
//                }
//
//                let notesResult: Array<Note> = try context.fetch(Note.fetchRequest())
//
//                for fetchedObject: Note in notesResult
//                {
//                    context.delete(fetchedObject)
//                }
//                try context.save()
//            } catch {
//                print("CoreDataManager saving locations failed")
//            }
//            completion()
//        }
//    }
}
