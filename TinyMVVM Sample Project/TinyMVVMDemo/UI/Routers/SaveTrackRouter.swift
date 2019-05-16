//
//  SaveTrackRouter.swift
//  TinyMVVMDemo
//
//  Created by Aleksei Artamonov on 5/2/19.
//  Copyright © 2019 test. All rights reserved.
//

import Foundation
import UIKit

public protocol SaveTrackRouting {
    func close()
}

public class SaveTrackRouter: BaseRouter {

}

extension SaveTrackRouter: SaveTrackRouting {
    public func close() {
        viewController?.navigationController?.popViewController(animated: true)
    }
}
