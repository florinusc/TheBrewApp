//
//  NewStyleEntry.swift
//  TheBeerApp
//
//  Created by Florin Uscatu on 10/25/17.
//  Copyright © 2017 Florin Uscatu. All rights reserved.
//

import UIKit
import Eureka
import CoreData

class NewStyleEntry: FormViewController {
    
    var styleArray: [Style] = []
    var nameArr: [String] = []
    
    var style: String?
    
    var newStyleDelegate: NewStyleDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //customize view
        self.tableView.backgroundColor = UIColor(hex: backgroundColor)
        
        requestData()
    }
    
    func requestData() {
        let urlString = "http://api.brewerydb.com/v2/styles?&key=1da922b0d817607f683dc6e2cb1612dc"
        guard let url = URL(string: urlString) else {return}
        
        let request = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) -> Void in
            
            if error == nil {
                
                do {
                    self.styleArray = try JSONDecoder().decode(Response.self, from: data!).data
                    
                    DispatchQueue.main.async {
                        self.styleArray.sort {$0.name < $1.name}
                        self.nameArr = self.styleArray.map { $0.name }
                        self.setupForm()
                    }
                    
                } catch let err {
                    print(err)
                }
                
            }
        }
        
        task.resume()
    }
    
    func setupForm() {
        form +++ Section("Style")
            
            <<< PickerInputRow<String>("StyleRow") {
                $0.title = "Style"
                $0.options = nameArr
                if style != nil {
                    $0.value = style
                }
            }.cellSetup { cell, row in
                cell.tintColor = UIColor.black
            }
        
            +++ Section("Rate")
            <<< PickerInputRow<String>("RatingRow") {
                $0.title = "Rating"
                $0.value = "⭐"
                $0.options = ["⭐","⭐⭐","⭐⭐⭐","⭐⭐⭐⭐","⭐⭐⭐⭐⭐"]
                }.cellSetup { cell, row in
                    cell.tintColor = UIColor.black
            }
        
            +++ Section("Note") { section in
                
                var footerView = HeaderFooterView<UIView>(.class)
                footerView.height = {100}
                footerView.onSetupView = {view,_ in
                    
                    let saveButton = UIButton(frame: CGRect(x: 10, y: 30, width: self.view.bounds.width - 20, height: 50))
                    saveButton.setTitle("Save", for: .normal)
                    saveButton.backgroundColor = UIColor(hex: mainColor)
                    saveButton.layer.cornerRadius = 8.0
                    saveButton.addTarget(self, action: #selector(NewStyleEntry.saveStyle), for: .touchUpInside)
                    view.addSubview(saveButton)
                    
                }
                section.footer = footerView
                
            }
            <<< TextRow("NoteRow") {
                $0.placeholder = "Notes"
            }
        
        self.tableView.isScrollEnabled = false
        
    }
    
    @objc func saveStyle() {
        
        guard let styleRow = form.rowBy(tag: "StyleRow") else {return}
        let style = styleRow.baseValue as? String
        
        guard let ratingRow = form.rowBy(tag: "RatingRow") else {return}
        let rating = ratingRow.baseValue as? String

        guard let noteRow = form.rowBy(tag: "NoteRow") else {return}
        let note = noteRow.baseValue as? String
        if style != nil && rating != nil {
            
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        
            let managedContext = appDelegate.persistentContainer.viewContext
            let entity = NSEntityDescription.entity(forEntityName: "MyStyle", in: managedContext)!
            let myStyle = NSManagedObject(entity: entity, insertInto: managedContext)
            
            if style != nil { myStyle.setValue(style, forKey: "name") }
            if rating != nil { myStyle.setValue(rating, forKey: "rating") }
            if note != nil { myStyle.setValue(note, forKey: "note") }
            
            let uuid = UUID().uuidString
            
            myStyle.setValue(Date(), forKey: "timeAndDate")
            myStyle.setValue(uuid, forKey: "uuid")
        
            do {
                try managedContext.save()
                print("saving entry")
                
                newStyleDelegate?.reloadCollection()
                
                dismiss(animated: true, completion: nil)
                
            } catch let err {
                print(err.localizedDescription)
            }
        }
        
    }

}
