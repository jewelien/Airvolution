//
//  ProfileCustomCell.m
//  Airvolution
//
//  Created by Julien Guanzon on 4/7/15.
//  Copyright (c) 2015 Julien Guanzon. All rights reserved.
//

#import "UserCustomCell.h"

@implementation UserCustomCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
//        UIImageView *imageView = [[UIImageView alloc] init];
//        imageView.image = [UIImage imageNamed:@"compass"];
        self.imageView.image = [UIImage imageNamed:@"compass"];
        self.imageView.backgroundColor = [UIColor redColor];
        [self.contentView addSubview:self.imageView];
        
//        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 10, 60, 60)];
//        imageView.image = [UIImage imageNamed:@"compass"];
//        imageView.backgroundColor = [UIColor lightGrayColor];
//        [self.contentView addSubview:imageView];
        
        self.usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 15, 200, 20)];
//                    label.backgroundColor = [UIColor orangeColor];
        [self.contentView addSubview:self.usernameLabel];
        
        self.pointsLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 40, 150, 20)];
//                    label.backgroundColor = [UIColor orangeColor];
        [self.contentView addSubview:self.pointsLabel];
        
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
