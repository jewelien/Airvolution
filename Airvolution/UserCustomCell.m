//
//  ProfileCustomCell.m
//  Airvolution
//
//  Created by Julien Guanzon on 4/7/15.
//  Copyright (c) 2015 Julien Guanzon. All rights reserved.
//

#import "UserCustomCell.h"
#import "UIColor+Color.h"

@implementation UserCustomCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
        CGFloat profileImageWidth = 60;
        self.viewForImage = [[UIImageView alloc] initWithFrame:CGRectMake(25, 10, profileImageWidth, 60)];
        self.viewForImage.backgroundColor = [UIColor lightGrayColor];
//        self.viewForImage.backgroundColor = [UIColor airvolutionRed];
        self.viewForImage.layer.cornerRadius = 10;
        self.viewForImage.clipsToBounds = YES;
        [self.contentView addSubview:self.viewForImage];
        
        self.usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(profileImageWidth + 35, 11, screenWidth - profileImageWidth - 85, 30)];
        self.usernameLabel.font = [UIFont systemFontOfSize:25];
//        self.usernameLabel.backgroundColor = [UIColor orangeColor];
        [self.contentView addSubview:self.usernameLabel];
        
        self.pointsLabel = [[UILabel alloc] initWithFrame:CGRectMake(profileImageWidth + 35, 47, 150, 20)];
//        self.pointsLabel.backgroundColor = [UIColor orangeColor];
        [self.contentView addSubview:self.pointsLabel];
        
        self.editButton = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth - 25 - 7.5, (self.contentView.frame.size.height / 2) + 7.5, 15, 15)];
//        self.editButton.backgroundColor = [UIColor yellowColor];
        [self.editButton setImage:[UIImage imageNamed:@"editUser"] forState:UIControlStateNormal];
        [self.contentView addSubview:self.editButton];
        
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
