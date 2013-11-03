//
//  HCRTableTallyCell.m
//  UNHCR
//
//  Created by Sean Conrad on 11/3/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRTableTallyCell.h"

////////////////////////////////////////////////////////////////////////////////

@interface HCRTableTallyCell ()

@property (nonatomic, readonly) CGRect forwardImageFrame;

@end

////////////////////////////////////////////////////////////////////////////////

@implementation HCRTableTallyCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.forwardImage.image = [[UIImage imageNamed:@"tap-here"] colorImage:[UIColor UNHCRBlue]
                                                                 withBlendMode:kCGBlendModeNormal
                                                              withTransparency:YES];
        
        self.forwardImage.alpha = 0.4;
    }
    return self;
}

#pragma mark - Getters & Setters

- (CGRect)forwardImageFrame {
    
    return CGRectMake(CGRectGetWidth(self.contentView.bounds) - CGRectGetWidth(self.forwardImage.bounds) - self.trailingSpaceForContent,
                      0.5 * (CGRectGetHeight(self.contentView.bounds) - CGRectGetHeight(self.forwardImage.bounds)),
                      CGRectGetWidth(self.forwardImage.bounds),
                      CGRectGetHeight(self.forwardImage.bounds));
    
}

@end
