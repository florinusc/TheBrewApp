//
//  BeerList.swift
//  TheBeerApp
//
//  Created by Florin Uscatu on 10/24/17.
//  Copyright © 2017 Florin Uscatu. All rights reserved.
//

import UIKit

class BeerList: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var navBarTitle: UINavigationItem!
    
    var styleId = Int()
    var styleName = String()
    var beerArr: [BeerData] = []
    var numberOfPages = 1
    var currentPage = 1
    
    @IBAction func backBttn(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToBeerProfile" {
            let dest = segue.destination as! BeerProfile
            let selectedRow = tableView.indexPathForSelectedRow
            dest.beerData = beerArr[(selectedRow?.row)!]
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("styleId is: \(styleId)")

        
        navBarTitle.title = styleName
        
        requestData(page: currentPage)
    }
    
    func requestData(page: Int) {
        
        DispatchQueue.global().async {
            let urlString = "http://api.brewerydb.com/v2/beers?styleId=\(self.styleId)&p=\(page)&key=1da922b0d817607f683dc6e2cb1612dc"
            let url = URL(string: urlString)
            
            let task = URLSession.shared.dataTask(with: url!) {
                (data, response, error) -> Void in
                
                if error == nil {
                    do {
                        
                        let tempArr = try JSONDecoder().decode(BeerResponse.self, from: data!).data
                        
                        self.beerArr.append(contentsOf: tempArr)
                        
                        let jsonData = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as! NSDictionary
                        
                        self.numberOfPages = jsonData["numberOfPages"] as! Int
                        self.currentPage = jsonData["currentPage"] as! Int
                        
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                        
                    } catch let err {
                        print(err)
                    }
                } else {
                    print(error?.localizedDescription ?? "")
                }
            }
            
            task.resume()
        }
    }
    
    
    //detect if table view is at the end and add more rows by requesting data from API
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == beerArr.count {
            if currentPage < numberOfPages {
                currentPage += 1
                requestData(page: currentPage)
            }
        }
    }
    
    
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return beerArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = beerArr[indexPath.row].name
        
        return cell
    }


}
