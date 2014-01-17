//
//  HCRCollectionCell.m
//  UNHCR
//
//  Created by Sean Conrad on 10/27/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRCollectionCell.h"

////////////////////////////////////////////////////////////////////////////////

static const CGFloat kBottomLineHeight = 0.5;

static const CGFloat kPreferredIndent = 20.0;
static const CGFloat kPreferredTrailingSpace = 25.0;

static const CGFloat kDefaultCellHeight = 48.0;
static const CGFloat kAppDescriptionHeight = 210.0;

////////////////////////////////////////////////////////////////////////////////

@interface HCRCollectionCell ()

@property (nonatomic, readonly) CGRect bottomLineFrame;

@property (nonatomic, readwrite) UIView *bottomLineView;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;

@end

////////////////////////////////////////////////////////////////////////////////

@implementation HCRCollectionCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.defaultBackgroundColor = [UIColor whiteColor];
        self.contentView.backgroundColor = self.defaultBackgroundColor;
        
        self.highlightedColor = [UIColor UNHCRBlue];
        
        // set initial indent
        self.indentForContent = [HCRCollectionCell preferredIndentForContent];
        self.trailingSpaceForContent = [HCRCollectionCell preferredTrailingSpaceForContent];
        
        // bottom line
        self.bottomLineView = [[UIView alloc] initWithFrame:self.bottomLineFrame];
        [self addSubview:self.bottomLineView];
        
        self.bottomLineView.backgroundColor = [UIColor tableDividerColor];
        
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.contentView.backgroundColor = self.defaultBackgroundColor;
    
    self.bottomLineView.hidden = NO;
    
    self.processingAction = NO;
    
    [self.spinner removeFromSuperview];
    self.spinner = nil;
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.bottomLineView.frame = self.bottomLineFrame;
    
}

#pragma mark - Class Methods

+ (CGFloat)preferredIndentForContent {
    return kPreferredIndent;
}

+ (CGFloat)preferredTrailingSpaceForContent {
    return kPreferredTrailingSpace;
}

+ (CGSize)preferredSizeForCollectionView:(UICollectionView *)collectionView {
    return CGSizeMake(CGRectGetWidth(collectionView.bounds),
                      kDefaultCellHeight);
}

+ (CGSize)preferredSizeForAppDescriptionCollectionCellForCollectionView:(UICollectionView *)collectionView {
    return CGSizeMake(CGRectGetWidth(collectionView.bounds),
                      kAppDescriptionHeight);
}

#pragma mark - Getters & Setters

- (CGRect)bottomLineFrame {
    
    return CGRectMake(self.indentForContent,
                      CGRectGetHeight(self.bounds) - kBottomLineHeight,
                      CGRectGetWidth(self.bounds) - self.indentForContent,
                      kBottomLineHeight);
    
}

- (void)setProcessingAction:(BOOL)processingAction {
    
    _processingAction = processingAction;
    
    if (processingAction) {
        
        if (!self.spinner) {
            self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
            [self.contentView addSubview:self.spinner];
        }
        
        self.spinner.center = [self _centerForProcessingView];
        
        self.spinner.color = [UIColor UNHCRBlue];
        
        self.spinner.hidesWhenStopped = YES;
        [self.spinner startAnimating];
        
        [self.contentView bringSubviewToFront:self.spinner];
        
    } else {
        [self.spinner stopAnimating];
    }
    
}

- (void)setIndentForContent:(CGFloat)indentForContent {
    
    _indentForContent = indentForContent;
    
    self.bottomLineView.frame = self.bottomLineFrame;
    
}

#pragma mark - Public Methods

- (void)setBottomLineStatusForCollectionView:(UICollectionView *)collectionView atIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == [collectionView numberOfItemsInSection:indexPath.section] - 1) {
        self.bottomLineView.hidden = YES;
    }
    
}

#pragma mark - Private Methods

- (CGPoint)_centerForProcessingView {
    
    CGFloat xPosition;
    
    switch (self.processingViewPosition) {
        case HCRCollectionCellProcessingViewPositionLeft:
            xPosition = self.indentForContent + CGRectGetMidX(self.spinner.bounds) + [HCRCollectionCell preferredIndentForContent];
            break;
            
        case HCRCollectionCellProcessingViewPositionCenter:
            xPosition = CGRectGetMidX(self.contentView.bounds);
            break;
            
        case HCRCollectionCellProcessingViewPositionRight:
            xPosition = CGRectGetWidth(self.contentView.bounds) - CGRectGetMidX(self.spinner.bounds) - [HCRCollectionCell preferredIndentForContent];
            break;
    }
    
    return CGPointMake(xPosition,
                       CGRectGetMidY(self.contentView.bounds));
    
}

@end
