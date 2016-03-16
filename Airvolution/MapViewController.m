//
//  ViewController.m
//  Airvolution
//
//  Created by Julien Guanzon on 3/23/15.
//  Copyright (c) 2015 Julien Guanzon. All rights reserved.
//

#import "MapViewController.h"
#import "LocationController.h"
#import "UserController.h"
#import "UIColor+Color.h"
#import "ProfileTableViewDatasource.h"
#import <Airvolution-Swift.h>
#import "Airvolution-Swift.h"

    
@interface MapViewController () <CLLocationManagerDelegate, MKMapViewDelegate, UISearchBarDelegate, UITableViewDelegate>

@property (nonatomic, strong) UIActivityIndicatorView *initialLoadingIndicatorView;
@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic, strong) UIButton *dropPinButton;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic) CLLocation *location;
@property (nonatomic, strong) MKPointAnnotation *droppedPinAnnotation;
@property (nonatomic, strong) NSMutableArray *searchedAnnotations;
@property (nonatomic, strong) NSArray *selectedPinAddress;
@property (nonatomic, strong) NSString *selectedPinStreet;
@property (nonatomic, strong) NSString *selectedPinCity;
@property (nonatomic, strong) NSString *selectedPinState;
@property (nonatomic, strong) NSString *selectedPinZip;
@property (nonatomic, strong) NSString *selectedPinCountry;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, strong) NSArray *allLocations;
@property (nonatomic, strong) MKPointAnnotation *selectedAnnotation;
@property (nonatomic, strong) UIView *locationInfoBackgroundView;
@property (nonatomic, strong) NSMutableArray *searchedItems;
@property (nonatomic, strong) NSString *selectedPhoneNumber;
@property (nonatomic, strong) NSDictionary *userLocationAddressDictionary;

@end

static NSString * const droppedPinTitle = @"Dropped Pin";


@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor], };
//    UIImage *logoImage = [UIImage imageNamed:@"logo"];
//    UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
//    logoImageView.image = logoImage;
//    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:logoImage];
//    self.navigationItem.titleView.frame = CGRectMake(0, 0, 0, 15);
    self.navigationController.navigationBar.barTintColor = [UIColor airvolutionRed];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
//        self.view.backgroundColor = [UIColor colorWithWhite:0.96 alpha:5.0];
    self.view.backgroundColor = [UIColor airvolutionRed];
    
    [self setupMap];
    [self navigationBarButtonItems];
    [self registerForNotifications];
    
//    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(20, -30, 285, 30)];
    [self showSearchBar];
//    UIBarButtonItem *searchButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(showSearchBar)];
//    [self.navigationItem setLeftBarButtonItem:searchButton];

    [self loadingViewAtLaunch];
}

-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation{
    CLLocation *location = [[CLLocation alloc]initWithLatitude:userLocation.location.coordinate.latitude longitude:userLocation.location.coordinate.longitude];
    [[LocationController sharedInstance]fetchLocationsnearLocation:location];
    [self reverseGeoCodeUserLocation];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:true];
    self.navigationController.navigationBar.topItem.title = @"AIRVOLUTION";
}

-(UINavigationController*)navControllerWithTitle:(NSString*)title andRootVC:(UIViewController*)rootVC {
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:rootVC];
    nav.navigationBar.barTintColor = [UIColor airvolutionRed];
    nav.navigationBar.tintColor = [UIColor whiteColor];
    nav.navigationBar.topItem.title = title;
    nav.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor],};
    return nav;
}

- (void)loadingViewAtLaunch {
    self.initialLoadingIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.initialLoadingIndicatorView.frame = self.view.bounds;
    self.initialLoadingIndicatorView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    [self.initialLoadingIndicatorView startAnimating];
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [self.navigationController.navigationBar addSubview:self.initialLoadingIndicatorView];
}


- (void)setupMap {
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
    self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 105, self.view.frame.size.width, self.view.frame.size.height - 105)];
    self.mapView.delegate = self;
    [self.view addSubview:self.mapView];
    self.mapView.showsUserLocation = YES;
    self.mapView.userTrackingMode = MKUserTrackingModeFollow;
    NSLog(@"user loc = %@", self.mapView.userLocation.location);
}

