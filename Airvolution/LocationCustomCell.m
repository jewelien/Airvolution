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
        
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, self.contentView.frame.size.width / 2 + 15, 20)];
//        self.nameLabel.backgroundColor = [UIColor grayColor];
        [self.contentView addSubview:self.nameLabel];
        
        self.dateLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.contentView.frame.size.width / 2) + 35, 10, 110, 15)];
//        self.dateLabel.backgroundColor = [UIColor orangeColor];
        self.dateLabel.textColor = [UIColor lightGrayColor];
        self.dateLabel.textAlignment = NSTextAlignmentRight;
        self.dateLabel.font = [UIFont systemFontOfSize:10 weight:5];
        [self.contentView addSubview:self.dateLabel];
        
        self.addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 30, self.contentView.frame.size.width - 30, 15)];
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
