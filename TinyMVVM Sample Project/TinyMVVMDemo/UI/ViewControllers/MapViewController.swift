//
//  MapViewController.swift
//  TinyMVVM
//
//  Created by Aleksei Artamonov on 3/26/19.
//  Copyright © 2019 test. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: BaseViewController, MKMapViewDelegate {
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var addNoteButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    public var router: MapViewRouting?
    
    private var route: MKOverlay?
    public var viewModel: MapViewModeling? {
        didSet {
            viewModel?.locations.addListener { [weak self] (locations) in
                guard self?.isViewLoaded ?? false else {
                    return
                }
                self?.createRoute(with: locations)
            }
            
            viewModel?.regionRadius.addListener { [weak self] (radius) in
                guard self?.isViewLoaded ?? false else {
                    return
                }
                guard let location = self?.mapView.userLocation.location else {
                    return
                }
                self?.setMapCenter(with: location, radius: radius)
            }
            
            viewModel?.currentLocation?.addListener { [weak self] (location) in
                guard self?.isViewLoaded ?? false else {
                    return
                }
                self?.setMapCenter(with: location, radius: self?.viewModel?.regionRadius.value ?? 500.0)
            }
            
            viewModel?.speed.addListener { [weak self] (value) in
                guard self?.isViewLoaded ?? false else {
                    return
                }
                
                self?.speedLabel.text = value
            }
            
            viewModel?.distanse.addListener { [weak self] (value) in
                guard self?.isViewLoaded ?? false else {
                    return
                }
                self?.distanceLabel.text = value
            }
        }
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        if viewModel == nil {
            viewModel = MapViewModel(locationService: LocationService.shared, dataStorageManager: DataStorageManager.sharedInstance)
        }
        
        if router == nil {
            router = MapViewRouter(with: self)
        }
        
    }
    
    @IBAction func handleStartButtonTap(_ sender: Any) {
        viewModel?.startTrack()
    }
    
    @IBAction func handleStopButtonTap(_ sender: Any) {
        viewModel?.stopTrack()
    }
    
    @IBAction func handleClearButtonTap(_ sender: Any) {
        if let route = route {
            mapView.removeOverlay(route)
        }
        viewModel?.clearTrack()
    }
    
    func setMapCenter(with location: CLLocation, radius: CLLocationDistance) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: radius, longitudinalMeters: radius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func createRoute(with locations: [CLLocation]) {
        let locs = locations.map { $0.coordinate }
        let newRoute = MKPolyline(coordinates: locs, count: locations.count)
        
        if let route = route {
            mapView.removeOverlay(route)
        }
        mapView.addOverlay(newRoute)
        self.route = newRoute
    }

    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.lineWidth = 3.0
            polylineRenderer.strokeColor = .red
            return polylineRenderer
        }
        return MKPolylineRenderer(overlay: overlay)
    }
    
    func mapView(_ mapView: MKMapView, didAdd renderers: [MKOverlayRenderer]) {
        
    }
}
