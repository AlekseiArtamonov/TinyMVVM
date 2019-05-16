//
//  MapViewRouter.swift
//  TinyMVVMDemo
//
//  Created by Aleksei Artamonov on 5/2/19.
//  Copyright © 2019 test. All rights reserved.
//

import Foundation
import UIKit

public protocol MapViewRouting {
}

public class MapViewRouter: BaseRouter {
    private enum Segue: String {
        case saveTrack
        case addNote
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier, let typed = Segue(rawValue: identifier) else {
            return
        }
        switch typed {
        case .saveTrack:
            guard let vc = segue.destination as? SaveTrackViewController else {
                fatalError("cannot construct SaveTrackViewController")
            }
            guard let navigation = viewController as? MapViewController else {
                return
            }
            vc.router = SaveTrackRouter(with: vc)
            vc.viewModel = navigation.viewModel?.getSaveTrackViewModel()
            
        case .addNote:
            break
            
        default:
            break
        }
    }
}

extension MapViewRouter: MapViewRouting {
  
}
