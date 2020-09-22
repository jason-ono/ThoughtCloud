//
//  MainNaviController.swift
//  ThoughtCloud
//
//  Created by Jason Ono on 7/27/20.
//  Copyright © 2020 Jason Ono. All rights reserved.
//

import UIKit

/*
 MainNaviController is the root VC of the app.
 */
class MainNaviController: UINavigationController, UITabBarControllerDelegate{
    var vcArray: [UIViewController] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let catVC = CategoryViewController()
        self.viewControllers.append(catVC)
        vcArray.append(catVC)
    }
}


