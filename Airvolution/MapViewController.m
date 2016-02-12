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
@property (nonatomic, strong) NSMutableDictionary *locationAnnotationDictionary;
@property (nonatomic, strong) NSMutableArray *searchedItems;
@property (nonatomic, strong) NSString *selectedPhoneNumber;

@end

static NSString * const droppedPinTitle = @"Dropped Pin";


@implementation MapViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor],};
//    UIImage *logoImage = [UIImage imageNamed:@"logo"];
//    UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 10, 20)];
//    logoImageView.image = logoImage;
//    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:logoImage];
//    self.navigationItem.titleView.frame = CGRectMake(0, 0, 0, 15);
    
    self.navigationController.navigationBar.barTintColor = [UIColor airvolutionRed];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    //    self.view.backgroundColor = [UIColor colorWithWhite:0.96 alpha:5.0];
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

-(void)viewWillAppear:(BOOL)animated {
    self.title = @"AIRVOLUTION";
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
             MKPointAnnotation *searchedAnnotation = [[MKPointAnnotation alloc] init];
             searchedAnnotation.coordinate = item.placemark.coordinate;
             searchedAnnotation.title = item.name;
             [self.searchedAnnotations addObject:searchedAnnotation];
         }
         
         [self.mapView showAnnotations:self.searchedAnnotations animated:NO];
     }];
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notLoggedIniCloudAlert) name:NotLoggedIniCloudNotificationKey object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMapWithSavedLocations) name:updateMapKey object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(savedToCloudKitFailedAlert) name:newLocationSaveFailedNotificationKey object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(savedToCloudKitSuccess) name:newLocationSavedNotificationKey object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeMapAnnotations) name:locationDeletedNotificationKey object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(goToLocation:) name:goToLocationNotificationKey object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeLaunchScreen) name:removeLoadingLaunchScreenNotification object:nil];
}

- (void)removeLaunchScreen {
    [self.initialLoadingIndicatorView stopAnimating];
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
}

- (void)notLoggedIniCloudAlert {
    [self.initialLoadingIndicatorView stopAnimating];
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Required" message:@"To use this app please log in to your iCloud account in your iPhone Settings > iCloud." preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [alert removeFromParentViewController];
        [self.indicatorView stopAnimating];
    }];
    [alert addAction:cancelAction];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"Take me there" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }];
    [alert addAction:action];
    
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)removeMapAnnotations {
    [self.locationAnnotationDictionary removeAllObjects];
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self updateMapWithSavedLocations];
}

- (void)updateMapWithSavedLocations
{
    NSMutableArray *locationsArray = [NSMutableArray new];
    for (Location *location in [LocationController sharedInstance].locations) {
        MKPointAnnotation *savedAnnotation = [[MKPointAnnotation alloc] init];
        savedAnnotation.coordinate = CLLocationCoordinate2DMake(location.location.coordinate.latitude, location.location.coordinate.longitude);
        savedAnnotation.title = location.locationName;
        [locationsArray addObject:savedAnnotation];
        [self setDictionaryForLocation:location andAnnotation:savedAnnotation];
    }
    self.allLocations = locationsArray;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.mapView addAnnotations:locationsArray];
        [self.mapView reloadInputViews];
        [self removeLaunchScreen];
    });
}

-(void)setDictionaryForLocation:(Location*)location andAnnotation:(MKPointAnnotation*)annotation{
    if (!self.locationAnnotationDictionary) {
        self.locationAnnotationDictionary = [[NSMutableDictionary alloc]init];
    }
    if (!location.recordName) {
        location.recordName = @"none";
    }
    [self.locationAnnotationDictionary setValue:annotation forKey:location.recordName];
}

- (void)savedToCloudKitFailedAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Location failed to save. Please make sure you have a network connection and logged in to your iCloud account in your iPhone Settings > iCloud." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:action];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)savedToCloudKitSuccess {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Success" message:@"Location saved. Thank you!" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
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
            annotation.subtitle = [NSString stringWithFormat:@"%@", self.selectedPinAddress[0]];
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

- (void)goToLocation:(NSNotification*)notification {
    Location *profileSelectedLocation = notification.object;
    [self.mapView setCenterCoordinate:profileSelectedLocation.location.coordinate];
    MKPointAnnotation *selectedAnnotation = [self.locationAnnotationDictionary valueForKey:profileSelectedLocation.recordName];
    [self.mapView selectAnnotation:selectedAnnotation animated:YES];
}

#pragma mark - annotation views
-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    MKAnnotationView *pinView;
//    MKPinAnnotationView *pinView;
//    pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"pin"];
    
//    if ([annotation isKindOfClass:[MKPlacemark class] ]) {
    if ([self.searchedAnnotations containsObject:annotation]) {
        pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"searchedPin"];
