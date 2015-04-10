//
//  ViewController.m
//  Airvolution
//
//  Created by Julien Guanzon on 3/23/15.
//  Copyright (c) 2015 Julien Guanzon. All rights reserved.
//

#import "MapViewController.h"
#import "SetLocationView.h"
#import "LocationController.h"

@interface MapViewController () <CLLocationManagerDelegate, MKMapViewDelegate, UISearchBarDelegate>

@property (nonatomic) CLLocationManager *locationManager;

@property (nonatomic, strong) UIButton *dropPinButton;
@property (nonatomic, strong) UISearchBar *searchBar;

@property (nonatomic) CLLocation *location;
@property (nonatomic, strong) MKPointAnnotation *droppedPinAnnotation;

@property (nonatomic, strong) SetLocationView *setLocationView;
@property (nonatomic, strong) NSMutableArray *placemarks;
@property (nonatomic, strong) NSArray *selectedPinAddress;

@end

static NSString * const droppedPinTitle = @"cancel or add";


@implementation MapViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
//    self.view.backgroundColor = [UIColor lightGrayColor];
    [self setTitle:@"Airvolution"];
    [self registerForNotifications];
    
    
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
    
//    self.dropPinButton = [[UIButton alloc] initWithFrame:CGRectMake(260, 400, 45, 55)];
////    self.dropPinButton.backgroundColor = [UIColor grayColor];
//    [self.dropPinButton setImage:[UIImage imageNamed:@"location"] forState:UIControlStateNormal];
//    [self.view addSubview:self.dropPinButton];
//    [self.dropPinButton addTarget:self action:@selector(dropPinAtCurrentLocation) forControlEvents:UIControlEventTouchUpInside];

    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    self.dropPinButton = [[UIButton alloc] initWithFrame:view.frame];
    [self.dropPinButton setImage:[UIImage imageNamed:@"location"] forState:UIControlStateNormal];
    [self.dropPinButton addTarget:self action:@selector(dropPinAtCenterOfMap) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:self.dropPinButton];
    UIBarButtonItem *pinDrop = [[UIBarButtonItem alloc] initWithCustomView:view];
    [self.navigationItem setRightBarButtonItem:pinDrop];
    
    
    UILongPressGestureRecognizer *dropPinPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(addPinWithGestureRecognizer:)];
    dropPinPress.minimumPressDuration = 1.0;
    [self.mapView addGestureRecognizer:dropPinPress];
    
    
    MKUserTrackingBarButtonItem *barButtonItem = [[MKUserTrackingBarButtonItem alloc] initWithMapView:self.mapView];
    [self.navigationItem setLeftBarButtonItem:barButtonItem];
    
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(20, -30, 285, 30)];
    [self showSearchBar];
//    UIBarButtonItem *searchButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(showSearchBar)];
//    [self.navigationItem setLeftBarButtonItem:searchButton];

//    self.setLocationView = [[SetLocationView alloc] initWithFrame:CGRectMake(self.view.frame.size.width, 0, 300, self.view.frame.size.height)];
//    [self.view addSubview:self.setLocationView];
}

#pragma mapSearch

- (void)showSearchBar
{
    [UIView animateWithDuration:1.0 animations:^{
        self.searchBar.frame = CGRectMake(20, 70, 285, 30);
        self.searchBar.searchBarStyle = UISearchBarStyleMinimal;
//        self.searchBar.backgroundColor = [UIColor blackColor];
//            self.searchBar.barTintColor = [UIColor whiteColor];
        self.searchBar.delegate = self;
        self.searchBar.showsCancelButton = YES;
        [self.view addSubview:self.searchBar];
    }];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    [self.mapView removeAnnotations:self.placemarks];
//    [UIView animateWithDuration:1.0 animations:^{
//        self.searchBar.frame = CGRectMake(20, -30, 285, 30);
//        self.searchBar.text = @"";
//    }];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
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
         self.placemarks = [NSMutableArray array];
         for (MKMapItem *item in response.mapItems) {
             [self.placemarks addObject:item.placemark];
         }
//         [self.mapView removeAnnotations:[self.mapView annotations]];
         [self.mapView showAnnotations:self.placemarks animated:NO];
     }];
}

#pragma notification observer
-(void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateMapWithSavedLocations) name:@"locationsFetched" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(savedToCloudKitFailedAlert) name:@"CloudKitSaveFail" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(savedToCloudKitSuccess) name:@"savedToCloudKit" object:nil];
}

- (void)updateMapWithSavedLocations
{
    NSMutableArray *locationsArray = [NSMutableArray new];
    for (Location *location in [LocationController sharedInstance].locations) {
        MKPointAnnotation *savedAnnotation = [[MKPointAnnotation alloc] init];
        savedAnnotation.coordinate = CLLocationCoordinate2DMake(location.location.coordinate.latitude, location.location.coordinate.longitude);
        savedAnnotation.title = location.locationName;
        
        [locationsArray addObject:savedAnnotation];
    }
    [self.mapView addAnnotations:locationsArray];
}


