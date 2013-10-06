//
//  HCRGraphCell.m
//  UNHCR
//
//  Created by Sean Conrad on 10/5/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRGraphCell.h"

@implementation HCRGraphCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UIImageView *graphImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,
                                                                                    0,
                                                                                    CGRectGetWidth(self.bounds),
                                                                                    CGRectGetHeight(self.bounds))];
        [self addSubview:graphImageView];
        
        graphImageView.image = [UIImage imageNamed:@"campcluster-graph"];
        graphImageView.contentMode = UIViewContentModeScaleAspectFit;
        
    }
    return self;
}

#pragma mark - Class Methods

+ (CGFloat)preferredHeightForGraphCell {
    return 200;
}

@end
