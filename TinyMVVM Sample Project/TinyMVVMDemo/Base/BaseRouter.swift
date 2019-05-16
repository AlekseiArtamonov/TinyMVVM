//
//  BaseRouter.swift
//  TinyMVVMDemo
//
//  Created by Aleksei Artamonov on 3/26/19.
//  Copyright © 2019 test. All rights reserved.
//
import UIKit

public class BaseRouter {
    weak var viewController: BaseViewController?
    
    init(with viewController: BaseViewController) {
        self.viewController = viewController
        viewController.segueHandler = { [weak self] (segue, sender) in
            self?.prepare(for: segue, sender: sender)
        }
    }
    
    func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // no-op
    }
}
