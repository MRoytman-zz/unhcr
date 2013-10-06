//
//  HCRFlowLayout.m
//  UNHCR
//
//  Created by Sean Conrad on 10/2/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRFlowLayout.h"

////////////////////////////////////////////////////////////////////////////////

const CGFloat kHeaderHeight = 44.0;
const CGFloat kFooterHeight = 30.0;
const CGFloat kFooterHeightForGraphCell = 50.0;

////////////////////////////////////////////////////////////////////////////////

@interface HCRFlowLayout ()

@property (nonatomic, readwrite) BOOL displayHeader;
@property (nonatomic, readwrite) BOOL displayFooter;

@end

////////////////////////////////////////////////////////////////////////////////

@implementation HCRFlowLayout

#pragma mark - Public Methods

+ (CGSize)preferredHeaderSizeForCollectionView:(UICollectionView *)collectionView {
    return CGSizeMake(CGRectGetWidth(collectionView.bounds),
                      kHeaderHeight);
}

+ (CGSize)preferredFooterSizeForCollectionView:(UICollectionView *)collectionView {
    return CGSizeMake(CGRectGetWidth(collectionView.bounds),
                      kFooterHeight);
}

+ (CGSize)preferredFooterSizeForGraphCellInCollectionView:(UICollectionView *)collectionView {
    return CGSizeMake(CGRectGetWidth(collectionView.bounds),
                      kFooterHeightForGraphCell);
}

- (void)setDisplayHeader:(BOOL)displayHeader withSize:(CGSize)size {
    
    _displayHeader = displayHeader;
    
    if (displayHeader) {
        self.headerReferenceSize = size;
    } else {
        self.headerReferenceSize = CGSizeZero;
    }
    
}

- (void)setDisplayFooter:(BOOL)displayFooter withSize:(CGSize)size {
    
    _displayFooter = displayFooter;
    
    if (displayFooter) {
        self.footerReferenceSize = size;
    } else {
        self.footerReferenceSize = CGSizeZero;
    }
    
}

@end
