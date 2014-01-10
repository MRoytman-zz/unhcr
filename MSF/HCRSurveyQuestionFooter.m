//
//  HCRSurveyQuestionFooter.m
//  UNHCR
//
//  Created by Sean Conrad on 1/6/14.
//  Copyright (c) 2014 Sean Conrad. All rights reserved.
//

#import "HCRSurveyQuestionFooter.h"

////////////////////////////////////////////////////////////////////////////////

@interface HCRSurveyQuestionFooter ()

@property UIImageView *msfImage;

@end

////////////////////////////////////////////////////////////////////////////////


@implementation HCRSurveyQuestionFooter

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.msfImage = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:self.msfImage];
        
        self.msfImage.image = [UIImage imageNamed:@"msf-logo-medium"];
        self.msfImage.contentMode = UIViewContentModeScaleAspectFit;
        
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.msfImage.hidden = YES;
    self.showMSFLogo = NO;
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.msfImage.hidden = !self.showMSFLogo;
    self.msfImage.frame = UIEdgeInsetsInsetRect(self.bounds, UIEdgeInsetsMake(30, 10, 20, 10));
    
}

#pragma mark - Class Methods

+ (CGSize)preferredFooterSizeForCollectionView:(UICollectionView *)collectionView {
    return CGSizeMake(CGRectGetWidth(collectionView.bounds),
                      140);
}

#pragma mark - Getters & Setters

- (void)setShowMSFLogo:(BOOL)showMSFLogo {
    _showMSFLogo = showMSFLogo;
    [self setNeedsLayout];
}

@end