//        pinView.pinColor = MKPinAnnotationColorGreen;
        pinView.canShowCallout = YES;
        
        UIButton *addLocationButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
        addLocationButton.tag = 2;
        pinView.rightCalloutAccessoryView = addLocationButton;
        
        UIImage *directionsImage = [UIImage imageNamed:@"rightFilled"];
        UIButton *directionsButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, directionsImage.size.width, directionsImage.size.height)];
        [directionsButton setImage:directionsImage forState:UIControlStateNormal];
        directionsButton.tag = 3;
        pinView.leftCalloutAccessoryView = directionsButton;
    } else if ([[annotation title] isEqualToString:droppedPinTitle]) {
        if (pinView == nil) {
            pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"droppedPin"];
            pinView.draggable = YES;
            pinView.canShowCallout = YES;
//            pinView.animatesDrop = YES;
//            pinView.pinColor = MKPinAnnotationColorPurple;
            
            UIButton *addLocationButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
            addLocationButton.tag = 2;
            pinView.rightCalloutAccessoryView = addLocationButton;
            
            UIImage *removePinImage = [UIImage imageNamed:@"remove"];
            UIButton *removePinButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, removePinImage.size.width, removePinImage.size.height)];
            [removePinButton setImage:removePinImage forState:UIControlStateNormal];
            removePinButton.tag = 1;
            pinView.leftCalloutAccessoryView = removePinButton;
        }     else {
            pinView.annotation = annotation;
        }
    } else { //pinview for saved/shared locations]
        pinView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"sharedPin"];
        pinView.canShowCallout = YES;
        
        CLLocation *location = [[CLLocation alloc] initWithLatitude:annotation.coordinate.latitude longitude:annotation.coordinate.longitude];
        Location *locationToCheck = [[LocationController sharedInstance]findLocationMatchingLocation:location];
        NSString *costString = locationToCheck.costString;
        if ([costString isEqualToString:@"FREE"]) {
            UIImage *img = [self drawText:[NSString stringWithFormat:@"%@ \n FREE", locationToCheck.locationName] inImage:[UIImage imageNamed:@"commentsRed"] atPoint:CGPointMake(15, 25)];
            pinView.image = img;
        } else {
            UIImage *img = [self drawText:[NSString stringWithFormat:@"%@ %@",locationToCheck.locationName, costString]
                                  inImage:[UIImage imageNamed:@"commentsGreen"]
                                  atPoint:CGPointMake(15, 25)];
            pinView.image = img;
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
    }
    return pinView;
}

-(UIImage*) drawText:(NSString*) text
             inImage:(UIImage*)  image
             atPoint:(CGPoint)   point
{
    
    NSMutableAttributedString *textStyle = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    textStyle = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",text]];
    
    // text color
    [textStyle addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, textStyle.length)];
    
    // text font
    [textStyle addAttribute:NSFontAttributeName  value:[UIFont systemFontOfSize:8.0] range:NSMakeRange(0, textStyle.length)];
    
    UIGraphicsBeginImageContext(image.size);
    [image drawInRect:CGRectMake(0,0,image.size.width,image.size.height)];
    CGRect rect = CGRectMake(point.x - 8, point.y - 18, image.size.width, image.size.height);
    [[UIColor whiteColor] set];
    
    // add text onto the image
    [textStyle drawInRect:CGRectIntegral(rect)];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
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
        //cancel dropped pin
        [self.mapView removeAnnotation:self.droppedPinAnnotation];
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
    if (droppedPin) {
        [self searchForGasNear:self.droppedPinAnnotation.coordinate withCompletion:^(NSArray *mapItems) {
            [self showSelectLocationViewWithItems:mapItems forDroppedPin:true];
        }];
    } else { //add button clicked on searched item
        LocationViewController *locationVC = [[LocationViewController alloc]init];
        locationVC.isSavedLocation = false;
        locationVC.selectedMapItem = [self findMapItemFromSearchedList:self.selectedAnnotation];
        UINavigationController *nav = [self navControllerWithTitle:@"Add Location" andRootVC:locationVC];
        [self presentViewController:nav animated:YES completion:nil];
    }
}

//add button in navigation bar
-(void)addButtonTapped {
    [self searchForGasNear:self.mapView.userLocation.coordinate withCompletion:^(NSArray *mapItems) {
        [self showSelectLocationViewWithItems:mapItems forDroppedPin:false];
    }];
}

-(void)showSelectLocationViewWithItems:(NSArray*)items forDroppedPin:(BOOL)droppedPin{
    LocationSearchViewController *searchVC = [[LocationSearchViewController alloc]init];
    searchVC.mapItems = items;
    searchVC.isDroppedPin = droppedPin;
    
    UINavigationController *nav = [self navControllerWithTitle:@"Select Location" andRootVC:searchVC];
    [self presentViewController:nav animated:true completion:nil];
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
    locationVC.isSavedLocation = true;
    locationVC.selectedLocation = location;
    locationVC.savedLocationPhone = self.selectedPhoneNumber;
    self.title = @"Map";
    [self.navigationController pushViewController:locationVC animated:true];
}

@end