- (void)navigationBarButtonItems{
    UIBarButtonItem *add = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonTapped)];
    [self.navigationItem setRightBarButtonItem:add];
    
    UILongPressGestureRecognizer *dropPinPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(addPinWithGestureRecognizer:)];
    dropPinPress.minimumPressDuration = 1.0;
    [self.mapView addGestureRecognizer:dropPinPress];
    
    
    MKUserTrackingBarButtonItem *barButtonItem = [[MKUserTrackingBarButtonItem alloc] initWithMapView:self.mapView];
    UIImage *currentLocationImage = [UIImage imageNamed:@"nearMe"];
    UIImageView *currentLocationView = [[UIImageView alloc] initWithImage:currentLocationImage];
    [barButtonItem setCustomView:currentLocationView] ;
    [self.navigationItem setLeftBarButtonItem:barButtonItem];

}

#pragma mark - search
- (void)showSearchBar
{
    [UIView animateWithDuration:1.0 animations:^{
        self.searchBar = [[UISearchBar alloc] init];
        int viewWidth = self.view.frame.size.width;
        self.searchBar.frame = CGRectMake(10 , 70, viewWidth - 15, 30);
        self.searchBar.searchBarStyle = UISearchBarStyleMinimal;
        self.searchBar.backgroundColor = [UIColor whiteColor];
            self.searchBar.barTintColor = [UIColor lightGrayColor];
        self.searchBar.delegate = self;
        self.searchBar.placeholder = @"Search for place to add.";
        [self.view addSubview:self.searchBar];
    }];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction)];
    [self.view addGestureRecognizer:tap];
}

-(void)tapAction {
    [self.searchBar resignFirstResponder];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if (!searchText.length){
        [self.mapView removeAnnotations:self.searchedAnnotations];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.mapView removeAnnotations:self.searchedAnnotations];
    [searchBar resignFirstResponder];
    // Create and initialize a search request object.
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    request.naturalLanguageQuery = self.searchBar.text;
    request.region = self.mapView.region;
    
    // Create and initialize a search object.
    MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:request];
    
    // Start the search and display the results as annotations on the map.
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error)
     {
         self.searchedAnnotations = [NSMutableArray new];
         if (!self.searchedItems) {
             self.searchedItems = [[NSMutableArray alloc]init];
         }
         
         for (MKMapItem *item in response.mapItems) {
             [self.searchedItems addObject:item];
             MKPointAnnotation *searchedAnnotation = [self createAnnotationForMapItem:item];
             [self.searchedAnnotations addObject:searchedAnnotation];
         }
         
         [self.mapView showAnnotations:self.searchedAnnotations animated:NO];
     }];
}

-(MKPointAnnotation*)createAnnotationForMapItem:(MKMapItem*)item {
    MKPointAnnotation *searchedAnnotation = [[MKPointAnnotation alloc] init];
    searchedAnnotation.coordinate = item.placemark.coordinate;
    searchedAnnotation.title = item.name;
    return searchedAnnotation;
}

- (void)searchForGasNear:(CLLocationCoordinate2D)locationCoordinate withCompletion: (void(^)(NSArray *mapItems))completion {
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    request.naturalLanguageQuery = @"gas";
//    request.region = self.mapView.region;
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(locationCoordinate, 10, 10);
    request.region = region;
    MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:request];
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error)
     {
         if (!error) {
             completion(response.mapItems);
         } else {
             NSLog(@"Nearby locations search error; %@", error);
         }
     }];
}

