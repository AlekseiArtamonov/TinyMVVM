//
//  MapViewModel.swift
//  TinyMVVMDemo
//
//  Created by Aleksei Artamonov on 3/31/19.
//  Copyright © 2019 test. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation

public protocol MapViewModeling: class {
    var regionRadius: Property<Double> { get }
    var locations: Property<[CLLocation]> { get }
    var currentLocation: Property<CLLocation>? { get }
    var speed: Property<String> { get }
    var distanse: Property<String> { get }
    
    func startTrack()
    func stopTrack()
    func clearTrack()
    
    func getSaveTrackViewModel() -> SaveTrackViewModeling
}

public class MapViewModel: NSObject, NSFetchedResultsControllerDelegate {
    private enum Constants {
        static let untitled = "untitled"
    }
    
    public var regionRadius = Property(500.0)
    public var locations: Property<[CLLocation]>
    public var currentLocation: Property<CLLocation>?
    public var speed: Property<String>
    public var distanse: Property<String>
    private var dist = 0.0 {
        didSet {
            distanse.value = String(format: "%.3f km", dist / 1000.0)
        }
    }
    private var dateStart: Date?
    private var dateEnd: Date?
    
    lazy var fetchedResultsController: NSFetchedResultsController<Location> = {
        let fetchRequest = NSFetchRequest<Location>(entityName:"Location")
        fetchRequest.predicate = NSPredicate(format: "name == %@", Constants.untitled)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending:false)]
        
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                    managedObjectContext:  dataStorageManager.persistentContainer.viewContext,
                                                    sectionNameKeyPath: nil, cacheName: nil)
        controller.delegate = self
        
        do {
            try controller.performFetch()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return controller
    }()
        
    private let locationService: LocationServicing
    private let dataStorageManager: DataStorageManaging
    init(locationService: LocationServicing, dataStorageManager: DataStorageManaging) {
        self.locationService = locationService
        self.dataStorageManager = dataStorageManager
        self.locations = Property([])
        self.speed = Property("")
        self.distanse = Property("")
        if let location = locationService.currentLocation() {
           currentLocation = Property(location)
        }
        super.init()
    }
    
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if let locations = controller.fetchedObjects as? [Location] {
            self.locations.value = locations.map {
                return CLLocation(latitude: $0.latitude, longitude: $0.longitude)
            }
        }
        
        if let location = locationService.currentLocation() {
            if  location.speed >= 0 {
                let currentSpeed: Double = location.speed * 3600.0 / 1000.0
                speed.value = String(format: "%.1f km/h", currentSpeed)
            }
            if  currentLocation == nil{
                currentLocation = Property(location)
            } else {
                if let curLoc = currentLocation?.value {
                    dist += location.distance(from: curLoc)
                }
                currentLocation?.value = location
            }
        }
    }
}

extension MapViewModel: MapViewModeling {
    public func stopTrack() {
        dateEnd = Date()
        locationService.stopTracking()
    }
    
    public func getSaveTrackViewModel() -> SaveTrackViewModeling {
        return SaveTrackViewModel(locationService: locationService, dataStorageManager: dataStorageManager, startDate: dateStart ?? Date(), endDate: dateEnd)
    }
    
    public func startTrack() {
        fetchedResultsController.fetchedObjects
        locationService.requestAuthorization { [weak self] (status) in
            if status {
                self?.dateStart = Date()
                self?.locationService.startTracking()
            }
        }
    }
    
    public func clearTrack() {
        currentLocation = nil
        dist = 0.0
        dataStorageManager.clearTrack(by: Constants.untitled)
    }
}
