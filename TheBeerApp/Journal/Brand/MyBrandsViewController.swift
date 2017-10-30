//
//  MyBrandsViewController.swift
//  TheBeerApp
//
//  Created by Florin Uscatu on 10/25/17.
//  Copyright © 2017 Florin Uscatu. All rights reserved.
//

import UIKit
import CoreData
import DeckTransition

protocol NewBrandDelegate {
    func reloadCollection()
}

class MyBrandsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    fileprivate let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    fileprivate let itemsPerRow: CGFloat = 1
    
    var brands: [NSManagedObject] = []
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        fetchData()
    }
    
    func fetchData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "MyBrand")
        
        do {
            brands = try managedContext.fetch(fetchRequest)
            DispatchQueue.main.async {
                self.brands.sort { ($0.value(forKey: "timeAndDate") as! Date) > ($1.value(forKey: "timeAndDate") as! Date) }
                self.collectionView.reloadData()
            }
        } catch let err {
            print(err.localizedDescription)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (brands.count + 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "addBrandCell", for: indexPath)
            cell.layer.cornerRadius = 8.0
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "journalCell", for: indexPath) as! JournalCell
            cell.layer.cornerRadius = 8.0
            cell.nameLabel.text = (brands[indexPath.row - 1].value(forKey: "name") as? String)!
            
            if let brewery: String = brands[indexPath.row - 1].value(forKey: "brewery") as? String {
                cell.nameLabel.text! += (" | " + brewery)
            }
            
            cell.ratingLabel.text = brands[indexPath.row - 1].value(forKey: "rating") as? String
            cell.notesLabel.text = brands[indexPath.row - 1].value(forKey: "note") as? String
            
            cell.deleteBttn.tag =  (indexPath.row - 1)
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            
            //Set the delegate for the new Style VC entry
            let newBrandVC = storyboard?.instantiateViewController(withIdentifier: "NewBrandEntry") as! NewBrandEntry
            newBrandVC.newBrandDelegate = self
            
            //Setting the transition style to deck
            let transitionDelegate = DeckTransitioningDelegate()
            newBrandVC.transitioningDelegate = transitionDelegate
            newBrandVC.modalPresentationStyle = .custom
            
            //Presenting the new entry VC
            present(newBrandVC, animated: true, completion: nil)
            
        }
    }
    
    
    @IBAction func deleteBttn(_ sender: UIButton) {
        print("deleting brand: \(String(describing: brands[sender.tag].value(forKey: "name")))")
        
        let uuid = brands[sender.tag].value(forKey: "uuid") as! String
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "MyBrand")
        
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

extension MyBrandsViewController: UICollectionViewDelegateFlowLayout {
    
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

extension MyBrandsViewController: NewBrandDelegate {
    func reloadCollection() {
        print("called the delegate function")
        self.fetchData()
    }
}
