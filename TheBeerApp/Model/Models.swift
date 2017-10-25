//
//  Models.swift
//  TheBeerApp
//
//  Created by Florin Uscatu on 10/24/17.
//  Copyright © 2017 Florin Uscatu. All rights reserved.
//

import UIKit
import MapKit

struct Response: Decodable {
    var message: String
    var data: [Style]
    var status: String
}

struct Style: Decodable {
    var id: Int
    var categoryId: Int
    var category: Category
    var name: String
    var shortName: String
    var description: String?
    var ibuMin: String?
    var ibuMax: String?
    var abvMin: String?
    var abvMax: String?
    var srmMin: String?
    var srmMax: String?
    var ogMin: String?
    var fgMin: String?
    var fgMax: String?
}

struct Category: Decodable {
    var id: Int
    var name: String
    var createDate: String
}

struct BreweryResponse: Decodable {
    var currentPage: Int?
    var numberOfPages: Int?
    var totalResults: Int?
    var data: [BreweryData]
    var status: String?
}

struct BreweryData: Decodable {
    var id: String
    var name: String
    var streetAddress: String?
    var locality: String
    var latitude: Double
    var longitude: Double
    var isPrimary: String
    var inPlanning: String
    var isClosed: String
    var openToPublic: String
    var locationType: String
    var locationTypeDisplay: String
    var countryCode: String?
    var status: String
    var statusDisplay: String
    var breweryId: String
    var brewery: Brewery
}

struct Brewery: Decodable {
    var id: String
    var name: String
    var nameShortDisplay: String
    var description: String?
    var website: String?
    var established: String?
    var images: Images?
    var isOrganic: String
    var status: String
    var statusDisplay: String
    var isMassOwned: String
    var brandClassification: String
}

struct Images: Decodable {
    var icon: String?
    var medium: String?
    var large: String?
    var squareMedium: String?
    var squareLarge: String?
}

class BreweryPoint: NSObject, MKAnnotation {
    let title: String?
    let address: String?
    let coordinate: CLLocationCoordinate2D
    let id: String?
    let brewery: BreweryData?
    
    init(title: String, address: String, coordinate: CLLocationCoordinate2D, id: String, brewery: BreweryData) {
        self.title = title
        self.address = address
        self.coordinate = coordinate
        self.id = id
        self.brewery = brewery
        
        super.init()
    }
    
    var subtitle: String? {
        return address
    }
}

struct BeerResponse: Decodable {
    var currentPage: Int
    var data: [BeerData]
    var numberOfPages: Int
    var status: String
    var totalResults: Int
}

struct BeerData: Decodable {
    var abv: String?
    var description: String?
    var labels: BeerLabel?
    var availableId: Int?
    var ibu: String?
    var id: String
    var isOrganic: String
    var name: String
    var nameDisplay: String
    var statusDisplay: String
    var styleId: Int
    var style: Style?
}

struct BeerLabel: Decodable {
    var icon: String
    var large: String
    var medium: String
}