-(void)searchBusinessPhoneForSavedLocation:(Location*)location withCompletion:(void (^)(NSString *phoneString))completion {
    CLLocationCoordinate2D locationCoordinates = location.location.coordinate;
    NSString *locationStreet = location.street;
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    request.naturalLanguageQuery = location.locationName;
    request.region = self.mapView.region;
    MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:request];
    [search startWithCompletionHandler:^(MKLocalSearchResponse * _Nullable response, NSError * _Nullable error) {
        NSString *phoneFound;
        for (MKMapItem *item in response.mapItems) {
            NSString *itemStreet = item.placemark.addressDictionary[@"Street"];
            if ((item.placemark.coordinate.latitude == locationCoordinates.latitude && item.placemark.coordinate.longitude == locationCoordinates.longitude) || [itemStreet isEqualToString:locationStreet]) {
                phoneFound = item.phoneNumber;
            }
        }
        completion(phoneFound);
    }];
}

-(MKMapItem*)findMapItemFromSearchedList:(MKPointAnnotation*)annotation{
    for (MKMapItem *item in self.searchedItems) {
        if (item.placemark.coordinate.latitude == annotation.coordinate.latitude && item.placemark.coordinate.longitude == annotation.coordinate.longitude) {
            self.selectedPhoneNumber = item.phoneNumber;
            return item;
        }
    }
    self.selectedPhoneNumber = nil;
    return nil;
}

#pragma mark - notification observers
-(void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadMapWithSavedLocations) name:updateMapKey object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addAnnotationForLocation:) name:locationAddedNotificationKey object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(savedToCloudKitFailedAlert) name:newLocationSaveFailedNotificationKey object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(savedToCloudKitSuccess) name:newLocationSavedNotificationKey object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeAnnotationForDeletedLocation:) name:locationDeletedNotificationKey object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(goToSavedLocation:) name:goToSavedLocationNotificationKey object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(goToSearchedMapItem:) name:@"goToSearchedLocation" object:nil];
}

- (void)removeLaunchScreen {
    [self.initialLoadingIndicatorView stopAnimating];
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
}

-(void)removeAnnotationForDeletedLocation:(NSNotification*)notification {
    Location *deletedLocation = notification.object;
    NSArray *queriedAnnotations = [self findAnnotationsWithCoordinate:deletedLocation.location.coordinate];
    [self.mapView removeAnnotations:queriedAnnotations];
    [self.mapView reloadInputViews];
}



-(NSArray*)findAnnotationsWithCoordinate:(CLLocationCoordinate2D)coordinate {
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        id<MKAnnotation> annotation = evaluatedObject;
        if ([annotation coordinate].latitude == coordinate.latitude
            && [annotation coordinate].longitude == coordinate.longitude) {
            return YES;
        } else {
            return NO;
        }
    }];
    return [self.mapView.annotations filteredArrayUsingPredicate:predicate];
}

-(void)addAnnotationForLocation:(NSNotification*)notification {
    NSString *locationRecordName = notification.object;
    Location *location = [[LocationController sharedInstance] findLocationInCoreDataWithLocationIdentifierOrRecordName:locationRecordName];
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    annotation.coordinate = CLLocationCoordinate2DMake(location.location.coordinate.latitude, location.location.coordinate.longitude);
    annotation.title = location.locationName;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.mapView addAnnotation:annotation];
        [self.mapView reloadInputViews];
        [self removeLaunchScreen];
    });
}

- (void)loadMapWithSavedLocations
{
    NSMutableArray *locationsArray = [NSMutableArray new];
    for (Location *location in [LocationController sharedInstance].locations) {
        MKPointAnnotation *savedAnnotation = [[MKPointAnnotation alloc] init];
        savedAnnotation.coordinate = CLLocationCoordinate2DMake(location.location.coordinate.latitude, location.location.coordinate.longitude);
        savedAnnotation.title = location.locationName;
        [locationsArray addObject:savedAnnotation];
    }
    self.allLocations = locationsArray;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.mapView removeAnnotations:self.mapView.annotations];
        [self.mapView addAnnotations:locationsArray];
        [self.mapView reloadInputViews];
        [self removeLaunchScreen];
    });
}

