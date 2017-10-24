//
//  BreweryViewController.swift
//  TheBeerApp
//
//  Created by Florin Uscatu on 10/24/17.
//  Copyright © 2017 Florin Uscatu. All rights reserved.
//

import UIKit
import MapKit

class BreweryViewController: UITableViewController {
    
    @IBOutlet weak var beerHeader: UIImageView!
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var estLabel: UILabel!
    @IBOutlet weak var locationTypeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var websiteBttn: UIButton!
    
    
    private let kTableHeaderHeight: CGFloat = 200.0
    var headerView: UIView!
    
    var brewery: BreweryData?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        
        retrieveBreweryImages()
        
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
    
    func retrieveBreweryImages() {
        if let images = brewery?.brewery.images {
            do {
                let largeImageURL = URL(string: images.large!)
                let largeImageData = try Data(contentsOf: largeImageURL!)
                let largeImage = UIImage(data: largeImageData)
                
                let iconImageURL = URL(string: images.icon!)
                let iconImageData = try Data(contentsOf: iconImageURL!)
                let iconImage = UIImage(data: iconImageData)
                
                beerHeader.image = largeImage
                logoImage.image = iconImage

            } catch let err {
                print(err.localizedDescription)
            }
        }

        DispatchQueue.main.async {
            self.tableView.reloadData()
            print("reloading the table")
        }
    }
    
    func setupView() {
        nameLabel.text = brewery?.name
        if let est = (brewery?.brewery.established) {
            estLabel.text = "est. " + est
        }
        locationTypeLabel.text = brewery?.locationTypeDisplay
        descriptionTextView.text = brewery?.brewery.description
        websiteBttn.setTitle(brewery?.brewery.website, for: .normal)
        addressLabel.text = brewery?.streetAddress
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateHeaderView()
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 {
            print("go to maps")
            
            if brewery?.latitude != nil && brewery?.longitude != nil {
            
                let regionDistance:CLLocationDistance = 10000
                let coordinates = CLLocationCoordinate2DMake((brewery?.latitude)!, (brewery?.longitude)!)
                let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
                
                let options = [
                    MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
                    MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
                ]
                
                let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
                let mapItem = MKMapItem(placemark: placemark)
                mapItem.name = self.brewery?.name
                mapItem.openInMaps(launchOptions: options)
            
            }
        }
    }
    
    @IBAction func websiteBttn(_ sender: UIButton) {
    
        if brewery?.brewery.website != nil {
            if let breweryURL = URL(string: (brewery?.brewery.website)!) {
                UIApplication.shared.openURL(breweryURL)
            }
        }
    }
    
    
    
    

}
