//
//  StyleCell.swift
//  TheBeerApp
//
//  Created by Florin Uscatu on 10/22/17.
//  Copyright © 2017 Florin Uscatu. All rights reserved.
//

import UIKit

class StyleCell: UICollectionViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        self.layer.cornerRadius = 8.0
        self.clipsToBounds = true
    }    
}
