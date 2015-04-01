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

@property (nonatomic) MKMapView *mapView;
@property (nonatomic) CLLocationManager *locationManager;

@property (nonatomic, strong) UIButton *dropPinButton;
@property (nonatomic, strong) UISearchBar *searchBar;

@property (nonatomic) CLLocation *location;
@property (nonatomic, strong) SetLocationView *setLocationView;

@property (nonatomic, strong) MKPointAnnotation *droppedPinAnnotation;
@property (nonatomic, strong) NSMutableArray *placemarks;
@property (nonatomic, strong) NSMutableArray *savedLocations;
@property (nonatomic, strong) NSArray *selectedPinAddress;

@end

static NSString * const droppedPinTitle = @"cancel or add";


@implementation MapViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self setTitle:@"Airvolution"];
    [self registerForNotifications];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
    self.mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
    self.mapView.delegate = self;
    [self.view addSubview:self.mapView];
    self.mapView.showsUserLocation = YES;
    self.mapView.userTrackingMode = MKUserTrackingModeFollow;
    
//    self.dropPinButton = [[UIButton alloc] initWithFrame:CGRectMake(260, 400, 45, 55)];
////    self.dropPinButton.backgroundColor = [UIColor grayColor];
//    [self.dropPinButton setImage:[UIImage imageNamed:@"location"] forState:UIControlStateNormal];
//    [self.view addSubview:self.dropPinButton];
//    [self.dropPinButton addTarget:self action:@selector(addPin) forControlEvents:UIControlEventTouchUpInside];

    UILongPressGestureRecognizer *dropPinPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(addPinWithGestureRecognizer:)];
    dropPinPress.minimumPressDuration = 1.0;
    [self.mapView addGestureRecognizer:dropPinPress];
    
    UIButton *clearPinsButton = [[UIButton alloc] initWithFrame:CGRectMake(260, 455, 45, 40)];
//    clearPinsButton.backgroundColor = [UIColor grayColor];
    [clearPinsButton setImage:[UIImage imageNamed:@"clear"] forState:UIControlStateNormal];
    [clearPinsButton addTarget:self action:@selector(clearPins) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:clearPinsButton];
    
    MKUserTrackingBarButtonItem *barButtonItem = [[MKUserTrackingBarButtonItem alloc] initWithMapView:self.mapView];
    [self.navigationItem setLeftBarButtonItem:barButtonItem];
    
    UIBarButtonItem *searchButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(showSearchBar)];
    [self.navigationItem setRightBarButtonItem:searchButton];
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(20, -30, 285, 30)];

    self.setLocationView = [[SetLocationView alloc] initWithFrame:CGRectMake(self.view.frame.size.width, 0, 300, self.view.frame.size.height)];
    [self.view addSubview:self.setLocationView];
}

#pragma mapSearch

- (void)showSearchBar
{
    [UIView animateWithDuration:1.0 animations:^{
        self.searchBar.frame = CGRectMake(20, 70, 285, 30);
        self.searchBar.searchBarStyle = UISearchBarStyleDefault;
        //    self.searchBar.barTintColor = [UIColor whiteColor];
        self.searchBar.delegate = self;
        self.searchBar.showsCancelButton = YES;
        [self.view addSubview:self.searchBar];
    }];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    [self.mapView removeAnnotations:self.placemarks];
    [UIView animateWithDuration:1.0 animations:^{
        self.searchBar.frame = CGRectMake(20, -30, 285, 30);
        self.searchBar.text = @"";
    }];
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
}

- (void)updateMapWithSavedLocations
{
    self.savedLocations = [NSMutableArray new];
    for (NSDictionary *dictionary in [LocationController sharedInstance].locations) {
        MKPointAnnotation *savedAnnotation = [[MKPointAnnotation alloc] init];
        CLLocation *location = dictionary[locationKey];
        savedAnnotation.coordinate = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude);
        savedAnnotation.title = dictionary[nameKey];
        
        [self.savedLocations addObject:savedAnnotation];
    }
    [self.mapView addAnnotations:self.savedLocations];
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
            NSLog(@"%@", self.selectedPinAddress);
            annotation.subtitle = [NSString stringWithFormat:@"%@", self.selectedPinAddress[0]];
            
//            MKPinAnnotationView *view = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"savedPin"];
//            view.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
////            need to set this only for savedPinLocations
        }
    }];

}

#pragma annotations
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
        pinView.pinColor = MKPinAnnotationColorPurple;
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
        pinView.pinColor = MKPinAnnotationColorGreen;
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
        [UIView animateWithDuration:0.5 animations:^{
            self.setLocationView.locationFromAnnotation = self.location;
            self.setLocationView.frame = CGRectMake((self.view.frame.size.width/2) - 150, 125, 300, 225) ;
//            self.setLocationView.frame = self.view.bounds;
        }];
    } else if ([control tag] == 1) {
        [self.mapView removeAnnotation:self.droppedPinAnnotation];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