- (void)savedToCloudKitFailedAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Location failed to save. Please make sure you have a network connection and logged in to your iCloud account in your iPhone Settings > iCloud." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:action];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)savedToCloudKitSuccess {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Success" message:@"Location saved. Thank you!" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self.mapView removeAnnotation:self.droppedPinAnnotation];
        [self.mapView removeAnnotations:self.searchedAnnotations];
        self.droppedPinAnnotation = nil;
        [self.indicatorView stopAnimating];
    }];
    [alert addAction:action];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:alert animated:YES completion:nil];
    });
    
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

#pragma mark - geocode location
-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    MKPointAnnotation *selectedAnnotation = view.annotation;
    
    if ( [selectedAnnotation isKindOfClass:[MKPlacemark class]] ) {
        return;
    } else {
        CLLocation *selectedLocation = [[CLLocation alloc] initWithLatitude:selectedAnnotation.coordinate.latitude longitude:selectedAnnotation.coordinate.longitude];
        [self reverseGeocode:selectedLocation forAnnotation:selectedAnnotation];
    }
}

- (void)reverseGeocode:(CLLocation *)location forAnnotation:(MKPointAnnotation *)annotation
{
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        NSLog(@"Finding address");
        if (error) {
            NSLog(@"Error %@", error.description);
        } else {
            CLPlacemark *placemark = [placemarks lastObject];
            self.selectedPinAddress = [placemark.addressDictionary valueForKey:@"FormattedAddressLines"];
            self.selectedPinStreet = [placemark.addressDictionary valueForKey:@"Street"];
            self.selectedPinCity = [placemark.addressDictionary valueForKey:@"City"];
            self.selectedPinState = [placemark.addressDictionary valueForKey:@"State"];
            self.selectedPinZip  = [placemark.addressDictionary valueForKey:@"ZIP"];
            self.selectedPinCountry  = [placemark.addressDictionary valueForKey:@"CountryCode"];
            self.location = placemark.location;
            if (self.selectedPinStreet.length > 0) {
                annotation.subtitle = [NSString stringWithFormat:@"%@", self.selectedPinStreet];
            } else {
                annotation.subtitle = @"cannot find address";
            }
        }
    }];

}

- (void)reverseGeoCodeUserLocation {
    if (!self.userLocationAddressDictionary) {
        self.userLocationAddressDictionary = [[NSDictionary alloc]init];
    }
    CLLocation *userLocation = [[CLLocation alloc]initWithLatitude:self.mapView.userLocation.coordinate.latitude longitude:self.mapView.userLocation.coordinate.longitude];
    CLGeocoder *geoCoder = [[CLGeocoder alloc]init];
    [geoCoder reverseGeocodeLocation:userLocation completionHandler:^(NSArray* placemarks, NSError *error) {
        if (error) {
            NSLog(@"Error puling user's location address. %@", error.description);
        } else {
            CLPlacemark *placemark = [placemarks lastObject];

           self.userLocationAddressDictionary = @{
              (NSString *) CNPostalAddressStreetKey : [placemark.addressDictionary valueForKey:@"Street"],
              (NSString *) CNPostalAddressCityKey : [placemark.addressDictionary valueForKey:@"City"],
              (NSString *) CNPostalAddressStateKey : [placemark.addressDictionary valueForKey:@"State"],
              (NSString *) CNPostalAddressPostalCodeKey : [placemark.addressDictionary valueForKey:@"ZIP"],
              (NSString *) CNPostalAddressCountryKey : [placemark.addressDictionary valueForKey:@"CountryCode"]
              };
        }
    }];
}

#pragma mark - drop Pin Action
//- (void)dropPinAtCenterOfMap {
//    
//    self.droppedPinAnnotation = [[MKPointAnnotation alloc] init];
////    self.droppedPinAnnotation.coordinate = self.mapView.userLocation.coordinate;
//    self.droppedPinAnnotation.coordinate = self.mapView.centerCoordinate;
//    self.droppedPinAnnotation.title = droppedPinTitle;
//    self.location = [[CLLocation alloc] initWithLatitude:self.droppedPinAnnotation.coordinate.latitude longitude:self.droppedPinAnnotation.coordinate.longitude];
//    NSLog(@"DROPPED %@", self.location);
//    
//    for (id annotation in self.mapView.annotations) {
//        if ([[annotation title] isEqualToString:droppedPinTitle]) {
//            [self.mapView removeAnnotation:annotation];
//        }
//    }
//    [self.mapView addAnnotation:self.droppedPinAnnotation];
//}

