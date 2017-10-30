//
//  NewPairingEntry.swift
//  TheBeerApp
//
//  Created by Florin Uscatu on 10/26/17.
//  Copyright © 2017 Florin Uscatu. All rights reserved.
//

import UIKit
import Eureka
import CoreData


class NewPairingEntry: FormViewController {

    var newPairingDelegate: NewPairingDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //customize view
        self.tableView.backgroundColor = UIColor(hex: backgroundColor)
        
        setupForm()
    }
    
    func setupForm() {
        form +++ Section("Food Pairing")
            
            <<< TextRow("BeerRow") {
                $0.placeholder = "Beer"
            }
            
            <<< TextRow("FoodRow") {
                $0.placeholder = "Food"
            }
            
            <<< TextRow("NotesRow") {
                $0.placeholder = "Notes"
            }
            
            +++ Section("Rating") { section in
                
                var footerView = HeaderFooterView<UIView>(.class)
                footerView.height = {100}
                footerView.onSetupView = {view,_ in
                    
                    let saveButton = UIButton(frame: CGRect(x: 10, y: 30, width: self.view.bounds.width - 20, height: 50))
                    saveButton.setTitle("Save", for: .normal)
                    saveButton.backgroundColor = UIColor(hex: mainColor)
                    saveButton.layer.cornerRadius = 8.0
                    saveButton.addTarget(self, action: #selector(NewPairingEntry.savePairing), for: .touchUpInside)
                    view.addSubview(saveButton)
                    
                }
                section.footer = footerView
                
            }
            
            <<< PickerInputRow<String>("RatingRow") {
                $0.title = "Rating"
                $0.value = "⭐"
                $0.options = ["⭐","⭐⭐","⭐⭐⭐","⭐⭐⭐⭐","⭐⭐⭐⭐⭐"]
                }.cellSetup { cell, row in
                    cell.tintColor = UIColor.black
        }
        
        
        self.tableView.isScrollEnabled = false
    }
    
    @objc func savePairing() {
        guard let beerRow = form.rowBy(tag: "BeerRow") else {return}
        let beer = beerRow.baseValue as? String
        
        guard let foodRow = form.rowBy(tag: "FoodRow") else {return}
        let food = foodRow.baseValue as? String
        
        guard let notesRow = form.rowBy(tag: "NotesRow") else {return}
        let note = notesRow.baseValue as? String
        
        guard let ratingRow = form.rowBy(tag: "RatingRow") else {return}
        let rating = ratingRow.baseValue as? String
        
        if beer != nil && food != nil && rating != nil {
            
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
            let managedContext = appDelegate.persistentContainer.viewContext
            let entity = NSEntityDescription.entity(forEntityName: "MyPairing", in: managedContext)!
            let myPairing = NSManagedObject(entity: entity, insertInto: managedContext)
            
            if beer != nil { myPairing.setValue(beer, forKey: "beer") }
            
            if food != nil { myPairing.setValue(food, forKey: "food") }
            
            if rating != nil { myPairing.setValue(rating, forKey: "rating") }
            
            if note != nil { myPairing.setValue(note, forKey: "note") }
            
            let uuid = UUID().uuidString
            
            myPairing.setValue(Date(), forKey: "timeAndDate")
            myPairing.setValue(uuid, forKey: "uuid")
            
            do {
                try managedContext.save()
                print("saving entry")
                
                newPairingDelegate?.reloadCollection()
                
                dismiss(animated: true, completion: nil)
            } catch let err {
                print(err.localizedDescription)
            }
        }

    }

}
