# Airvolution

#### Problem 
- When you need air for tires and don’t have any change or cash, Airvolution will help you find the closest locations with free air pumps.

#### Marketing
- Airvolution is a community based location finder app to locate places that offers free air pumps. 


#### Features
- Find locations with free air pumps.
- Drop pin to add location of free air pump. 
- Thumbs up, thumbs down buttons for users to verify locations. 
- Directions to the location selected. 


##### MainViewController
	- Title label.
	- Add location button.

##### FindLocationsViewController
	Map View with submitted info (locations that have been marked with free air pumps).
	-Select a location.
	-Present a pop up view at the bottom of the screen (directions | location name | thumbs up/down).
		-Direction pressed = open in maps or present directions.
	-Drop pin to current location. Can move pin around. Once set present pop up view at the bottom to enter a location name and a submit button. 
	
##### Station 
	-name
	-location
	-thumbsUp
	-thumbsDown

##### StationController
	-Add location info. (name, location, air pump status).
	-Remove location's air pump status. (based on thumbs down submissions).
	-Retrieve locations info.




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
