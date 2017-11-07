//
//  LaunchViewController.swift
//  TheBeerApp
//
//  Created by Florin Uscatu on 10/30/17.
//  Copyright © 2017 Florin Uscatu. All rights reserved.
//

import UIKit

class LaunchViewController: UIViewController {
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        performSegue(withIdentifier: "introSegue", sender: self)
    }

}
