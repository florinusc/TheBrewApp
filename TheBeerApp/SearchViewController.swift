//
//  SearchViewController.swift
//  TheBeerApp
//
//  Created by Florin Uscatu on 10/27/17.
//  Copyright © 2017 Florin Uscatu. All rights reserved.
//

import UIKit
import BarcodeScanner
import JSSAlertView
import DeckTransition

struct BarcodeResponse: Decodable {
    var code: String
    var status: Int
    var status_verbose: String
    var product: BarcodeProduct?
}

struct BarcodeProduct: Decodable {
    var _keywords: [String]
    var product_name: String?
}

enum SearchType {
    case beer
    case brewery
}

class SearchViewController: UIViewController, UITextFieldDelegate {

    var beerArr: [BeerData] = []
    var breweryArr: [Brewery] = []
    var searchType: SearchType = .beer
    
    override func viewWillAppear(_ animated: Bool) {
        UIApplication.shared.statusBarView?.backgroundColor = UIColor(hex: backgroundColor)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //customize the disclaimer
        disclaimerView.layer.cornerRadius = 8.0
        self.view.addSubview(disclaimerView)
        disclaimerView.isHidden = true
        
        //text field delegate
        nameTxtFld.delegate = self
        
        //customize the buttons
        searchBttnOutlet.layer.cornerRadius = 8.0
        searchByNameBttnOutlet.layer.cornerRadius = 8.0
        
        nameTxtFld.layer.cornerRadius = 8.0
        
    }
    
    @IBAction func segmentControl(_ sender: UISegmentedControl) {
        disclaimerView.isHidden = true
        switch sender.selectedSegmentIndex {
        case 0:
            searchType = .beer
            nameTxtFld.placeholder = "Beer name..."
            searchBttnOutlet.isHidden = false
            disclaimerBttnOutlet.isHidden = false
        case 1:
            searchType = .brewery
            nameTxtFld.placeholder = "Brewery name..."
            searchBttnOutlet.isHidden = true
            disclaimerBttnOutlet.isHidden = true
        default:
            break
        }
        
    }
    
    @IBOutlet weak var searchBttnOutlet: UIButton!
    @IBAction func searchBttn(_ sender: UIButton) {
        disclaimerView.isHidden = true
        let controller = BarcodeScannerController()
        controller.codeDelegate = self
        controller.errorDelegate = self
        controller.dismissalDelegate = self
        
        present(controller, animated: true, completion: nil)
    }
    
    
    @IBOutlet weak var nameTxtFld: UITextField!
    @IBOutlet weak var searchByNameBttnOutlet: UIButton!
    @IBAction func searchByName(_ sender: UIButton) {
        disclaimerView.isHidden = true
        if nameTxtFld.text != "" {
            if searchType == .beer {
                fetchDataFromBeerName(name: nameTxtFld.text!)
            } else {
                print("calling the fetch func from bttn")
                fetchDataFromBreweryName(name: nameTxtFld.text!)
            }
        }
    }
    
    @IBOutlet weak var disclaimerBttnOutlet: UIButton!
    @IBAction func disclaimer(_ sender: UIButton) {
        disclaimerView.frame = CGRect(x: (self.view.bounds.width/2 - disclaimerView.frame.width/2), y: (self.view.bounds.height/2 - disclaimerView.frame.height/2), width: disclaimerView.frame.width, height: disclaimerView.frame.height)
        disclaimerView.isHidden = false
    }
    
    @IBOutlet var disclaimerView: UIView!
    @IBAction func closeDisclaimer(_ sender: UIButton) {
        disclaimerView.isHidden = true
    }
    
