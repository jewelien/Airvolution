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
@property (nonatomic, strong) UIButton *setButton;
@property (nonatomic, strong) UISearchBar *searchBar;

@property (nonatomic) CLLocation *location;
@property (nonatomic, strong) SetLocationView *setLocationView;

@property (nonatomic, strong) MKPointAnnotation *droppedPinAnnotation;
@property (nonatomic, strong) NSMutableArray *placemarks;
@property (nonatomic, strong) NSMutableArray *savedLocations;
@property (nonatomic, strong) NSArray *selectedPinAddress;

@end

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
    
    self.dropPinButton = [[UIButton alloc] initWithFrame:CGRectMake(235, 400, 65, 65)];
    [self.dropPinButton setImage:[UIImage imageNamed:@"location"] forState:UIControlStateNormal];
    [self.view addSubview:self.dropPinButton];
    [self.dropPinButton addTarget:self action:@selector(addPin) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *currentLocationButton = [[UIButton alloc] initWithFrame:CGRectMake(235, 470, 65, 65)];
    currentLocationButton.layer.cornerRadius = 35;
    currentLocationButton.layer.borderWidth = 2;
    currentLocationButton.layer.borderColor = [[UIColor colorWithRed:150/255.0 green:150/255.0 blue:150/255.0 alpha:1] CGColor];
    currentLocationButton.backgroundColor = [UIColor clearColor];
    [currentLocationButton setImage:[UIImage imageNamed:@"nearMeBlue"] forState:UIControlStateNormal];
    [self.view addSubview:currentLocationButton];
    [currentLocationButton addTarget:self action:@selector(currentLocationButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *clearPinsButton = [[UIButton alloc] initWithFrame:CGRectMake(235, 350, 65, 65)];
    [clearPinsButton setImage:[UIImage imageNamed:@"clear"] forState:UIControlStateNormal];
    [clearPinsButton addTarget:self action:@selector(clearPins) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:clearPinsButton];
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(20, 70, 285, 30)];
    self.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    self.searchBar.delegate = self;
    [self.searchBar setShowsCancelButton:YES];
    
    [self.view addSubview:self.searchBar];
    
    self.setLocationView = [[SetLocationView alloc] initWithFrame:CGRectMake(self.view.frame.size.width, 0, 300, self.view.frame.size.height)];
    [self.view addSubview:self.setLocationView];
    
}

#pragma mapSearch

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

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
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
        }
    }];

}


#pragma buttons
- (void)currentLocationButtonPressed
{
    self.mapView.userTrackingMode = MKUserTrackingModeFollow;
}

- (void)clearPins
{
    [self.mapView removeAnnotation:self.droppedPinAnnotation];
    [self.mapView removeAnnotations:self.placemarks];
//    [self.mapView addAnnotations:self.savedLocations];
}

#pragma annotations
- (void)addPin
{
    self.droppedPinAnnotation = [[MKPointAnnotation alloc] init];
    self.droppedPinAnnotation.coordinate = self.mapView.centerCoordinate;
    self.droppedPinAnnotation.title = @"location name";
    self.location = [[CLLocation alloc] initWithLatitude:self.droppedPinAnnotation.coordinate.latitude longitude:self.droppedPinAnnotation.coordinate.longitude];
//    NSLog(@"DROPPED %@", self.location);
    
    for (id annotation in self.mapView.annotations) {
        if ([[annotation title] isEqualToString:@"location name"]) {
            [self.mapView removeAnnotation:annotation];
        }
    }
    
    [self.mapView addAnnotation:self.droppedPinAnnotation];
//    [annotation release];
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
    } else if ([[annotation title] isEqualToString:@"location name"]) {
        if (pinView == nil) {
            pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"droppedPin"];
            pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"droppedPin"];
            pinView.draggable = YES;
            pinView.canShowCallout = YES;
            pinView.animatesDrop = YES;
            
            self.setButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, 50, 25)];
            [self.setButton setTitle:@"set" forState:UIControlStateNormal];
            [self.setButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            pinView.rightCalloutAccessoryView = self.setButton;
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


-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    if (view.rightCalloutAccessoryView) {
        NSLog(@"set button clicked");
        [UIView animateWithDuration:0.5 animations:^{
            self.setLocationView.locationFromAnnotation = self.location;
            self.setLocationView.frame = CGRectMake((self.view.frame.size.width/2) - 150, 125, 300, 225) ;
//            self.setLocationView.frame = self.view.bounds;
        }];
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




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
