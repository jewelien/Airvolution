//
//  LocationViewController.swift
//  Airvolution
//
//  Created by Julien Guanzon on 2/2/16.
//  Copyright © 2016 Julien Guanzon. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class LocationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    var tableView:UITableView!
    var isSavedLocation:Bool = true
    var selectedMapItem: MKMapItem = MKMapItem()
    var selectedLocation:NSManagedObject?
    var savedLocation:Location?
    var savedLocationPhone:NSString = ""
    var screenWidth:CGFloat!
    
    var street:String?
    var city:String?
    var state:String?
    var zip:String?
    var country:String?
    
    let cancelString = "Cancel"
    let saveString = "Save and Share"
    let deleteString = "Delete Location"
    let reportString = "Report Location"
    let alreadyReportedString = "Already Reported"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.screenWidth = UIScreen.mainScreen().bounds.width
        setupTableView()
        if let savedLoc = self.selectedLocation {
            self.savedLocation = (savedLoc as! Location)
        } else {
            self.navigationItem.title = "Add Location"
        }
    }

// MARK: tableView
    func setupTableView() {
        self.tableView = UITableView(frame: self.view.bounds, style: UITableViewStyle.Grouped)
        self.view.addSubview(self.tableView)
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 3
        case 1:
            if self.isSavedLocation {
                return 1
            } else {
                return 2
            }
        default: break
        }
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("cell")
        cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "cell")
        cell?.preservesSuperviewLayoutMargins = false
        cell?.separatorInset = UIEdgeInsetsZero
        cell?.layoutMargins = UIEdgeInsetsZero
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                if let location = self.savedLocation {
                    cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "subtitleCell")
                    cell?.detailTextLabel?.text = "Added: \(location.creationDateString)"
                }
                cell!.textLabel?.text = "\(locationName())"
                cell?.textLabel?.font = UIFont(name: (cell?.textLabel?.font?.fontName)!, size: 25.0)
            case 1: cell!.textLabel?.text = "Address:" + "\n" + "\(niceAddress())"
            cell?.textLabel?.numberOfLines = 3
            case 2: cell!.textLabel?.text = "Phone: \(phoneNumber())"
              default: break
            }
        }
        if indexPath.section == 1 {
            cell?.textLabel?.textAlignment = NSTextAlignment.Center
            cell?.backgroundColor = UIColor.airvolutionRed()
            cell?.textLabel?.textColor = UIColor.whiteColor()
            switch indexPath.row {
            case 0:
                if !self.isSavedLocation {
                    cell!.textLabel?.text = self.cancelString
                } else if (self.savedLocation?.userRecordName == UserController.sharedInstance().currentUserRecordName) {
                    cell!.textLabel?.text = self.deleteString
                } else {
                    if userAlreadyReportedLocation() {
                        cell?.textLabel?.text = self.alreadyReportedString
                        cell?.backgroundColor = UIColor.lightGrayColor()
                    } else {
                        cell?.textLabel?.text = self.reportString
                    }
                }
            default: cell!.textLabel?.text = self.saveString
            }
        }
        
        return cell!
    }
    
    func userAlreadyReportedLocation() -> Bool {
        if let reportsArray = self.savedLocation?.reports {
            let array = reportsArray as! Array<String>
            let currentUserRecordName = UserController.sharedInstance().currentUserRecordName
            if let userRecordName = currentUserRecordName {
                if array.contains(userRecordName){
                    return true;
                }
            }
        }
        return false
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0 : return 75
            case 1 : return 75
            default : return 50
            }
        }
        return 40
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = self.tableView.cellForRowAtIndexPath(indexPath)
        let cellLabelText = cell?.textLabel?.text
        print(cell?.textLabel?.text)
        if indexPath.section == 0 {
            switch indexPath.row {
            case 1: addressTapped()
            case 2 : phoneNumberTapped()
            default : tableView.deselectRowAtIndexPath(indexPath, animated: true)
            }
        }
        if indexPath.section == 1 {
            switch cellLabelText! {
            case self.saveString:
                saveLocation()
                self.dismissViewControllerAnimated(true, completion: nil)
            case self.deleteString:
                LocationController.sharedInstance().deleteLocationWithRecordName(self.savedLocation?.recordName)
                self.navigationController?.popViewControllerAnimated(true)
            case self.reportString:
                reportLocationAlert()
            default: self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        if indexPath.section == 0 {
            switch indexPath.row {
            case 1: return true
            case 2: return true
            default: return false
            }
        }
        if cell?.textLabel?.text == alreadyReportedString {
            return false
        }
        return true;
    }
    
    func reportLocationAlert() {
        let alert = UIAlertController(title: "Report", message: "You are reporting this location as inacurrate information", preferredStyle: UIAlertControllerStyle.Alert)
        let confirm = UIAlertAction(title: "Confirm", style: UIAlertActionStyle.Default) { (action) -> Void in
            LocationController.sharedInstance().reportLocation(self.savedLocation, withCompletion: { (success) -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if success {
                        self.successReportAlert()
                    } else {
                        self.failedReportAlert()
                    }
                })
            })
            alert.removeFromParentViewController()
        }
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (action) -> Void in
            alert.removeFromParentViewController()
        }
        alert.addAction(confirm)
        alert.addAction(cancel)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func successReportAlert() {
        let alert = UIAlertController(title: "Success", message: "Thank you for reporting this location.", preferredStyle: UIAlertControllerStyle.Alert)
        let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default) { (action) -> Void in
            alert.removeFromParentViewController()
            self.navigationController?.popViewControllerAnimated(true)
        }
        alert.addAction(ok)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func failedReportAlert() {
        let alert = UIAlertController(title: "Failed to Report", message: "Location report failed. Please try again later.", preferredStyle: UIAlertControllerStyle.Alert)
        let ok = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default) { (action) -> Void in
            alert.removeFromParentViewController()
            self.navigationController?.popViewControllerAnimated(true)
        }
        alert.addAction(ok)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
