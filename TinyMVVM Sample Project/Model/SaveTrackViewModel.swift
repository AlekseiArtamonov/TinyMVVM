//
//  SaveTrackViewModel.swift
//  TinyMVVMDemo
//
//  Created by Aleksei Artamonov on 5/2/19.
//  Copyright © 2019 test. All rights reserved.
//

import Foundation

public protocol SaveTrackViewModeling: class {
    var trackName: Property<String> { get }
    var trackNote: Property<String> { get }
    func saveTrack(completion: @escaping (Bool) -> Void)
}

class SaveTrackViewModel {
    public var trackName: Property<String>
    public var trackNote: Property<String>
    private let locationService: LocationServicing
    private let dataStorageManager: DataStorageManaging
    private let startDate: Date
    private let endDate: Date?
    
    init(locationService: LocationServicing, dataStorageManager: DataStorageManaging, startDate: Date, endDate: Date?) {
        self.locationService = locationService
        self.dataStorageManager = dataStorageManager
        self.startDate = startDate
        self.endDate = endDate
        trackName = Property("")
        trackNote = Property("")
    }
}

extension SaveTrackViewModel: SaveTrackViewModeling {
    func saveTrack(completion: @escaping (Bool) -> Void) {
        locationService.stopTracking()
        dataStorageManager.saveTrack(with: trackName.value, description: trackNote.value, startDate: startDate, endDate: endDate ?? Date()) { (success) in
            DispatchQueue.main.async {
                completion(success)
            }            
        }
    }
}
