//
//  HCRCampClusterGraphCell.m
//  UNHCR
//
//  Created by Sean Conrad on 10/4/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRCampClusterGraphCell.h"

@implementation HCRCampClusterGraphCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UIImageView *graphImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,
                                                                                    0,
                                                                                    CGRectGetWidth(self.bounds),
                                                                                    CGRectGetHeight(self.bounds))];
        graphImageView.image = [UIImage imageNamed:@"campcluster-graph"];
        graphImageView.contentMode = UIViewContentModeCenter;
    }
    return self;
}

@end