// MARK: Data
    func locationName() -> String {
        if let name = self.selectedMapItem.name{
            if name != "Unknown Location" {
                return name;
            }
        }
        
        if let location = self.savedLocation {
            return location.locationName
        }
        return "no name";
    }
    
    func phoneNumber() -> String {
        if let number = self.selectedMapItem.phoneNumber {
            return number
        }
        if self.savedLocationPhone.length > 0 {
            return self.savedLocationPhone as String
        }
        return "not available"
    }
    
    func phoneNumberTapped() {
        let characterSet = NSCharacterSet(charactersInString: "0123456789-+()").invertedSet
        let cleanNumber = phoneNumber().componentsSeparatedByCharactersInSet(characterSet).joinWithSeparator("")
        let numberURLString = "telprompt://\(cleanNumber)" //obj-C "telprompt:\(escapedNumber)"
        let phoneURL = NSURL(string: numberURLString)
        if let url = phoneURL {
            if UIApplication .sharedApplication() .canOpenURL(url) {
                UIApplication.sharedApplication().openURL(url)
            }
        }
    }
    
    func addressTapped() {
        var placemark:MKPlacemark;
        if let savedLoc = self.savedLocation {
            let location = CLLocation(latitude: savedLoc.location.coordinate.latitude, longitude: savedLoc.location.coordinate.longitude)
            let dictionary = LocationController.sharedInstance().addressDictionaryForLocationWithCLLocation(location)
            placemark = MKPlacemark(coordinate: location.coordinate, addressDictionary: (dictionary as! [String : AnyObject]))
        } else {
            placemark = self.selectedMapItem.placemark
        }
        let controller = LocationController.sharedInstance().alertForDirectionsToPlacemark(placemark)
        presentViewController(controller, animated: true, completion: nil)
    }
    
    func niceAddress() -> String {
        var addressString: String = ""
        if let addressDict = self.selectedMapItem.placemark.addressDictionary {
            if let street = addressDict["Street"] {
                self.street = (street as! String)
                addressString.appendContentsOf("\(street) ")
            }
            if let city = addressDict["City"] {
                self.city = (city as! String)
                addressString = addressString + "\n" + "\(city), "
            }
            if let state = addressDict["State"] {
                self.state = (state as! String)
                addressString.appendContentsOf("\(state) ")
            }
            if let zipCode = addressDict["ZIP"] {
                self.zip = (zipCode as! String)
                addressString.appendContentsOf("\(zipCode) ")
            }
            if let country = addressDict["CountryCode"] {
                self.country = (country as! String)
                addressString.appendContentsOf("\(country) ")
            }
        }
        
        if let location = self.savedLocation {
            addressString.appendContentsOf("\(location.street)")
            addressString = addressString + "\n" + "\(location.city), "
            addressString.appendContentsOf("\(location.state) ")
            addressString.appendContentsOf("\(location.zip) ")
            addressString.appendContentsOf("\(location.country)")
        }
        
        return addressString
    }
// MARK: SaveLocation
    func saveLocation() {
        LocationController.sharedInstance().saveLocationWithName(locationName(), location: self.selectedMapItem.placemark.location, streetAddress: self.street, city: self.city, state: self.state, zip: self.zip, country: self.country)
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
