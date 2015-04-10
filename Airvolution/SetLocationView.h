//
//  SetLocationView.h
//  Airvolution
//
//  Created by Julien Guanzon on 3/27/15.
//  Copyright (c) 2015 Julien Guanzon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Location.h"
#import <MapKit/MapKit.h>

@interface SetLocationView : UIView

@property (nonatomic, strong) CLLocation *locationFromAnnotation;
@property (nonatomic, strong) NSArray *address;

@end
