//
//  HCRCollectionCell.m
//  UNHCR
//
//  Created by Sean Conrad on 10/27/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRCollectionCell.h"

////////////////////////////////////////////////////////////////////////////////

static const CGFloat kPreferredIndent = 20.0;

static const CGFloat kDefaultCellHeight = 44.0;
static const CGFloat kAppDescriptionHeight = 210.0;

////////////////////////////////////////////////////////////////////////////////

@interface HCRCollectionCell ()

@property (nonatomic, readwrite) UIView *bottomLineView;

@end

////////////////////////////////////////////////////////////////////////////////

@implementation HCRCollectionCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor whiteColor];
        
        // bottom line
        static const CGFloat kLineHeight = 0.5;
        self.bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(kPreferredIndent,
                                                                       CGRectGetHeight(self.bounds) - kLineHeight,
                                                                       CGRectGetWidth(self.bounds) - kPreferredIndent,
                                                                       kLineHeight)];
        [self addSubview:self.bottomLineView];
        
        self.bottomLineView.backgroundColor = [UIColor tableDividerColor];
        
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.bottomLineView.hidden = NO;
}

#pragma mark - Class Methods

+ (CGFloat)preferredIndentForContent {
    return kPreferredIndent;
}

+ (CGSize)preferredSizeForCollectionView:(UICollectionView *)collectionView {
    return CGSizeMake(CGRectGetWidth(collectionView.bounds),
                      kDefaultCellHeight);
}

+ (CGSize)preferredSizeForAppDescriptionCollectionCellForCollectionView:(UICollectionView *)collectionView {
    return CGSizeMake(CGRectGetWidth(collectionView.bounds),
                      kAppDescriptionHeight);
}

#pragma mark - Public Methods

- (void)setBottomLineStatusForCollectionView:(UICollectionView *)collectionView atIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == [collectionView numberOfItemsInSection:indexPath.section] - 1) {
        self.bottomLineView.hidden = YES;
    }
    
}

@end
