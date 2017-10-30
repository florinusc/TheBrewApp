//
//  BeerSearchTable.swift
//  TheBeerApp
//
//  Created by Florin Uscatu on 10/27/17.
//  Copyright © 2017 Florin Uscatu. All rights reserved.
//

import UIKit
import DeckTransition

class BeerSearchTable: UITableViewController {

    public var beerArr: [BeerData] = []

    public var breweryArr: [Brewery] = []

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if breweryArr.isEmpty {
            return beerArr.count
        } else {
            return breweryArr.count
        }
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if breweryArr.isEmpty {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.text = beerArr[indexPath.row].name
            cell.detailTextLabel?.text = beerArr[indexPath.row].style?.name
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.textLabel?.text = breweryArr[indexPath.row].name
            cell.detailTextLabel?.text = breweryArr[indexPath.row].established
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if breweryArr.isEmpty {
            //Set the delegate for the new Style VC entry
            let beerVC = storyboard?.instantiateViewController(withIdentifier: "BeerProfile") as! BeerProfile
            beerVC.beerData = beerArr[indexPath.row]
            
            //Setting the transition style to deck
            let transitionDelegate = DeckTransitioningDelegate()
            beerVC.transitioningDelegate = transitionDelegate
            beerVC.modalPresentationStyle = .custom

            //Presenting the new entry VC
            present(beerVC, animated: true, completion: nil)
        } else {
            //BreweryViewController
            let breweryVC = storyboard?.instantiateViewController(withIdentifier: "BreweryViewController") as! BreweryViewController
            //breweryVC.brewery?.brewery = breweryArr[indexPath.row]
            
            breweryVC.brewery = BreweryData(id: "", name: "", streetAddress: nil, locality: nil, latitude: nil, longitude: nil, isPrimary: nil, inPlanning: nil, isClosed: nil, openToPublic: nil, locationType: nil, locationTypeDisplay: nil, countryCode: nil, status: nil, statusDisplay: nil, breweryId: nil, brewery: breweryArr[indexPath.row])
            
            //Setting the transition style to deck
            let transitionDelegate = DeckTransitioningDelegate()
            breweryVC.transitioningDelegate = transitionDelegate
            breweryVC.modalPresentationStyle = .custom
            
            //Presenting the new entry VC
            present(breweryVC, animated: true, completion: nil)
        }
    }

}
