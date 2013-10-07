//
//  HCRCampClusterButtonListCell.m
//  UNHCR
//
//  Created by Sean Conrad on 10/5/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRButtonListCell.h"

////////////////////////////////////////////////////////////////////////////////

@interface HCRButtonListCell ()

@property (nonatomic, readonly) CGSize sharedButtonSize;
@property (nonatomic, readwrite) UIButton *listButton;

@end

////////////////////////////////////////////////////////////////////////////////

@implementation HCRButtonListCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

#pragma mark - Class Methods

+ (CGFloat)preferredCellHeight {
    return kSharedButtonHeight;
}

+ (CGFloat)preferredButtonPadding {
    return kYButtonPadding;
}

#pragma mark - Getters & Setters

- (CGSize)sharedButtonSize {
    return CGSizeMake(CGRectGetWidth(self.bounds),
                      kSharedButtonHeight);
}

- (void)setListButtonTitle:(NSString *)listButtonTitle {
    
    _listButtonTitle = listButtonTitle;
    
    [self.listButton removeFromSuperview];
    
    if (listButtonTitle) {
        
        self.listButton = [self _listCellButtonWithTitle:listButtonTitle];
        [self addSubview:self.listButton];
        
        self.listButton.center = CGPointMake(kXListOffset + CGRectGetMidX(self.listButton.bounds),
                                             CGRectGetMidY(self.bounds));
        
        // workaround; convenience after a refactor
        self.listButton.userInteractionEnabled = NO;
        
    }
    
}

#pragma mark - Private Methods

- (UIButton *)_listCellButtonWithTitle:(NSString *)titleString {
    
    return [UIButton buttonWithUNHCRTextStyleWithString:titleString
                                    horizontalAlignment:UIControlContentHorizontalAlignmentLeft
                                             buttonSize:self.sharedButtonSize
                                               fontSize:[NSNumber numberWithFloat:kSharedButtonFontSize]];
    
}

@end
