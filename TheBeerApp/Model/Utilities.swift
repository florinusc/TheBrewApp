//
//  Utilities.swift
//  TheBeerApp
//
//  Created by Florin Uscatu on 10/22/17.
//  Copyright © 2017 Florin Uscatu. All rights reserved.
//

import UIKit
import DeviceKit


let beerColors: [String] = ["FFE699", "FFD878", "FFCA5A", "FFBF42", "FBB123", "F8A600", "F39C00", "EA8F00", "E58500", "DE7C00", "D77200", "CF6900", "CB6200", "C35900", "BB5100", "B54C00", "B04500", "A63E00", "A13700", "9B3200", "952D00", "8E2900", "882300", "821E00", "7B1A00", "771900", "701400", "6A0E00", "660D00", "5E0B00", "5A0A02", "600903", "520907", "4C0505", "470606", "440607", "3F0708", "3B0607", "3A070B", "36080A"]

extension UIColor {
    convenience init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.scanLocation = 0
        
        var rgbValue: UInt64 = 0
        
        scanner.scanHexInt64(&rgbValue)
        
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        
        self.init(
            red: CGFloat(r) / 0xff,
            green: CGFloat(g) / 0xff,
            blue: CGFloat(b) / 0xff, alpha: 1
        )
    }
}

let mainColor = "F1C40F"
let secondaryColor = "bea231"
let textColor = "2B2B2B"
let backgroundColor = "F7F7F7"

extension UISearchBar {
    
    var textColor:UIColor? {
        get {
            if let textField = self.value(forKey: "searchField") as?
                UITextField  {
                return textField.textColor
            } else {
                return nil
            }
        }
        
        set (newValue) {
            if let textField = self.value(forKey: "searchField") as?
                UITextField  {
                textField.textColor = newValue
            }
        }
    }
}

extension UIApplication {
    var statusBarView: UIView? {
        return value(forKey: "statusBar") as? UIView
    }
}

extension UIView {
    
    func constrainToEdges(_ subview: UIView) {
        
        subview.translatesAutoresizingMaskIntoConstraints = false
        
        let device = Device()
        
        var topConstraint = NSLayoutConstraint()
        
        if device == .iPhoneX || device == .simulator(.iPhoneX) {
            topConstraint = NSLayoutConstraint(
                item: subview,
                attribute: .top,
                relatedBy: .equal,
                toItem: self,
                attribute: .top,
                multiplier: 1.0,
                constant: 44)
        } else {
            topConstraint = NSLayoutConstraint(
                item: subview,
                attribute: .top,
                relatedBy: .equal,
                toItem: self,
                attribute: .top,
                multiplier: 1.0,
                constant: 20)
        }
        
        let bottomConstraint = NSLayoutConstraint(
            item: subview,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: self,
            attribute: .bottom,
            multiplier: 1.0,
            constant: 0)
        
        let leadingContraint = NSLayoutConstraint(
            item: subview,
            attribute: .leading,
            relatedBy: .equal,
            toItem: self,
            attribute: .leading,
            multiplier: 1.0,
            constant: 0)
        
        let trailingContraint = NSLayoutConstraint(
            item: subview,
            attribute: .trailing,
            relatedBy: .equal,
            toItem: self,
            attribute: .trailing,
            multiplier: 1.0,
            constant: 0)
        
        addConstraints([
            topConstraint,
            bottomConstraint,
            leadingContraint,
            trailingContraint])
    }
    
}
