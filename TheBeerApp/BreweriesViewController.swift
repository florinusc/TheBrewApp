//
//  BreweriesViewController.swift
//  TheBeerApp
//
//  Created by Florin Uscatu on 10/23/17.
//  Copyright © 2017 Florin Uscatu. All rights reserved.
//

import UIKit
import MapKit



class BreweriesViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    var breweryArr: [BreweryData] = []
    var locationManager = CLLocationManager()
    
    let homeLocation = CLLocation(latitude: 37.6213, longitude: -122.3790)
    let regionRadius: CLLocationDistance = 3000
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setup delegates
        mapView.delegate = self
        mapView.showsUserLocation = true
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        
        
        //ask for the user's permission to access location while they are using the app
        locationManager.requestWhenInUseAuthorization()
        
        //center the map on the user's location
        if let userLocation = mapView.userLocation.location {
            centerMapOnLocation(location: userLocation)
        }
    }
    
    
    /** Updates the user's location */
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        if let userLocation = mapView.userLocation.location {
            centerMapOnLocation(location: userLocation)
            getCurrentCity(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        }
    }
    
    /** Retrieve the current city from the location */
    func getCurrentCity(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: latitude, longitude: longitude), completionHandler: {
            (placemarks, error) -> Void in
            
            if error == nil {
                if placemarks!.count > 0 {
                    let pm = placemarks![0]
                    
                    if let city = pm.locality {
                        self.requestBreweryData(city: city)
                    }
                }
                else {
                    print("Problem with the data received from geocoder")
                }
            } else {
                print("Reverse geocoder failed with error" + error!.localizedDescription)
            }
        })
    }
    
    
    func requestBreweryData(city: String) {
        let newCity = city.replacingOccurrences(of: " ", with: "%20").lowercased()
        let urlString = "http://api.brewerydb.com/v2/locations?locality=\(newCity)&key=1da922b0d817607f683dc6e2cb1612dc"
        guard let url = URL(string: urlString) else {return}
        
        let request = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            
            if error == nil {
                do {
                    self.breweryArr = try JSONDecoder().decode(BreweryResponse.self, from: data!).data
                    
                    self.addBreweryPoints(breweryArray: self.breweryArr)
                    
                } catch let err {
                    print("json decoding error: \(err)")
                }
            } else {
                print(error?.localizedDescription ?? "")
            }
        }
        task.resume()
    }
    
    var annotationArr: [BreweryPoint] = []
    
    /** Add annotations */
    func addBreweryPoints(breweryArray: [BreweryData]) {
        for brewery in breweryArray {
            
            var address = ""
            
            if brewery.streetAddress != nil {
                address = brewery.streetAddress!
            } else {
                address = ""
            }
            
            let breweryPoint = BreweryPoint(title: brewery.name, address: address, coordinate: CLLocationCoordinate2D(latitude: brewery.latitude, longitude: brewery.longitude), id: brewery.id, brewery: brewery)
            
            annotationArr.append(breweryPoint)
        }
        
        DispatchQueue.main.async {
            self.mapView.addAnnotations(self.annotationArr)
        }
    }
    
    var selectedBrewery: BreweryData?
    
    //add action to detail disclosure of annotations
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let location = view.annotation as! BreweryPoint
        
        print("the selected location is: \(location.title!) with id: \(location.id!)")
        
        selectedBrewery = location.brewery
        
        performSegue(withIdentifier: "goToBrewery", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToBrewery" {
            let dest = segue.destination as! BreweryViewController
                
            dest.brewery = selectedBrewery
            
        }
    }
    
    

}

extension BreweriesViewController {
    
    //customized annotation views
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? BreweryPoint else {return nil}
        
        let identifier = "marker"
        var view: MKAnnotationView
        
        if let dequedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) {
            dequedView.annotation = annotation
            view = dequedView
        } else {
            view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            
            view.canShowCallout = true
            view.image = UIImage(named: "pinpoint")
            view.calloutOffset = CGPoint(x: -5, y: -5)
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            
        }
        
        
        return view
    }
    
}

