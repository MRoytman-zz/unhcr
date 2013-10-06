//
//  HCRCampClusterButtonListCell.m
//  UNHCR
//
//  Created by Sean Conrad on 10/5/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRCampClusterButtonListCell.h"

////////////////////////////////////////////////////////////////////////////////

@interface HCRCampClusterButtonListCell ()

@property (nonatomic, readonly) CGSize sharedButtonSize;

@end

////////////////////////////////////////////////////////////////////////////////

@implementation HCRCampClusterButtonListCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)layoutSubviews {
    
    CGFloat bottomY = kYListOffset;
    
    for (UIButton *button in self.buttonsArray) {
        
        BOOL addPadding = ( [self.buttonsArray indexOfObject:button] != 0 );
        CGFloat padding = (addPadding) ? kYButtonPadding : 0;
        button.center = CGPointMake(kXListOffset + CGRectGetMidX(button.bounds),
                                    bottomY + padding + CGRectGetMidY(button.bounds));
        
        bottomY = CGRectGetMaxY(button.frame);
        
    }
    
}

#pragma mark - Class Methods

+ (CGFloat)preferredCellHeightForNumberOfButtons:(NSInteger)numberOfButtons {
    
    NSParameterAssert(numberOfButtons > 0);
    
    return kYListOffset + numberOfButtons * (kSharedButtonHeight + kYButtonPadding) - kYButtonPadding + kYListOffset;
    
}

#pragma mark - Getters & Setters

- (CGSize)sharedButtonSize {
    return CGSizeMake(kLargeButtonWidth,
                      kSharedButtonHeight);
}

#pragma mark - Public Methods

- (UIButton *)buttonListCellButtonWithTitle:(NSString *)titleString {
    
    return [UIButton buttonWithUNHCRTextStyleWithString:titleString
                                    horizontalAlignment:UIControlContentHorizontalAlignmentLeft
                                             buttonSize:self.sharedButtonSize
                                               fontSize:[NSNumber numberWithFloat:kSharedButtonFontSize]];
    
}

@end
