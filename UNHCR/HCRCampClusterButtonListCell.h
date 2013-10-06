//
//  HCRCampClusterButtonListCell.h
//  UNHCR
//
//  Created by Sean Conrad on 10/5/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import <UIKit/UIKit.h>

////////////////////////////////////////////////////////////////////////////////

static const CGFloat kLargeButtonWidth = 200.0;
static const CGFloat kSharedButtonHeight = 40.0;

static const CGFloat kSharedButtonFontSize = 23.0;

static const CGFloat kXListOffset = 20;
static const CGFloat kYListOffset = 12;
static const CGFloat kYButtonPadding = 10;

////////////////////////////////////////////////////////////////////////////////

@interface HCRCampClusterButtonListCell : UICollectionViewCell

@property (nonatomic, strong) NSMutableArray *buttonsArray;

+ (CGFloat)preferredCellHeightForNumberOfButtons:(NSInteger)numberOfButtons;
- (UIButton *)buttonListCellButtonWithTitle:(NSString *)titleString;

@end