- (void)addPinWithGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint touchPoint = [gestureRecognizer locationInView:self.mapView];
    CLLocationCoordinate2D touchMapCoordinate = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
    
    self.droppedPinAnnotation = [[MKPointAnnotation alloc] init];
    self.droppedPinAnnotation.coordinate = touchMapCoordinate;
    self.droppedPinAnnotation.title = droppedPinTitle;
    self.location = [[CLLocation alloc] initWithLatitude:self.droppedPinAnnotation.coordinate.latitude longitude:self.droppedPinAnnotation.coordinate.longitude];
    NSLog(@"DROPPED %@", self.location);
    
    for (id annotation in self.mapView.annotations) {
        if ([[annotation title] isEqualToString:droppedPinTitle]) {
            [self.mapView removeAnnotation:annotation];
        }
    }
    
    [self.mapView addAnnotation:self.droppedPinAnnotation];
}

- (void)goToSavedLocation:(NSNotification*)notification {
    Location *profileSelectedLocation = notification.object;
    [self.mapView setCenterCoordinate:profileSelectedLocation.location.coordinate];
    NSArray *array = [self findAnnotationsWithCoordinate:profileSelectedLocation.location.coordinate];
    [self.mapView selectAnnotation:array.firstObject animated:YES];
}

-(void)goToSearchedMapItem:(NSNotification*)notification {
    if (self.droppedPinAnnotation) {
        [self.mapView removeAnnotations:@[self.droppedPinAnnotation]];
        self.droppedPinAnnotation = nil;
    }
    if (self.searchedAnnotations) {
        [self.mapView removeAnnotations:self.searchedAnnotations];
    }
    MKMapItem *item = notification.object;
    MKPointAnnotation *annotation = [self createAnnotationForMapItem:item];
    self.searchedItems = [[NSMutableArray alloc]init];
    self.searchedAnnotations = [[NSMutableArray alloc]init];
    [self.searchedItems addObject:item];
    [self.searchedAnnotations addObject:annotation];
    [self.mapView setCenterCoordinate:annotation.coordinate];
    [self.mapView addAnnotation:annotation];
    [self.mapView showAnnotations:self.searchedAnnotations animated:true];
    [self.mapView selectAnnotation:annotation animated:true];
}

#pragma mark - annotation views
-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    if ([self.searchedAnnotations containsObject:annotation]) {
        return [self cancelAddViewWithAnnotation:annotation];
    } else if ([[annotation title] isEqualToString:droppedPinTitle]) {
        MKAnnotationView *pinView = [self cancelAddViewWithAnnotation:annotation];
        pinView.draggable = YES;
        return pinView;
    } else { //pinview for saved/shared locations]
        MKAnnotationView *pinView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pin"];
        pinView.canShowCallout = YES;
        
        CLLocation *location = [[CLLocation alloc] initWithLatitude:annotation.coordinate.latitude longitude:annotation.coordinate.longitude];
        Location *locationToCheck = [[LocationController sharedInstance]findLocationMatchingLocation:location];
        if (locationToCheck.isForBike) {
            pinView.image = [UIImage imageNamed:@"bike"];
            pinView.frame =  CGRectMake(pinView.frame.origin.x, pinView.frame.origin.y, 25, 25);
        } else {
            pinView.image = [UIImage imageNamed:@"redMarker"];
            pinView.frame =  CGRectMake(pinView.frame.origin.x, pinView.frame.origin.y, 30, 30);
        }

        UIImage *directionsImage = [UIImage imageNamed:@"rightFilled"];
        UIButton *directionsButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, directionsImage.size.width, directionsImage.size.height)];
        [directionsButton setImage:directionsImage forState:UIControlStateNormal];
        directionsButton.tag = 3;
        pinView.leftCalloutAccessoryView = directionsButton;
        
        UIImage *moreInfo = [UIImage imageNamed:@"right"];
        UIButton *moreInfoButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, moreInfo.size.width, moreInfo.size.height)];
        [moreInfoButton setImage:moreInfo forState:UIControlStateNormal];
