//
//  ViewController.h
//  Airvolution
//
//  Created by Julien Guanzon on 3/23/15.
//  Copyright (c) 2015 Julien Guanzon. All rights reserved.
//

#import <UIKit/UIKit.h>
@import MapKit;

@interface MapViewController : UIViewController

@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) NSMutableArray *savedLocations;



@end

