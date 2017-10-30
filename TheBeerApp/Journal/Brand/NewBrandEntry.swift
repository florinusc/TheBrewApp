//
//  NewBrandEntry.swift
//  TheBeerApp
//
//  Created by Florin Uscatu on 10/26/17.
//  Copyright © 2017 Florin Uscatu. All rights reserved.
//

import UIKit
import CoreData
import Eureka

class NewBrandEntry: FormViewController {

    var newBrandDelegate: NewBrandDelegate? = nil
    
    var brandName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //customize view
        self.tableView.backgroundColor = UIColor(hex: backgroundColor)
        
        setupForm()
    }

    func setupForm() {
        form +++ Section("Brand")
        
            <<< TextRow("BrandRow") {
                $0.placeholder = "Brand name"
                if brandName != nil {
                    $0.value = brandName
                }
            }
        
            <<< TextRow("BreweryRow") {
                $0.placeholder = "Brewery name"
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
                    saveButton.addTarget(self, action: #selector(NewBrandEntry.saveBrand), for: .touchUpInside)
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
    
    @objc func saveBrand() {
        guard let brandRow = form.rowBy(tag: "BrandRow") else {return}
        let brand = brandRow.baseValue as? String
        
        guard let breweryRow = form.rowBy(tag: "BreweryRow") else {return}
        let brewery = breweryRow.baseValue as? String
        
        guard let notesRow = form.rowBy(tag: "NotesRow") else {return}
        let note = notesRow.baseValue as? String
        
        guard let ratingRow = form.rowBy(tag: "RatingRow") else {return}
        let rating = ratingRow.baseValue as? String
        
        if brand != nil && rating != nil {
            
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
            let managedContext = appDelegate.persistentContainer.viewContext
            let entity = NSEntityDescription.entity(forEntityName: "MyBrand", in: managedContext)!
            let myBrand = NSManagedObject(entity: entity, insertInto: managedContext)
            
            if brand != nil { myBrand.setValue(brand, forKey: "name") }
            
            if brewery != nil { myBrand.setValue(brewery, forKey: "brewery") }
            
            if rating != nil { myBrand.setValue(rating, forKey: "rating") }
            
            if note != nil { myBrand.setValue(note, forKey: "note") }
            
            let uuid = UUID().uuidString
            
            myBrand.setValue(Date(), forKey: "timeAndDate")
            myBrand.setValue(uuid, forKey: "uuid")
            
            do {
                try managedContext.save()
                print("saving entry")
                
                newBrandDelegate?.reloadCollection()
                
                dismiss(animated: true, completion: nil)
            } catch let err {
                print(err.localizedDescription)
            }
        }
    }
    
}