//        UIButton *moreInfoButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        moreInfoButton.tag = 4;
        pinView.rightCalloutAccessoryView = moreInfoButton;
        return pinView;
    }
}

-(MKPinAnnotationView*)cancelAddViewWithAnnotation:(id<MKAnnotation>)annotation {
   MKPinAnnotationView *pinAnnotation = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pin"];
    pinAnnotation.canShowCallout = YES;
    
    UIButton *addLocationButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
    addLocationButton.tag = 2;
    pinAnnotation.rightCalloutAccessoryView = addLocationButton;
    
    UIImage *removePinImage = [UIImage imageNamed:@"remove"];
    UIButton *removePinButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, removePinImage.size.width, removePinImage.size.height)];
    [removePinButton setImage:removePinImage forState:UIControlStateNormal];
    removePinButton.tag = 1;
    pinAnnotation.leftCalloutAccessoryView = removePinButton;
    return pinAnnotation;
}

-(void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views {
    if (self.droppedPinAnnotation) {
        [mapView selectAnnotation:self.droppedPinAnnotation animated:YES];
    }
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState
{
    if (newState == MKAnnotationViewDragStateEnding) {
        CLLocationCoordinate2D droppedAt = view.annotation.coordinate;
        self.location = [[CLLocation alloc] initWithLatitude:droppedAt.latitude longitude:droppedAt.longitude];
        //        NSLog(@"DRAGGED %@", self.location );
        
    }
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    self.selectedAnnotation = view.annotation;
    if ([control tag] == 2) {
        //add
        if ([self.selectedAnnotation.title isEqualToString:droppedPinTitle]) {
            [self addLocationButtonClickedOn:true];
        } else {
            [self findMapItemFromSearchedList:self.selectedAnnotation];
            [self addLocationButtonClickedOn:false];
        }
    } else if ([control tag] == 1) {
        //remove
        [self.mapView removeAnnotation:self.selectedAnnotation];
        self.droppedPinAnnotation = nil;
    } else if ([control tag] == 3) {
        //directions, saved location and searched item
        [self directionsButtonPressedWithAnnotation:self.selectedAnnotation];
    } else if ([control tag] == 4) {
        //more info, saved location
        CLLocation *location = [[CLLocation alloc] initWithLatitude:self.selectedAnnotation.coordinate.latitude longitude:self.selectedAnnotation.coordinate.longitude];
        Location *selectedLocation = [[LocationController sharedInstance] findLocationMatchingLocation:location];
        [self searchBusinessPhoneForSavedLocation:selectedLocation withCompletion:^(NSString *phoneString) {
            self.selectedPhoneNumber = phoneString;
            [self locationMoreInfoPressedForAnnotation:selectedLocation];
        }];
    }
}

#pragma mark - add
-(void) addLocationButtonClickedOn:(BOOL)droppedPin {
    if (droppedPin) { //add button on dropped pin
        [self searchForGasNear:self.droppedPinAnnotation.coordinate withCompletion:^(NSArray *mapItems) {
            [self showSelectLocationViewWithItems:mapItems isForDroppedPin:true];
        }];
    } else { //add button on searched item
        if ([self isAlreadyASavedLocation:self.selectedAnnotation]) {
            [self locationAlreadySavedAlert];
        } else {
            LocationViewController *locationVC = [[LocationViewController alloc]init];
            locationVC.selectedMapItem = [self findMapItemFromSearchedList:self.selectedAnnotation];
            UINavigationController *nav = [self navControllerWithTitle:@"Add Location" andRootVC:locationVC];
            [self presentViewController:nav animated:YES completion:nil];
        }
    }
}

-(BOOL)isAlreadyASavedLocation:(MKPointAnnotation*)annotation{
    CLLocation *location = [[CLLocation alloc]initWithLatitude:annotation.coordinate.latitude longitude:annotation.coordinate.longitude];
    Location *savedLocation = [[LocationController sharedInstance]findLocationMatchingLocation:location];
    if (savedLocation) {
        return true;
    }
    return false;
}

-(void)locationAlreadySavedAlert{
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Error" message:@"The location you are trying to add has already been saved." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [controller removeFromParentViewController];
    }];
    [controller addAction:ok];
    [self presentViewController:controller animated:true completion:nil];
}

