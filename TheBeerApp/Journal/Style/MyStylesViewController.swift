//
//  MyStylesViewController.swift
//  TheBeerApp
//
//  Created by Florin Uscatu on 10/25/17.
//  Copyright © 2017 Florin Uscatu. All rights reserved.
//

import UIKit
import CoreData
import DeckTransition

protocol NewStyleDelegate {
    func reloadCollection()
}

class MyStylesViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    fileprivate let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    fileprivate let itemsPerRow: CGFloat = 1
    
    var styles: [NSManagedObject] = []

    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        fetchData()
    }
    
    /** Fetching data from core data */
    func fetchData() {
        print("fetching data")
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "MyStyle")
        
        do {
            styles = try managedContext.fetch(fetchRequest)
            DispatchQueue.main.async {
                self.styles.sort { ($0.value(forKey: "timeAndDate") as! Date) > ($1.value(forKey: "timeAndDate") as! Date) }
                self.collectionView.reloadData()
            }
        } catch let err {
            print(err.localizedDescription)
        }
    }
    
    //Collection view data source
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return styles.count + 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "addStyleCell", for: indexPath)
            cell.layer.cornerRadius = 8.0
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "journalCell", for: indexPath) as! JournalCell
            cell.layer.cornerRadius = 8.0
            cell.nameLabel.text = styles[indexPath.row - 1].value(forKey: "name") as? String
            cell.ratingLabel.text = styles[indexPath.row - 1].value(forKey: "rating") as? String
            cell.notesLabel.text = styles[indexPath.row - 1].value(forKey: "note") as? String
            
            cell.deleteBttn.tag = indexPath.row - 1
            
            return cell
        }
    }
    
    //Transition to new style VC
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            //Set the delegate for the new Style VC entry
            let newStyleVC = storyboard?.instantiateViewController(withIdentifier: "NewStyleEntry") as! NewStyleEntry
            newStyleVC.newStyleDelegate = self
            
            //Setting the transition style to deck
            let transitionDelegate = DeckTransitioningDelegate()
            newStyleVC.transitioningDelegate = transitionDelegate
            newStyleVC.modalPresentationStyle = .custom
            
            //Presenting the new entry VC
            present(newStyleVC, animated: true, completion: nil)
        }
    }
    
    
    //Deleting an entry
    @IBAction func deleteStyle(_ sender: UIButton) {
        print("deleting style: \(String(describing: styles[sender.tag].value(forKey: "name")))")
        
        let uuid = styles[sender.tag].value(forKey: "uuid") as! String
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "MyStyle")
        
        let result = try? managedContext.fetch(fetchRequest)
        
        for object in result! {
            if object.value(forKey: "uuid") as! String == uuid {
                managedContext.delete(object)
            }
        }
        
        do {
            try managedContext.save()
            print("delete was successful")
            DispatchQueue.main.async {
                self.fetchData()
            }
        } catch let err {
            print(err.localizedDescription)
        }
    }
    
}

extension MyStylesViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        if indexPath.row == 0 {
            return CGSize(width: widthPerItem, height: 50)
        } else {
            return CGSize(width: widthPerItem, height: 120)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    
}

extension MyStylesViewController: NewStyleDelegate {
    func reloadCollection() {
        print("called the delegate function")
        self.fetchData()
    }
}
