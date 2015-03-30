//
//  SetLocationView.m
//  Airvolution
//
//  Created by Julien Guanzon on 3/27/15.
//  Copyright (c) 2015 Julien Guanzon. All rights reserved.
//

#import "SetLocationView.h"
#import "LocationController.h"

@interface SetLocationView () <UITextFieldDelegate>

@property (nonatomic, strong) UITextField *nameField;

@end

@implementation SetLocationView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor grayColor];
        
        self.nameField = [[UITextField alloc] initWithFrame:CGRectMake(30, 60, 250, 50)];
        //self.setLocationView.frame = CGRectMake((self.view.frame.size.width/2) - 150, 100, 300, 200) ;
        self.nameField.delegate = self;
        [self.nameField setPlaceholder:@"location name"];
        [self.nameField setTextAlignment:NSTextAlignmentCenter];
        [self.nameField setClearButtonMode:UITextFieldViewModeWhileEditing];
                self.nameField.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.nameField];
        
        UIButton *saveButton = [[UIButton alloc] initWithFrame:CGRectMake(50, 120, 200, 50)];
        [saveButton setTitle:@"Share" forState:UIControlStateNormal];
        [saveButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self addSubview:saveButton];
        [saveButton addTarget:self action:@selector(saveButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(50, 175, 200, 50)];
        [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
        [cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self addSubview:cancelButton];
        [cancelButton addTarget:self action:@selector(cancelButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        
        
    }
    return self;
}

- (void)saveButtonPressed {
    NSLog(@"save button pressed %@", self.locationFromAnnotation);
    NSLog(@"save button pressed %@", self.nameField.text);
    if ([self.nameField.text isEqualToString:@""]) {
        NSLog(@"please enter a location name");
    } else {
        [[LocationController sharedInstance] saveLocationWithName:self.nameField.text location:self.locationFromAnnotation];
        self.frame = CGRectMake(self.superview.frame.size.width, 0, 300, self.superview.frame.size.height);
        self.nameField.text = @"";
    }
    
}

- (void)cancelButtonPressed {
    self.frame = CGRectMake(self.superview.frame.size.width, 0, 300, self.superview.frame.size.height);
    self.nameField.text = @"";
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
