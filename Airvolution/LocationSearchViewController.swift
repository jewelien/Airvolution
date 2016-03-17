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
    var searchedMapItems = [MKMapItem]()
    var isDroppedPin:Bool = false
    var mapItem = MKMapItem()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
        let cancel = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: Selector("cancelAction"))
        self.navigationItem.rightBarButtonItem = cancel
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.title = "Select Location"
        addAdView()
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
        let request = GADRequest()
        request.testDevices = [kGADSimulatorID]
        bannerView.loadRequest(request)
        bannerView.frame.origin.y = bannerView.frame.origin.y + 50
        self.view.addSubview(bannerView)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return searchedMapItems.count
        default: return 0
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("cell")
        cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "cell")
        var mapItem: MKMapItem;
        switch indexPath.section {
            case 0: mapItem = self.mapItem
            default: mapItem = searchedMapItems[indexPath.row]
        }
        cell?.textLabel?.text = mapItem.name
        cell?.detailTextLabel?.text = niceAddress(mapItem)
        if mapItem.name?.characters.count == 0 {
            cell?.textLabel?.text = "cannot find address"
        }
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        switch indexPath.section {
        case 0:
            var street = ""
            var city = ""
            if let addressDict = self.mapItem.placemark.addressDictionary {
                if let streetFromDict = addressDict["Street"] {
                    street = streetFromDict as! String
                }
                if let cityFromDict = addressDict["City"] {
                    city = cityFromDict as! String
                }
            }
            if LocationController.sharedInstance().isLocationSavedWithStreet(street, andCity:city) == true {
                self.alreadySavedAlert()
                return
            }
            let addLocationVC = LocationViewController()
            addLocationVC.selectedMapItem = self.mapItem
            if (self.mapItem.name?.characters.count > 0) {
                self.navigationController?.pushViewController(addLocationVC, animated: true)
            } else {
                return
            }

        case 1:
            self.dismissViewControllerAnimated(false, completion: nil)
            NSNotificationCenter.defaultCenter().postNotificationName("goToSearchedLocation", object: self.searchedMapItems[indexPath.row])
        default: tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            if isDroppedPin {
                return "address at dropped pin"
            }
            return "address at current location"
        case 1:
            if isDroppedPin {
                return "gas stations near dropped pin"
            }
            return "gas stations near you"
        default: return ""
        }
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

    func alreadySavedAlert() {
        let alertController = UIAlertController(title: "Error", message: "Location already saved.", preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel) { (action) -> Void in
            alertController .removeFromParentViewController()
        }
        alertController.addAction(okAction)
        self.presentViewController(alertController, animated: true, completion: nil)
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
