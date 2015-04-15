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

        
        self.viewForImage = [[UIImageView alloc] initWithFrame:CGRectMake(50, 10, 60, 60)];
        self.viewForImage.backgroundColor = [UIColor lightGrayColor];
        self.viewForImage.layer.cornerRadius = 10;
        self.viewForImage.clipsToBounds = YES;
        [self.contentView addSubview:self.viewForImage];
        
        
        self.usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(125, 11, 150, 30)];
        self.usernameLabel.font = [UIFont systemFontOfSize:25];
//                    self.usernameLabel.backgroundColor = [UIColor orangeColor];
        [self.contentView addSubview:self.usernameLabel];
        
        self.pointsLabel = [[UILabel alloc] initWithFrame:CGRectMake(125, 47, 150, 20)];
//                    self.pointsLabel.backgroundColor = [UIColor orangeColor];
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
