//
//  ViewController.m
//  Airvolution
//
//  Created by Julien Guanzon on 3/23/15.
//  Copyright (c) 2015 Julien Guanzon. All rights reserved.
//

#import "MainViewController.h"
#import "SetLocationView.h"
@import MapKit;

@interface MainViewController () <CLLocationManagerDelegate, MKMapViewDelegate>


@property (nonatomic) MKMapView *mapView;
@property (nonatomic) CLLocationManager *locationManager;

@property (nonatomic, strong) UIButton *dropPinButton;
@property (nonatomic) CLLocation *location;

@property (nonatomic, strong) UIButton *setButton;
@property (nonatomic, strong) SetLocationView *setLocationView;



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
    
    self.setLocationView = [[SetLocationView alloc] initWithFrame:CGRectMake(self.view.frame.size.width, 0, 300, 300)];
    [self.view addSubview:self.setLocationView];
    
    
}

- (void)addPin{
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    annotation.coordinate = self.mapView.userLocation.coordinate;
    annotation.title = @"set location";
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
//        pinView.pinColor = MKPinAnnotationColorPurple;
        pinView.draggable = YES;
        pinView.canShowCallout = YES;
        pinView.animatesDrop = YES;
        
        self.setButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, 50, 25)];
        [self.setButton setTitle:@"set" forState:UIControlStateNormal];
        [self.setButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        setButton.backgroundColor = [UIColor blueColor];
        pinView.rightCalloutAccessoryView = self.setButton;
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
        [UIView animateWithDuration:0.5 animations:^{
            self.setLocationView.frame = CGRectMake((self.view.frame.size.width/2) - 150, 100, 300, 200) ;
            
        }];
//        [self.setButton addTarget:self action:@selector(presentView) forControlEvents:UIControlEventTouchUpInside];
        
    }
    
}

- (void)presentView {
    [UIView animateWithDuration:1.0 animations:^{
        self.setLocationView.frame = self.view.bounds;
        
    }];
}


-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState {
    if (newState == MKAnnotationViewDragStateEnding) {
        CLLocationCoordinate2D droppedAt = view.annotation.coordinate;
        self.location = [[CLLocation alloc] initWithLatitude:droppedAt.latitude longitude:droppedAt.longitude];
        NSLog(@"dropped at %@", self.location );
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
