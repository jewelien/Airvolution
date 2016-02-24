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
import GoogleMobileAds

class LocationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    var tableView:UITableView!
    var isSavedLocation:Bool = true
    var selectedMapItem: MKMapItem = MKMapItem()
    var selectedLocation:NSManagedObject?
    var savedLocation:Location?
    var savedLocationPhone:NSString = ""
    var screenWidth:CGFloat!
    var bannerView:GADBannerView!
    
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
    var forBicycleLabel:UILabel?;
    var isForBike = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.screenWidth = UIScreen.mainScreen().bounds.width
        setupTableView()
        addAdView()
        if let savedLoc = self.selectedLocation {
            self.savedLocation = (savedLoc as! Location)
            self.tableView.frame.size.height = self.tableView.frame.size.height - 100
            self.navigationController?.navigationBar.backgroundColor = UIColor.airvolutionRed()
        } else {
            self.navigationItem.title = "Add Location"
            self.tableView.frame.size.height = self.tableView.frame.size.height - 50
            bannerView.frame.origin.y = bannerView.frame.origin.y + 50
        }
    }

// MARK: tableView
    func setupTableView() {
        self.tableView = UITableView(frame: self.view.bounds, style: UITableViewStyle.Grouped)
        self.view.addSubview(self.tableView)
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    
    func addAdView() {
        bannerView = StyleController.sharedInstance.bannerView
        bannerView.rootViewController = self
        bannerView.loadRequest(GADRequest())
        self.view.addSubview(bannerView)
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            if self.isSavedLocation {
                return 3
            } else {
                return 4
            }
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
                    cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "cell")
                    cell?.detailTextLabel?.text = "Added: \(location.creationDateString)"
                    cell?.addSubview(rightImageViewForCell(cell!))
                }
                cell!.textLabel?.text = "\(locationName())"
                cell?.textLabel?.font = UIFont(name: (cell?.textLabel?.font?.fontName)!, size: 25.0)
            case 1: cell!.textLabel?.text = "\(niceAddress())"
                    cell?.textLabel?.numberOfLines = 3
                    let locationImg = UIImage(imageLiteral: "redMarker")
                    cell?.imageView?.image = locationImg
                    cell?.imageView?.transform = makeScaleForImage(locationImg)
            case 2: cell!.textLabel?.text = "\(phoneNumber())"
                    let phoneImg = UIImage(imageLiteral: "phone")
                    cell?.imageView?.image = phoneImg
                    cell?.imageView?.transform = makeScaleForImage(phoneImg)
            case 3: cell?.textLabel?.text = "For Bicycles"
                    cell?.addSubview(self.addLabelToCell(cell!))
                    let bikeImg = UIImage(imageLiteral: "bike")
                    cell?.imageView?.image = bikeImg
                    cell?.imageView?.transform = makeScaleForImage(bikeImg)
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
    
    func makeScaleForImage(image:UIImage) -> CGAffineTransform {
        let widthScale = 25 / image.size.width;
        let heightScale = 25 / image.size.height;
        return CGAffineTransformMakeScale(widthScale, heightScale)
    }
    
    func addLabelToCell(cell:UITableViewCell) -> UILabel {
        let cellHeight = cell.frame.size.height
        let label = UILabel(frame: CGRect(x: self.screenWidth - 75 - 15, y:cellHeight / 2 - 12, width: 75, height: 25))
        label.textAlignment = NSTextAlignment.Right
        label.textColor = UIColor.airvolutionRed()
        label.text = "NO"
        self.forBicycleLabel = label
        return label;
    }
    
    func rightImageViewForCell(cell:UITableViewCell)->UIImageView {
        
        var image:UIImage!
        if self.savedLocation?.isForBike.boolValue == true  {
            image = UIImage(imageLiteral: "bike")
        } else {
            image = UIImage(imageLiteral: "car")
        }
        let imageView = UIImageView(image: image)
        imageView.frame = CGRect(x: self.screenWidth - 60, y:cell.frame.size.height / 2 - 12, width: 50, height: 50)
        imageView.transform = makeScaleForImage(image)
        return imageView;
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
            case 3: forBicyclesTapped()
            default : tableView.deselectRowAtIndexPath(indexPath, animated: true)
            }
        }
        if indexPath.section == 1 {
            switch cellLabelText! {
            case self.saveString:
                confirmSaveAlert()
            case self.deleteString:
                LocationController.sharedInstance().deleteLocationWithRecordName(self.savedLocation?.recordName)
                self.navigationController?.popViewControllerAnimated(true)
            case self.reportString:
                reportLocationAlert()
            case self.alreadyReportedString:
                cancelReportedLocationAlert()
            default: self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0: return false
            default: return true
            }
        }
        return true;
    }
    
    func reportLocationAlert() {
        let alert = UIAlertController(title: "Are you sure?", message: "By reporting this location you are requesting it to be removed. \n Please report the following: \n -Location does not exist. \n -Location does not have a FREE air pump.", preferredStyle: UIAlertControllerStyle.Alert)
        
        let confirm = UIAlertAction(title: "Report", style: UIAlertActionStyle.Default) { (action) -> Void in
            LocationController.sharedInstance().reportLocation(self.savedLocation, withCompletion: { (success:Bool) -> Void in
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
    
    func cancelReportedLocationAlert() {
        let alert = UIAlertController(title: "", message: "You have already reported this location.", preferredStyle: UIAlertControllerStyle.Alert)
        let confirm = UIAlertAction(title: "Cancel Report", style: UIAlertActionStyle.Default) { (action) -> Void in
            LocationController.sharedInstance().cancelReportOnLocation(self.savedLocation, withCompletion: { (success:Bool) -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if success {
                        self.cancelReportSuccessAlert()
                    } else {
                        self.cancelReportFailedAlert()
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
        let alert = UIAlertController(title: "Reported", message: "Thank you for reporting this location.", preferredStyle: UIAlertControllerStyle.Alert)
        let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { (action) -> Void in
            alert.removeFromParentViewController()
            self.navigationController?.popViewControllerAnimated(true)
        }
        alert.addAction(ok)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func failedReportAlert() {
        let alert = UIAlertController(title: "Failed to Report", message: "Location report failed. Please try again later.", preferredStyle: UIAlertControllerStyle.Alert)
        let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { (action) -> Void in
            alert.removeFromParentViewController()
            self.navigationController?.popViewControllerAnimated(true)
        }
        alert.addAction(ok)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func cancelReportSuccessAlert () {
        let alert = UIAlertController(title: "Report Cancelled", message: "Your report has been cancelled. Thank you.", preferredStyle: UIAlertControllerStyle.Alert)
        let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { (action) -> Void in
            alert.removeFromParentViewController()
            self.navigationController?.popViewControllerAnimated(true)
        }
        alert.addAction(ok)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func cancelReportFailedAlert() {
        let alert = UIAlertController(title: "Cancel Report Failed", message: "Failed to cancel your report. Please try again later.", preferredStyle: UIAlertControllerStyle.Alert)
        let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) { (action) -> Void in
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
    
    func forBicyclesTapped() {
        if self.forBicycleLabel?.text == "NO" {
            self.forBicycleLabel?.text = "YES"
            self.isForBike = true
        } else {
            self.forBicycleLabel?.text = "NO"
            self.isForBike = false
        }
    }
    
    func phoneNumber() -> String {
        if let number = self.selectedMapItem.phoneNumber {
            return number
        }
        if self.savedLocationPhone.length > 0 {
            return self.savedLocationPhone as String
        }
        return "phone not available"
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
    func confirmSaveAlert() {
        let saveAlert = UIAlertController(title: "Confirm Save", message: "Please only save locations with a FREE air pump.", preferredStyle: UIAlertControllerStyle.Alert)
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (action) -> Void in
            saveAlert.removeFromParentViewController()
        }
        let save = UIAlertAction(title: "Save", style: UIAlertActionStyle.Default) { (action) -> Void in
            self.saveLocation()
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        saveAlert .addAction(cancel)
        saveAlert.addAction(save)
        self.presentViewController(saveAlert, animated: true, completion: nil)
    }
    func saveLocation() {
        LocationController.sharedInstance().saveLocationWithName(locationName(), location: self.selectedMapItem.placemark.location, streetAddress: self.street, city: self.city, state: self.state, zip: self.zip, country: self.country, forBike:self.isForBike)
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
