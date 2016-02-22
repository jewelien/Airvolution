//
//  LocationSearchViewController.swift
//  Airvolution
//
//  Created by Julien Guanzon on 2/5/16.
//  Copyright © 2016 Julien Guanzon. All rights reserved.
//

import UIKit
import MapKit
import GoogleMobileAds

class LocationSearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var tableView:UITableView!
    var mapItems = [MKMapItem]()
    var isDroppedPin:Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
        addAdView()
        let cancel = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: Selector("cancelAction"))
        self.navigationItem.rightBarButtonItem = cancel
    }
    
    override func viewWillAppear(animated: Bool) {
        self.title = "Select Location"
    }
    
    func cancelAction() {
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    
    func setUpTableView() {
        var tableViewRect = self.view.bounds;
        tableViewRect.size.height = tableViewRect.size.height - 50;
        self.tableView = UITableView(frame: tableViewRect, style: UITableViewStyle.Grouped)
        self.view.addSubview(self.tableView)
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    
    func addAdView() {
        let bannerView = StyleController.sharedInstance.bannerView
        bannerView.rootViewController = self
        bannerView.loadRequest(GADRequest())
        bannerView.frame.origin.y = bannerView.frame.origin.y + 50
        self.view.addSubview(bannerView)
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
        self.dismissViewControllerAnimated(false, completion: nil)
        NSNotificationCenter.defaultCenter().postNotificationName("goToSearchedLocation", object: self.mapItems[indexPath.row])
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if isDroppedPin {
            return "gas stations near dropped pin"
        }
        return "gas stations near you"
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
