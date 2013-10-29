//
//  HCRTableCell.m
//  UNHCR
//
//  Created by Sean Conrad on 10/28/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRTableCell.h"

////////////////////////////////////////////////////////////////////////////////

@interface HCRTableCell ()

@property (nonatomic, readwrite) UIImageView *badgeImageView;

@end

////////////////////////////////////////////////////////////////////////////////

@implementation HCRTableCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

@end