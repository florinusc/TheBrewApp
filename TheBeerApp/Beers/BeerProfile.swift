//
//  BeerProfile.swift
//  TheBeerApp
//
//  Created by Florin Uscatu on 10/25/17.
//  Copyright © 2017 Florin Uscatu. All rights reserved.
//

import UIKit
import DeckTransition

class BeerProfile: UITableViewController {

    @IBOutlet weak var headerImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var organicLabel: UILabel!
    @IBOutlet weak var abvLabel: UILabel!
    @IBOutlet weak var styleNameLabel: UILabel!
    @IBOutlet weak var styleDescription: UITextView!
    
    var beerData: BeerData?
    
    private let kTableHeaderHeight: CGFloat = 400.0
    var headerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        retrieveBeerLabel()
        
        setupProfile()
        
        headerView = tableView.tableHeaderView
        tableView.tableHeaderView = nil
        
        tableView.addSubview(headerView)
        
        tableView.contentInset = UIEdgeInsets(top: kTableHeaderHeight, left: 0, bottom: 0, right: 0)
        tableView.contentOffset = CGPoint(x: 0, y: -kTableHeaderHeight)
        updateHeaderView()
    }
    
    func updateHeaderView() {
        var headerRect = CGRect(x: 0, y: -kTableHeaderHeight, width: tableView.bounds.width, height: kTableHeaderHeight)
        if tableView.contentOffset.y < -kTableHeaderHeight {
            headerRect.origin.y = tableView.contentOffset.y
            headerRect.size.height = -tableView.contentOffset.y
        }
        
        headerView.frame = headerRect
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateHeaderView()
    }
    
    func retrieveBeerLabel() {
        if beerData?.labels != nil {
            if let urlString = beerData?.labels?.large {
                guard let url = URL(string: urlString) else {return}
                do {
                    let imageData = try Data(contentsOf: url)
                    let image = UIImage(data: imageData)
                    headerImage.image = image
                } catch let err {
                    print(err.localizedDescription)
                }
            }
            
        }
    }
    
    func setupProfile() {
        nameLabel.text = beerData?.name
        switch beerData?.isOrganic {
        case "Y"?:
            organicLabel.text = "organic"
        case "N"?:
            organicLabel.text = "not organic"
        default:
            organicLabel.text = ""
        }
        if beerData?.abv != nil {
            abvLabel.text = "\(String(describing: beerData!.abv!))%"
        } else {
            abvLabel.text = ""
        }
        styleNameLabel.text = "Style: " + (beerData?.style?.name)!
        styleDescription.text = beerData?.style?.description
    }
    
    
    @IBAction func addToJournal(_ sender: UIButton) {
        //Set the delegate for the new Style VC entry
        let newBrandVC = storyboard?.instantiateViewController(withIdentifier: "NewBrandEntry") as! NewBrandEntry
        
        newBrandVC.brandName = beerData?.name
        
        //Setting the transition style to deck
        let transitionDelegate = DeckTransitioningDelegate()
        newBrandVC.transitioningDelegate = transitionDelegate
        newBrandVC.modalPresentationStyle = .custom
        
        //Presenting the new entry VC
        present(newBrandVC, animated: true, completion: nil)
    }
    
}
