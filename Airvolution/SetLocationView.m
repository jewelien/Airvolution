//
//  SetLocationView.m
//  Airvolution
//
//  Created by Julien Guanzon on 3/27/15.
//  Copyright (c) 2015 Julien Guanzon. All rights reserved.
//

#import "SetLocationView.h"
#import "LocationController.h"

@implementation SetLocationView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor lightGrayColor];
        UITextField *nameField = [[UITextField alloc] initWithFrame:CGRectMake(20, 60, 250, 50)];
        //            self.setLocationView.frame = CGRectMake((self.view.frame.size.width/2) - 150, 100, 300, 200) ;
        [nameField setPlaceholder:@"location name"];
        nameField.backgroundColor = [UIColor orangeColor];
        [self addSubview:nameField];
    }
    return self;
}




/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
