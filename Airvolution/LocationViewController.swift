//
//  LocationViewController.swift
//  Airvolution
//
//  Created by Julien Guanzon on 2/2/16.
//  Copyright © 2016 Julien Guanzon. All rights reserved.
//

import UIKit
import MapKit

class LocationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    var tableView:UITableView!
    var navBar: UINavigationBar = UINavigationBar()
    var isSavedLocation:Bool = true
    var selectedMapItem: MKMapItem = MKMapItem()
    var selectedLocation:NSManagedObject?
    var savedLocation:Location?
    var savedLocationPhone:NSString = ""
    var isPaid:Bool = false
    var price:NSNumber?
    var notesTextField:UITextField!
    var screenWidth:CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.screenWidth = UIScreen.mainScreen().bounds.width
        setupTableView()
        if !isSavedLocation {
            let newNavBar = UINavigationBar(frame: self.navBar.frame)
            let navItem = UINavigationItem()
            navItem.title = "Add Location"
            newNavBar.pushNavigationItem(navItem, animated: true)
            self.view.addSubview(newNavBar)
        } else {
            self.navigationController?.navigationBar.topItem?.title = "Back to Map"
            self.savedLocation = (self.selectedLocation as! Location)
        }
    }
    
    func setupTableView() {
        var bounds:CGRect = self.view.bounds;
        bounds.origin.y = bounds.origin.y + self.navBar.frame.height
        self.tableView = UITableView(frame: bounds, style: UITableViewStyle.Grouped)
        self.view.addSubview(self.tableView)
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if self.isSavedLocation {
            return 1
        }
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0 : if self.isPaid{return 6} else{return 5}
        default : return 2
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("cell")
        cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "cell")
        cell?.preservesSuperviewLayoutMargins = false
        cell?.separatorInset = UIEdgeInsetsZero
        cell?.layoutMargins = UIEdgeInsetsZero
        let cellHeight = cell?.frame.size.height
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0: cell!.textLabel?.text = "\(locationName())"
            cell?.textLabel?.font = UIFont(name: (cell?.textLabel?.font?.fontName)!, size: 25.0)
            case 1: cell!.textLabel?.text = "Address:" + "\n" + "\(niceAddress())"
            cell?.textLabel?.numberOfLines = 3
            case 2: cell!.textLabel?.text = "Phone: \(phoneNumber())"
            case 3: cell!.textLabel?.text = "Air Pump"
            if let location = self.savedLocation {
                // cell?.addSubview(addCellLabel(cellHeight!, text: location.cost))
            } else {
                cell?.addSubview(addSegmentedControl(cellHeight!))
                }
            case 4:
                if self.isPaid {
                    cell!.textLabel?.text = "Cost"
                    cell?.addSubview(addCostTextField(cellHeight!))
                } else {
                    cell!.textLabel?.text = "Notes"
                    if let location = self.savedLocation {
                        cell?.addSubview(addCellLabel(cellHeight!, text: location.locationNotes))
                    } else {
                        cell?.addSubview(addNotesTextField(cellHeight!))
                    }
                }
            default: break
            }
        }
        if indexPath.section == 1 {
            cell?.textLabel?.textAlignment = NSTextAlignment.Center
            cell?.backgroundColor = UIColor.airvolutionRed()
            cell?.textLabel?.textColor = UIColor.whiteColor()
            switch indexPath.row {
            case 0: cell!.textLabel?.text = "Cancel"
            default: cell!.textLabel?.text = "Save"
            }
        }
        
        return cell!
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
        if indexPath.section == 0 {
            switch indexPath.row {
            case 2 : phoneNumberTapped()
            default : tableView.deselectRowAtIndexPath(indexPath, animated: true)
            }
        }
        if indexPath.section == 1 {
            switch indexPath.row {
            case 1 : // save and dismiss controller.
                if self.isPaid {

                }
            default : self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    func textFieldDidBeginEditing(textField: UITextField) {
        textField.text = "$"
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        //don't allow $ sign to be deleted
        if string.characters.count == 0 && textField.text == "$"{
            return false;
        }
        //allow backspace everytime. add a max character count 5.
        if string.characters.count > 0 && textField.text?.characters.count > 5 {
            return false
        }
        //return only numbers
        let components = string.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString:"0123456789.").invertedSet)
        let filtered = components.joinWithSeparator("")
        return string == filtered
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if let costString = textField.text {
            let components = costString.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString:"0123456789.").invertedSet)
            let filtered = components.joinWithSeparator("")
            let formatter = NSNumberFormatter()
            formatter.numberStyle = NSNumberFormatterStyle.DecimalStyle
            self.price = formatter.numberFromString(filtered)
        }
    }
    
    func addNotesTextField(cellHeight:CGFloat) -> UITextField {
        let textField = UITextField(frame: CGRect(x: self.screenWidth / 2 - 100, y:cellHeight / 2 - 12, width: self.screenWidth - 115, height: 25))
        textField.placeholder = "optional"
        textField.textAlignment = NSTextAlignment.Right
        self.notesTextField = textField;
        return textField;
    }
    
    func addCostTextField(cellHeight:CGFloat) -> UITextField {
        let textField = UITextField(frame: CGRect(x: self.screenWidth - 75 - 15, y:cellHeight / 2 - 12, width: 75, height: 25))
        textField.delegate = self
        textField.textAlignment = NSTextAlignment.Right
        textField.text = "$0.00"
        return textField;
    }
    
    func addCellLabel(cellHeight:CGFloat, text:String) -> UILabel {
        let label = UILabel(frame: CGRect(x: self.screenWidth / 2 - 100, y:cellHeight / 2 - 12, width: self.screenWidth - 115, height: 25))
        label.textAlignment = NSTextAlignment.Right
        if text.characters.count > 0 {
            label.text = text
        } else {
            label.text = "n/a"
        }
        return label
    }
    
    func addSegmentedControl(cellHeight:CGFloat) -> UISegmentedControl {
        let segmentedControl = UISegmentedControl(items: ["free", "paid"])
        segmentedControl.frame = CGRectMake(self.screenWidth - 175, (cellHeight / 2) - 10, 150, 25)
        segmentedControl .addTarget(self, action: "action:", forControlEvents: UIControlEvents.ValueChanged)
        if self.isPaid && !segmentedControl.selected{
            segmentedControl.selectedSegmentIndex = 1
        } else {
            segmentedControl.selectedSegmentIndex = 0
        }
        return segmentedControl
    }
    
    func action(segment:UISegmentedControl) {
        let selectedIndex = segment.selectedSegmentIndex
        switch selectedIndex {
        case 1 : //print("\(selectedIndex)")
            self.isPaid = true
            self.tableView.reloadData()
        default : //print("\(selectedIndex)")
            self.isPaid = false
            self.tableView.reloadData()
        }
    }
    
    func locationName() -> String {
        if let name = self.selectedMapItem.name{
            if name != "Unknown Location" {
                return name;
            }
        }
        
        if let location = self.savedLocation {
            return location.locationName
        }
        return "";
    }
    
    func phoneNumber() -> String {
        if let number = self.selectedMapItem.phoneNumber {
            return number
        }
        if self.savedLocationPhone.length > 0 {
            return self.savedLocationPhone as String
        }
        return ""
    }
    
    func phoneNumberTapped() {
        let characterSet = NSCharacterSet(charactersInString: "0123456789-+()").invertedSet
        let cleanNumber = phoneNumber().componentsSeparatedByCharactersInSet(characterSet).joinWithSeparator("")
        let escapedNumber = cleanNumber.stringByAddingPercentEncodingWithAllowedCharacters(characterSet)
        let numberURLSting = "telprompt:\(escapedNumber)"
        let phoneURL = NSURL(string: numberURLSting)
        if let url = phoneURL {
            if UIApplication .sharedApplication() .canOpenURL(url) {
                UIApplication.sharedApplication().openURL(url)
            }
        }
    }
    
    func niceAddress() -> String {
        var addressString: String = ""
        if let addressDict = self.selectedMapItem.placemark.addressDictionary {
            if let street = addressDict["Street"] {
                addressString.appendContentsOf("\(street) ")
            }
            if let city = addressDict["City"] {
                addressString = addressString + "\n" + "\(city), "
            }
            if let state = addressDict["State"] {
                addressString.appendContentsOf("\(state) ")
            }
            if let postalCode = addressDict["ZIP"] {
                addressString.appendContentsOf("\(postalCode) ")
            }
            if let countryCode = addressDict["CountryCode"] {
                addressString.appendContentsOf("\(countryCode) ")
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
