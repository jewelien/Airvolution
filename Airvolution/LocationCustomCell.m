//
//  LocationCustomCell.m
//  Airvolution
//
//  Created by Julien Guanzon on 4/8/15.
//  Copyright (c) 2015 Julien Guanzon. All rights reserved.
//

#import "LocationCustomCell.h"

@implementation LocationCustomCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;

        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, screenWidth - 130, 25)];
//        self.nameLabel.backgroundColor = [UIColor grayColor];
        self.nameLabel.font = [UIFont systemFontOfSize:20];
        [self.contentView addSubview:self.nameLabel];
        
        self.dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth - 115, 10, 100, 15)];
//        self.dateLabel.backgroundColor = [UIColor orangeColor];
        self.dateLabel.textColor = [UIColor lightGrayColor];
        self.dateLabel.textAlignment = NSTextAlignmentRight;
        self.dateLabel.font = [UIFont systemFontOfSize:10 weight:5];
        [self.contentView addSubview:self.dateLabel];
        
        self.addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 35, screenWidth - 30, 15)];
//        self.addressLabel.backgroundColor = [UIColor grayColor];
        self.addressLabel.textColor = [UIColor grayColor];
        self.addressLabel.textAlignment = NSTextAlignmentCenter;
        self.addressLabel.font = [UIFont systemFontOfSize:10 weight:10];
        self.addressLabel.numberOfLines = 0;
        [self.contentView addSubview:self.addressLabel];
        
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
