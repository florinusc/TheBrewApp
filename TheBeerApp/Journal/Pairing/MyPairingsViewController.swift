//
//  MyPairingsViewController.swift
//  TheBeerApp
//
//  Created by Florin Uscatu on 10/25/17.
//  Copyright © 2017 Florin Uscatu. All rights reserved.
//

import UIKit
import CoreData
import DeckTransition

protocol NewPairingDelegate {
    func reloadCollection()
}

class MyPairingsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    fileprivate let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    fileprivate let itemsPerRow: CGFloat = 1
    
    var pairings: [NSManagedObject] = []
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        fetchData()
    }
    
    func fetchData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "MyPairing")
        
        do {
            pairings = try managedContext.fetch(fetchRequest)
            DispatchQueue.main.async {
                self.pairings.sort { ($0.value(forKey: "timeAndDate") as! Date) > ($1.value(forKey: "timeAndDate") as! Date) }
                self.collectionView.reloadData()
            }
        } catch let err {
            print(err.localizedDescription)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (pairings.count + 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "addPairingCell", for: indexPath)
            cell.layer.cornerRadius = 8.0
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "journalCell", for: indexPath) as! JournalCell
            cell.layer.cornerRadius = 8.0
            cell.nameLabel.text = (pairings[indexPath.row - 1].value(forKey: "beer") as? String)!
            
            if let food: String = pairings[indexPath.row - 1].value(forKey: "food") as? String {
                cell.nameLabel.text! += (" | " + food)
            }
            
            cell.ratingLabel.text = pairings[indexPath.row - 1].value(forKey: "rating") as? String
            cell.notesLabel.text = pairings[indexPath.row - 1].value(forKey: "note") as? String
            
            cell.deleteBttn.tag =  (indexPath.row - 1)
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            
            //Set the delegate for the new Style VC entry
            let newPairingVC = storyboard?.instantiateViewController(withIdentifier: "NewPairingEntry") as! NewPairingEntry
            newPairingVC.newPairingDelegate = self
            
            //Setting the transition style to deck
            let transitionDelegate = DeckTransitioningDelegate()
            newPairingVC.transitioningDelegate = transitionDelegate
            newPairingVC.modalPresentationStyle = .custom
            
            //Presenting the new entry VC
            present(newPairingVC, animated: true, completion: nil)
            
        }
    }
    
    
    @IBAction func deleteBttn(_ sender: UIButton) {
        print("deleting pairing: \(String(describing: pairings[sender.tag].value(forKey: "uuid")))")
        
        let uuid = pairings[sender.tag].value(forKey: "uuid") as! String
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "MyPairing")
        
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

extension MyPairingsViewController: UICollectionViewDelegateFlowLayout {
    
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

extension MyPairingsViewController: NewPairingDelegate {
    func reloadCollection() {
        print("called the delegate function")
        self.fetchData()
    }
}
