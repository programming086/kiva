//
//  KivaTableViewController.swift
//  kiva
//
//  Created by Игорь on 26.12.15.
//  Copyright © 2015 Ihor Malovanyi. All rights reserved.
//

import UIKit

class KivaTableViewController: UITableViewController {

    let kivaLoadURL = "https://api.kivaws.org/v1/loans/newest.json"
    var loans = [Loan]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getLatestLoans()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return loans.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! KivaTableViewCell
        
        // Configure the cell...
        cell.nameLabel?.text = loans[indexPath.row].name
        cell.countryLabel?.text = loans[indexPath.row].country
        cell.useLabel?.text = loans[indexPath.row].use
        cell.amountLabel?.text = "$\(loans[indexPath.row].amount)"
        
        return cell
    }
    
    func getLatestLoans() {
        let request = NSURLRequest(URL: NSURL(string: kivaLoadURL)!)
        let urlSession = NSURLSession.sharedSession()
        let task = urlSession.dataTaskWithRequest(request, completionHandler:  { (data, response, error) -> Void in
            
            if let error = error {
                print(error)
                return
            }
            
            //Parsing
            if let data = data {
                self.loans = self.parseJsonData(data)
                
                NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                    self.tableView.reloadData()
                })
            }
            
        })
        task.resume()
    }
    
    func parseJsonData(data: NSData) -> [Loan] {
        do {
            let jsonResult = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
            
            //Parse JSON Data
            let jsonLoans = jsonResult?["loans"] as! [AnyObject]
            for jsonLoan in jsonLoans {
                let loan = Loan()
                loan.name = jsonLoan["name"] as! String
                loan.amount = jsonLoan["loan_amount"] as! Int
                loan.use = jsonLoan["use"] as! String
                let location = jsonLoan["location"] as! [String : AnyObject]
                loan.country = location["country"] as! String
                
                loans.append(loan)
            }
            
        } catch {
            print(error)
        }
        
        return loans
    }
    

}
