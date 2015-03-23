# Airvolution
Features: Find gas stations with free air pumps.
          Be able to submit air pump info for gas stations.
          Users can verify stations that have been marked as free or paid. 
          Directions to the gas station selected. 

Main View Controller:
	Title label.
	Tableview with 2 large cells OR 2 large buttons.
		Add (gas station). Default to current location on map.  Show gas stations nearby.
		Find (gas station). Default to current location on map.  Show gas stations nearby with free air pump. 
 
Find View Controller: 
Map View with submitted info (gas stations that have been marked free/paid).
	  Select a gas station.
	  Present a pop up view at the bottom of the screen (directions | stop station name | verify).
		Direction pressed = open in maps or present direction. 
		Verify pressed = Present a new view or popup to verify Free or Paid. Submit. 

Add View Controller: 
  Map View with gas stations to submit air pump status to. 
	Map View with gas stations nearby.
	Select a gas station. 
	Present submission form (new view or popup). Mark as free/paid. Submit
	

Stations:
  name
  location
  freeAirPump
  paidAirPump

StationsController:
	Save station info. (name, location, air pump status).
	Update station’s air pump status. (free > paid, paid > free automatically based on “verify” submissions).
	Retrieve stations info. 