//add button in navigation bar
-(void)addButtonTapped {
    [self searchForGasNear:self.mapView.userLocation.coordinate withCompletion:^(NSArray *mapItems) {
        [self showSelectLocationViewWithItems:mapItems isForDroppedPin:false];
    }];
}

-(void)showSelectLocationViewWithItems:(NSArray*)items isForDroppedPin:(BOOL)droppedPin{
    LocationSearchViewController *searchVC = [[LocationSearchViewController alloc]init];
    searchVC.searchedMapItems = items;
    searchVC.isDroppedPin = droppedPin;
    
    NSDictionary *addressDict;
    if (droppedPin == true) {
        addressDict = [self addressDictionaryForDroppedPin];
    } else {
        addressDict = self.userLocationAddressDictionary;
    }
    MKPlacemark *placemark = [[MKPlacemark alloc]initWithCoordinate:self.droppedPinAnnotation.coordinate addressDictionary:addressDict];
    MKMapItem *mapItem = [[MKMapItem alloc]initWithPlacemark:placemark];
    NSString *street = [addressDict valueForKey:CNPostalAddressStreetKey];
    if (street == nil) {
        mapItem.name = @"";
    } else {
        mapItem.name = [NSString stringWithFormat: @"%@, %@", [addressDict valueForKey:CNPostalAddressStreetKey],[addressDict valueForKey:CNPostalAddressCityKey]] ;
    }
    searchVC.mapItem = mapItem;
    
    UINavigationController *nav = [self navControllerWithTitle:@"Select Location" andRootVC:searchVC];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:nav animated:true completion:nil];
    });
}

- (NSDictionary*)addressDictionaryForDroppedPin  {
    if (self.selectedPinStreet.length == 0) {
        return nil;
    }
    return @{
      (NSString *) CNPostalAddressStreetKey : self.selectedPinStreet,
      (NSString *) CNPostalAddressCityKey : self.selectedPinCity,
      (NSString *) CNPostalAddressStateKey : self.selectedPinState,
      (NSString *) CNPostalAddressPostalCodeKey : self.selectedPinZip,
      (NSString *) CNPostalAddressCountryKey : self.selectedPinCountry,
      };
}

#pragma mark - directions

-(void)directionsButtonPressedWithAnnotation:(MKPointAnnotation *)annotation
{
    CLLocation *location = [[CLLocation alloc] initWithLatitude:annotation.coordinate.latitude longitude:annotation.coordinate.longitude];
    NSDictionary *dictionary = [[LocationController sharedInstance]addressDictionaryForLocationWithCLLocation:location];
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:annotation.coordinate addressDictionary:dictionary];
    UIAlertController *controller = [[LocationController sharedInstance]alertForDirectionsToPlacemark:placemark];
    [self presentViewController:controller animated:YES completion:nil];
}

#pragma mark - location info
-(void)locationMoreInfoPressedForAnnotation:(Location*)location {
    LocationViewController *locationVC = [[LocationViewController alloc]init];
    locationVC.selectedSavedLocationObject = location;
    locationVC.savedLocationPhone = self.selectedPhoneNumber;
    UIBarButtonItem *newBackButton =
    [[UIBarButtonItem alloc] initWithTitle:@"Map"
                                     style:UIBarButtonItemStylePlain
                                    target:nil
                                    action:nil];
    [[self navigationItem] setBackBarButtonItem:newBackButton];
    [self.navigationController pushViewController:locationVC animated:true];
}

@end
