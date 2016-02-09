//
//  LocationSearchViewController.swift
//  Airvolution
//
//  Created by Julien Guanzon on 2/5/16.
//  Copyright © 2016 Julien Guanzon. All rights reserved.
//

import UIKit
import MapKit

class LocationSearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var tableView:UITableView!
    var navBar: UINavigationBar = UINavigationBar()
    var mapItems = [MKMapItem]()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
        self.navigationController?.navigationBar.topItem?.title = "Select Location"
        
    }
    
    func setUpTableView() {
        self.tableView = UITableView(frame: self.view.bounds, style: UITableViewStyle.Grouped)
        self.view.addSubview(self.tableView)
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mapItems.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("cell")
        cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "cell")
        let mapItem = mapItems[indexPath.row]
        cell?.textLabel?.text = mapItem.name
        cell?.detailTextLabel?.text = niceAddress(mapItem)
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let addLocationVC = LocationViewController()
        addLocationVC.isSavedLocation = false
        addLocationVC.selectedMapItem = self.mapItems[indexPath.row]
        self.navigationController?.pushViewController(addLocationVC, animated: true)
        self.tableView .deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "nearby gas stations"
    }

    func niceAddress(mapItem:MKMapItem) -> String {
        var addressString: String = ""
        if let addressDict = mapItem.placemark.addressDictionary {
            if let street = addressDict["Street"] {
                addressString.appendContentsOf("\(street), ")
            }
            if let city = addressDict["City"] {
                addressString = addressString + "\(city), "
            }
            if let state = addressDict["State"] {
                addressString.appendContentsOf("\(state) ")
            }
            if let zipCode = addressDict["ZIP"] {
                addressString.appendContentsOf("\(zipCode) ")
            }
            if let country = addressDict["CountryCode"] {
                addressString.appendContentsOf("\(country) ")
            }
        }
        return addressString
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
