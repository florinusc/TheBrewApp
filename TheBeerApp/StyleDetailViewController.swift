//
//  StyleDetailViewController.swift
//  TheBeerApp
//
//  Created by Florin Uscatu on 10/23/17.
//  Copyright © 2017 Florin Uscatu. All rights reserved.
//

import UIKit

class StyleDetailViewController: UIViewController {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionView: UITextView!
    
    var styleDescription = ""
    var name = ""
    var srmMin = ""
    var srmMax = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createBackground()
        
        nameLabel.text = name
        descriptionView.text = styleDescription
    }

    @IBAction func exitBttn(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func createBackground() {
        
        if let srmMinInt = Int(srmMin), let srmMaxInt = Int(srmMax) {
            if srmMinInt < 41 && srmMaxInt < 41 {
                let srmMinColor = UIColor(hex: beerColors[srmMinInt - 1] ).cgColor
                let srmMaxColor = UIColor(hex: beerColors[srmMaxInt - 1] ).cgColor
                
                let gradientLayer = CAGradientLayer()
                gradientLayer.colors = [ srmMinColor, srmMaxColor ]
                gradientLayer.locations = [ 0.0, 1.0]
                gradientLayer.frame = self.view.bounds
                
                self.view.layer.insertSublayer(gradientLayer, at: 0)
            } else {
                self.view.backgroundColor = UIColor(hex: beerColors[5] )
                print("srm min is: \(srmMinInt), srm max is: \(srmMaxInt)")
            }
        }
    }
    
}