    internal func fetchDataFromBreweryName(name: String) {
        let newName = name.replacingOccurrences(of: " ", with: "%20").lowercased()
        let urlString = "http://api.brewerydb.com/v2/breweries?name=\(newName)&key=1da922b0d817607f683dc6e2cb1612dc"
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            print("fetching data")
            let task = URLSession.shared.dataTask(with: request) {
                (data, response, error) -> Void in
                
                if error == nil {
                    do {
                        let brewBeryResp = try JSONDecoder().decode(BrewerySearchResponse.self, from: data!)
                        
                        if let tempArr = brewBeryResp.data {
                            self.breweryArr = tempArr
                            print(self.breweryArr)
                            print("found data")
                            DispatchQueue.main.async {
                                if self.breweryArr.count > 0 {
                                    self.presentListOfResults()
                                }
                            }
                        } else {
                            DispatchQueue.main.async {
                                JSSAlertView().danger(
                                    self,
                                    title: "Error",
                                    text: "No brewery found in database",
                                    buttonText: "Ok"
                                )
                            }
                        } 
                    } catch let err {
                        print(err)
                        DispatchQueue.main.async {
                            JSSAlertView().danger(
                                self,
                                title: "Error",
                                text: "No brewery found in database",
                                buttonText: "Ok"
                            )
                        }
                    }
                } else {
                    print(error?.localizedDescription ?? "error")
                    DispatchQueue.main.async {
                        JSSAlertView().danger(
                            self,
                            title: "Error",
                            text: "No brewery found in database",
                            buttonText: "Ok"
                        )
                    }
                }
            }
            task.resume()
        }
    }
    
    internal func fetchDataFromBeerName(name: String) {
        let newName = name.replacingOccurrences(of: " ", with: "%20").lowercased()
        let urlString = "http://api.brewerydb.com/v2/beers?name=\(newName)&key=1da922b0d817607f683dc6e2cb1612dc"
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            
            let task = URLSession.shared.dataTask(with: request) {
                (data, response, error) -> Void in
                
                if error == nil {
                    do {
                        
                        self.beerArr = try JSONDecoder().decode(BeerResponse.self, from: data!).data
                        
                        print(self.beerArr)
                        DispatchQueue.main.async {
                            if self.beerArr.count > 0 {
                                self.presentListOfResults()
                            }
                        }
                    } catch let err {
                        print(err)
                        DispatchQueue.main.async {
                            JSSAlertView().danger(
                                self,
                                title: "Error",
                                text: "No beer found in database",
                                buttonText: "Ok"
                            )
                        }
                        
                    }
                } else {
                    print(error?.localizedDescription ?? "error")
                    DispatchQueue.main.async {
                        JSSAlertView().danger(
                            self,
                            title: "Error",
                            text: "No beer found in database",
                            buttonText: "Ok"
                        )
                    }
                }
            }
            task.resume()
        }
    }
    
    
    internal func fetchDataFromBarcode(code: String) {
        let urlString = "https://world.openfoodfacts.org/api/v0/product/\(code).json"
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            
            let task = URLSession.shared.dataTask(with: request) {
                (data, response, error) -> Void in
                
                if error == nil {
                    
                    do {
                        let reply = try JSONDecoder().decode(BarcodeResponse.self, from: data!)
                        
                        let beerName = reply.product?.product_name
                        if beerName != nil {
                            self.fetchDataFromBeerName(name: beerName!.lowercased())
                        } else {
                            print("beer name is nil")
                            DispatchQueue.main.async {
                                JSSAlertView().danger(
                                    self,
                                    title: "Error",
                                    text: "No beer found in database",
                                    buttonText: "Ok"
                                )
                            }
                        }
                        
                    } catch let err {
                        print(err.localizedDescription)
                        DispatchQueue.main.async {
                            JSSAlertView().danger(
                                self,
                                title: "Error",
                                text: "No beer found in database",
                                buttonText: "Ok"
                            )
                        }
                    }
                    
                } else {
                    print(error?.localizedDescription ?? "error")
                    DispatchQueue.main.async {
                        JSSAlertView().danger(
                            self,
                            title: "Error",
                            text: "No beer found in database",
                            buttonText: "Ok"
                        )
                    }
                }
                
            }
            task.resume()
        }
    }
    
    func presentListOfResults() {
        if breweryArr.isEmpty {
            let beerSearchTable = storyboard?.instantiateViewController(withIdentifier: "BeerSearchTable") as! BeerSearchTable
            beerSearchTable.beerArr = beerArr
            beerSearchTable.breweryArr = []
            
            let transitionDelegate = DeckTransitioningDelegate()
            beerSearchTable.transitioningDelegate = transitionDelegate
            beerSearchTable.modalPresentationStyle = .custom
            
            present(beerSearchTable, animated: true, completion: nil)
            beerArr.removeAll()
        } else {
            let beerSearchTable = storyboard?.instantiateViewController(withIdentifier: "BeerSearchTable") as! BeerSearchTable
            beerSearchTable.beerArr = []
            beerSearchTable.breweryArr = self.breweryArr
            
            let transitionDelegate = DeckTransitioningDelegate()
            beerSearchTable.transitioningDelegate = transitionDelegate
            beerSearchTable.modalPresentationStyle = .custom
            
            present(beerSearchTable, animated: true, completion: nil)
            breweryArr.removeAll()
        }
    }
    
    //retracts keyboard if user taps anywhere else
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        if nameTxtFld.text != "" {
            if searchType == .beer {
                fetchDataFromBeerName(name: nameTxtFld.text!)
            } else {
                fetchDataFromBreweryName(name: nameTxtFld.text!)
            }
        }
        return false
    }
}

extension SearchViewController: BarcodeScannerCodeDelegate {
    func barcodeScanner(_ controller: BarcodeScannerController, didCaptureCode code: String, type: String) {
        print(code)
        fetchDataFromBarcode(code: code)
        controller.dismiss(animated: true, completion: nil)
    }
}

extension SearchViewController: BarcodeScannerErrorDelegate {
    func barcodeScanner(_ controller: BarcodeScannerController, didReceiveError error: Error) {
        let alert = JSSAlertView().danger(
            self,
            title: "Error",
            text: error.localizedDescription,
            buttonText: "Ok"
        )
        alert.addAction {
            controller.reset()
        }
    }
}

extension SearchViewController: BarcodeScannerDismissalDelegate {
    func barcodeScannerDidDismiss(_ controller: BarcodeScannerController) {
        controller.dismiss(animated: true, completion: nil)
    }
}
