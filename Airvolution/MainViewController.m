//
//  ViewController.m
//  Airvolution
//
//  Created by Julien Guanzon on 3/23/15.
//  Copyright (c) 2015 Julien Guanzon. All rights reserved.
//

#import "MainViewController.h"
@import MapKit;

@interface MainViewController () <CLLocationManagerDelegate, MKMapViewDelegate>


@property (nonatomic) MKMapView *mapView;
@property (nonatomic) CLLocationManager *locationManager;

@property (nonatomic, strong) UIButton *dropPinButton;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;


@end

@implementation MainViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self setTitle:@"Airvolution"];
    
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
    
    
    self.dropPinButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 605, 400, 65)];
    [self.dropPinButton setTitle:@"Drop Pin" forState:UIControlStateNormal];
    self.dropPinButton.backgroundColor = [UIColor grayColor];
    [self.view addSubview:self.dropPinButton];
    [self.dropPinButton addTarget:self action:@selector(addPin) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)addPin{
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    annotation.coordinate = self.mapView.userLocation.coordinate;
    annotation.title = @"HELLO!";
    for (id annotation in self.mapView.annotations) {
        [self.mapView removeAnnotation:annotation];
    }
    [self.mapView addAnnotation:annotation];
//    [annotation release];
}


-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
    } //no pin on current location
    
    MKPinAnnotationView *pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"pin"];
    if (pinView == nil) {
        pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pin"];
        pinView.pinColor = MKPinAnnotationColorPurple;
        pinView.draggable = YES;
        pinView.canShowCallout = YES;
        pinView.animatesDrop = YES;
        
        UIButton* setButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, 50, 25)];
        [setButton setTitle:@"set" forState:UIControlStateNormal];
        [setButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        setButton.backgroundColor = [UIColor blueColor];
        pinView.rightCalloutAccessoryView = setButton;
    }
    else {
        pinView.annotation = annotation;
    }
    
    return pinView;
}



-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    
}

-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    
    if (view.rightCalloutAccessoryView) {
        NSLog(@"set button clicked");
    }
    
}



-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState {
    if (newState == MKAnnotationViewDragStateEnding) {
        CLLocationCoordinate2D droppedAt = view.annotation.coordinate;
        NSLog(@"dropped at %f %f", droppedAt.latitude, droppedAt.longitude);
        self.latitude = droppedAt.latitude;
        self.longitude = droppedAt.longitude;
        NSLog(@"dropped at %f, %f", self.latitude, self.longitude );
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
