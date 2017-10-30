//
//  ViewController.swift
//  TheBeerApp
//
//  Created by Florin Uscatu on 10/22/17.
//  Copyright © 2017 Florin Uscatu. All rights reserved.
//

import UIKit

class StylesViewController: UICollectionViewController, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating {
    
    @IBOutlet var loadingView: UIView!
    
    fileprivate let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    fileprivate let itemsPerRow: CGFloat = 1
    
    var styleArray: [Style] = []
    var filteredArray: [Style] = []
    
    var searchActive: Bool = false
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        //set the status bar color
        UIApplication.shared.statusBarView?.backgroundColor = UIColor(hex: mainColor)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setting the big title
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.title = "Styles"
        UINavigationBar.appearance().largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor(hex: textColor)]
        
        //customizing the nav bar
        navigationController?.navigationBar.barTintColor = UIColor(hex: mainColor)
        navigationController?.navigationBar.isTranslucent = false
        
        //add the loading view before the data gets to populate the collectionView
        loadingView.frame = self.view.frame
        self.view.addSubview(loadingView)
        
        createSearchBar()
        requestData()
    }
    
    func createSearchBar() {
        
        //Search controller
        self.searchController.searchResultsUpdater = self
        self.searchController.delegate = self
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.obscuresBackgroundDuringPresentation = false
        self.searchController.dimsBackgroundDuringPresentation = false
        
        
        //Search bar
        self.searchController.searchBar.delegate = self
        let bgImage = UIImage(named: "white")
        self.searchController.searchBar.setSearchFieldBackgroundImage(bgImage, for: .normal)
        self.searchController.searchBar.tintColor = UIColor(hex: mainColor)
        
        let textField = self.searchController.searchBar.value(forKey: "searchField") as? UITextField
        textField?.textColor = .white
        textField?.attributedPlaceholder = NSAttributedString(string: "  Search for styles...", attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
        
        
        //setting the color and size of the text of the cancel button for the search bar
        let attributes = [
            NSAttributedStringKey.foregroundColor : UIColor(hex: textColor),
            NSAttributedStringKey.font : UIFont.systemFont(ofSize: 16)
        ]

        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes(attributes, for: .normal)

        self.searchController.searchBar.becomeFirstResponder()

        self.navigationItem.searchController = searchController
        
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
                        self.loadingView.removeFromSuperview()
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
                    dest.styleId = filteredArray[selectedRow].id
                    
                    if let srmMax = filteredArray[selectedRow].srmMax, let srmMin = filteredArray[selectedRow].srmMin {
                        dest.srmMin = srmMin
                        dest.srmMax = srmMax
                    }
                    
                }
                
            } else {
            
                if let selectedRow = collectionView?.indexPathsForSelectedItems![0].row {
                    dest.name = styleArray[selectedRow].name
                    dest.styleDescription = styleArray[selectedRow].description!
                    dest.styleId = styleArray[selectedRow].id
                    
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


