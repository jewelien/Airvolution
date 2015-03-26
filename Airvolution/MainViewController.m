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
    
    
    self.dropPinButton = [[UIButton alloc]initWithFrame:CGRectMake(120, 40, 150, 65)];
    [self.dropPinButton setTitle:@"Drop Pin" forState:UIControlStateNormal];
    self.dropPinButton.backgroundColor = [UIColor grayColor];
    [self.view addSubview:self.dropPinButton];
    [self.dropPinButton addTarget:self action:@selector(addPin) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)addPin{
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    annotation.coordinate = self.mapView.userLocation.coordinate;
    annotation.title = @"HELLO!";
    [self.mapView addAnnotation:annotation];
//    [annotation release];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
