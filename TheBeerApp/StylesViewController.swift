//
//  ViewController.swift
//  TheBeerApp
//
//  Created by Florin Uscatu on 10/22/17.
//  Copyright © 2017 Florin Uscatu. All rights reserved.
//

import UIKit

class StylesViewController: UICollectionViewController, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating {

    
    fileprivate let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    fileprivate let itemsPerRow: CGFloat = 1
    
    var styleArray: [Style] = []
    var filteredArray: [Style] = []
    
    var searchActive: Bool = false
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createSearchBar()
        requestData()
    }
    
    func createSearchBar() {

        self.searchController.searchResultsUpdater = self
        self.searchController.delegate = self
        self.searchController.searchBar.delegate = self
        
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.obscuresBackgroundDuringPresentation = false
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.searchBar.placeholder = "Search for styles here"
        
        self.searchController.searchBar.becomeFirstResponder()
        
        navigationController?.navigationItem.titleView = self.searchController.searchBar
        
        self.navigationItem.titleView = self.searchController.searchBar
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
        self.dismiss(animated: true, completion: nil)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchString = searchController.searchBar.text
        
        if searchString != "" {
            filteredArray = styleArray.filter({ (style: Style) -> Bool in
                let name: NSString = style.name as NSString
                
                return (name.range(of: searchString!, options: NSString.CompareOptions.caseInsensitive).location) != NSNotFound
            })
        } else {
            filteredArray = styleArray
        }
        
        collectionView?.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true
        collectionView?.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
        collectionView?.reloadData()
    }
    
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        if !searchActive {
            searchActive = true
            collectionView?.reloadData()
        }
        
        searchController.searchBar.resignFirstResponder()
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
                    
                    let tempArray = self.styleArray.filter({ (acceptedStyle: Style) -> Bool in
                        if acceptedStyle.description != nil && acceptedStyle.srmMin != nil && acceptedStyle.srmMax != nil {
                            return true
                        } else {
                            return false
                        }
                    })
                    
                    self.styleArray = tempArray
                    
                    self.styleArray.sort(by: { (sort1: Style, sort2: Style) -> Bool in
                        var boolo = Bool()
                        
                        if sort1.srmMin != nil && sort2.srmMin != nil {
                           boolo = Int(sort1.srmMin!)! > Int(sort2.srmMin!)!
                        } else {
                            boolo =  false
                        }
                        
                        return boolo
                    })
                    
                    DispatchQueue.main.async {

                        self.collectionView?.reloadData()
                    }
                    
                } catch let err {
                    print(err)
                }
                
            }
        }
        
        task.resume()
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if searchActive {
            return filteredArray.count
        } else {
            return styleArray.count
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if searchActive {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StyleCell", for: indexPath) as! StyleCell
            
            cell.nameLabel.text = filteredArray[indexPath.row].name
            
            let srmMin = filteredArray[indexPath.row].srmMin
            
            if srmMin != nil {
                if let srmMinInt = Int(srmMin!) {
                    if srmMinInt <= 40 {
                        
                        let color = UIColor(hex: beerColors[srmMinInt - 1])
                        cell.backgroundColor = color
                        
                    } else {
                        print("srm is" + srmMin!)
                    }
                }
            } else {
                print("found a nil srm " + filteredArray[indexPath.row].name )
            }
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StyleCell", for: indexPath) as! StyleCell
            
            cell.nameLabel.text = styleArray[indexPath.row].name
            
            let srmMin = styleArray[indexPath.row].srmMin
            
            if srmMin != nil {
                if let srmMinInt = Int(srmMin!) {
                    if srmMinInt <= 40 {
                        
                        let color = UIColor(hex: beerColors[srmMinInt - 1])
                        cell.backgroundColor = color
                        
                    } else {
                        print("srm is" + srmMin!)
                    }
                }
            } else {
                print("found a nil srm " + styleArray[indexPath.row].name )
            }
            
            return cell
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToStyle", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToStyle" {
            let dest = segue.destination as! StyleDetailViewController
            
            if searchActive {
                
                if let selectedRow = collectionView?.indexPathsForSelectedItems![0].row {
                    dest.name = filteredArray[selectedRow].name
                    dest.styleDescription = filteredArray[selectedRow].description!
                    
                    if let srmMax = filteredArray[selectedRow].srmMax, let srmMin = filteredArray[selectedRow].srmMin {
                        dest.srmMin = srmMin
                        dest.srmMax = srmMax
                    }
                    
                }
                
            } else {
            
                if let selectedRow = collectionView?.indexPathsForSelectedItems![0].row {
                    dest.name = styleArray[selectedRow].name
                    dest.styleDescription = styleArray[selectedRow].description!
                    
                    if let srmMax = styleArray[selectedRow].srmMax, let srmMin = styleArray[selectedRow].srmMin {
                        dest.srmMin = srmMin
                        dest.srmMax = srmMax
                    }
                    
                }
            
            }
            
        }
    }

    
}

extension StylesViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        return CGSize(width: widthPerItem, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
    
}