- (void)savedToCloudKitFailedAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"error" message:@"Please log in to your iCloud in your iPhone Settings > iCloud." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:action];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)savedToCloudKitSuccess {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Thanks!" message:@"Location saved. Thank you!" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"ok" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:action];
    [self presentViewController:alert animated:YES completion:nil];
//    [self.mapView removeAnnotation:self.droppedPinAnnotation];

}

-(void)deRegisterForNotifcations
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

#pragma geocode location

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
//            NSLog(@"selectedPinAddress array %@", placemark);
            annotation.subtitle = [NSString stringWithFormat:@"%@", self.selectedPinAddress[0]];
            
//            MKPinAnnotationView *view = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"savedPin"];
//            view.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
////            need to set this only for savedPinLocations
        }
    }];

}

#pragma annotations
- (void)dropPinAtCenterOfMap {
    
    self.droppedPinAnnotation = [[MKPointAnnotation alloc] init];
//    self.droppedPinAnnotation.coordinate = self.mapView.userLocation.coordinate;
    self.droppedPinAnnotation.coordinate = self.mapView.centerCoordinate;
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
//- (void)dropPinAtCurrentLocation {
//    
//    self.droppedPinAnnotation = [[MKPointAnnotation alloc] init];
//    self.droppedPinAnnotation.coordinate = self.mapView.userLocation.coordinate;
//    self.droppedPinAnnotation.title = droppedPinTitle;
//    self.location = [[CLLocation alloc] initWithLatitude:self.droppedPinAnnotation.coordinate.latitude longitude:self.droppedPinAnnotation.coordinate.longitude];
//    NSLog(@"DROPPED %@", self.location);
//    
//    for (id annotation in self.mapView.annotations) {
//        if ([[annotation title] isEqualToString:droppedPinTitle]) {
//            [self.mapView removeAnnotation:annotation];
//        }
//    }
//    self.mapView.userTrackingMode = MKUserTrackingModeFollow;
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


-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    }
    
    MKPinAnnotationView *pinView;
    
    if ([annotation isKindOfClass:[MKPlacemark class] ]) {
        pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"placemarksPin"];
        pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"placemarksPin"];
        pinView.pinColor = MKPinAnnotationColorGreen;
        pinView.canShowCallout = YES;
    } else if ([[annotation title] isEqualToString:droppedPinTitle]) {
        if (pinView == nil) {
            pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"droppedPin"];
            pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"droppedPin"];
            pinView.draggable = YES;
            pinView.canShowCallout = YES;
//            pinView.animatesDrop = YES;
            
            UIButton *addLocationButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
            addLocationButton.tag = 2;
            pinView.rightCalloutAccessoryView = addLocationButton;
            
            UIImage *removePinImage = [UIImage imageNamed:@"remove"];
            UIButton *removePinButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, removePinImage.size.width, removePinImage.size.width)];
            [removePinButton setImage:removePinImage forState:UIControlStateNormal];
            removePinButton.tag = 1;
            pinView.leftCalloutAccessoryView = removePinButton;
            
        }     else {
            pinView.annotation = annotation;
        }
    } else {
        pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"savedPin"];
        pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"savedPin"];
        pinView.pinColor = MKPinAnnotationColorPurple;
        pinView.canShowCallout = YES;
    }
    
    return pinView;
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
    if ([control tag] == 2) {
        NSLog(@"add button clicked");
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Enter Location" message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = @"location name";
        }];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"cancel" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self removeFromParentViewController];
        }];
        [alertController addAction:cancelAction];
        
        UIAlertAction *saveAction = [UIAlertAction actionWithTitle:@"save" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            UITextField *textField = alertController.textFields[0];
            if ([textField.text isEqualToString:@""]) {
                NSLog(@"no text");
            } else {
            [[LocationController sharedInstance]saveLocationWithName:textField.text location:self.location addressArray:self.selectedPinAddress];
            }
        }];
        [alertController addAction:saveAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
//        [UIView animateWithDuration:0.5 animations:^{
//            self.setLocationView.locationFromAnnotation = self.location;
//            self.setLocationView.address = self.selectedPinAddress;
//            NSLog(@"self.location %@ ... self.selectedPinAddress %@", self.location, self.selectedPinAddress);
//            self.setLocationView.frame = CGRectMake((self.view.frame.size.width/2) - 150, 125, 300, 225);
////            self.setLocationView.frame = self.view.bounds;
//        }];
        
    } else if ([control tag] == 1) {
        [self.mapView removeAnnotation:self.droppedPinAnnotation];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
