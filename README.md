# Airvolution

#### Problem 
- When you need air for tires and don’t have any change or cash, Airvolution will help you find the closes gas station with free air pump.

#### Marketing
- Airvolution is a community based location finder app for gas stations that offers free air pump. 


#### Features
- Find gas stations with free air pumps.
- Be able to submit air pump info for gas stations.
- Users can verify stations that have been marked as free or paid. 
- Directions to the gas station selected. 


##### MainViewController:
	-Title label.
	-Tableview with 2 large cells OR 2 large buttons.
		Add (gas station). Default to current location on map.  Show gas stations nearby.
		Find (gas station). Default to current location on map.  Show gas stations nearby with free air pump. 
 
##### FindStationViewController: 
	Map View with submitted info (gas stations that have been marked free/paid).
	  -Select a gas station.
	  -Present a pop up view at the bottom of the screen (directions | stop station name | verify).
		Direction pressed = open in maps or present direction. 
		Verify pressed = Present a new view or popup to verify Free or Paid. Submit. 

##### AddStationViewController: 
	Map View with gas stations to submit air pump status to. 
	-Map View with gas stations nearby.
	-Select a gas station. 
	-Present submission form (new view or popup). Mark as free/paid. Submit
	

##### Station: 
	-name
	-location
	-freeAirPump
	-paidAirPump

##### StationController:
	-Save station info. (name, location, air pump status).
	-Update station’s air pump status. (free > paid, paid > free automatically based on “verify” submissions).
	-Retrieve stations info. 




#### FEEDBACK:
##### Opportunies:
 	Users can verify + get points.
 	Look at waze or gas buddy.
 	Add info on gas stations that are paid.
 	Add phone # of location to see if they’re open.
 	iAds.
 	Social networking 

##### Challenges:
	Getting users to act.
	Data accuracy - important.
	Data? free in CA w/gas.
	Verifying data.
	API.
	Need a large backend.
