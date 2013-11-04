//
//  HCRInformationCell.m
//  UNHCR
//
//  Created by Sean Conrad on 11/1/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRInformationCell.h"

////////////////////////////////////////////////////////////////////////////////

static const CGFloat kYOffset = 8.0;
static const CGFloat kYTrailing = kYOffset;

static const CGFloat kXOffset = 20.0; // TODO: make this dynamic to the source of self.indentForContent
static const CGFloat kXTrailing = kYOffset;

static const CGFloat kYLabelPadding = 4.0;

static const CGFloat kFontSizeDefault = 16.0;
static const CGFloat kFontSizeLarge = 17.0;

////////////////////////////////////////////////////////////////////////////////

@implementation HCRInformationCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // clear subviews
    // TODO: find a better way to handle this; no cachine = bad performance
    for (UIView *subview in self.contentView.subviews) {
        [subview removeFromSuperview];
    }
    
    // make subviews
    UILabel *lastLabel;
    
    for (NSString *string in self.stringArray) {
        
        NSUInteger index = [self.stringArray indexOfObject:string];
        
        CGSize boundingSize = [HCRInformationCell _boundingSizeWithCellSize:self.contentView.bounds.size];
        CGSize stringSize = [string sizeforMultiLineStringWithBoundingSize:boundingSize
                                                withFont:[HCRInformationCell _preferredFontForTextAtIndex:index]
                                                 rounded:YES];
        
        CGRect labelFrame = CGRectMake(self.indentForContent,
                                       (lastLabel) ? CGRectGetMaxY(lastLabel.frame) + kYLabelPadding : kYOffset,
                                       stringSize.width,
                                       stringSize.height);
        
        UILabel *stringLabel = [[UILabel alloc] initWithFrame:labelFrame];
        [self.contentView addSubview:stringLabel];
        
        stringLabel.text = string;
        stringLabel.font = [HCRInformationCell _preferredFontForTextAtIndex:index];
        
        stringLabel.numberOfLines = 0;
        
        lastLabel = stringLabel;
        
    }
    
}

#pragma mark - Class Methods

+ (CGSize)sizeForItemInCollectionView:(UICollectionView *)collectionView withStringArray:(NSArray *)stringArray {
    
    CGFloat requiredHeight = kYOffset;
    
    CGSize boundingSize = [HCRInformationCell _boundingSizeWithCellSize:CGSizeMake(CGRectGetWidth(collectionView.bounds),
                                                                                   HUGE_VALF)];
    
    for (NSString *string in stringArray) {
        CGSize messageSize = [string sizeforMultiLineStringWithBoundingSize:boundingSize
                                                 withFont:[HCRInformationCell _preferredFontForTextAtIndex:[stringArray indexOfObject:string]]
                                                  rounded:YES];
        
        requiredHeight += messageSize.height + kYLabelPadding;
        
    }
    
    requiredHeight -= kYLabelPadding; // remove last label padding - this is probably most performant?
    requiredHeight += kYTrailing;

    return CGSizeMake(CGRectGetWidth(collectionView.bounds),
                      requiredHeight);
    
}

+ (CGSize)preferredSizeForCollectionView:(UICollectionView *)collectionView {
    NSAssert(NO, @"Size of cell must be dynamic!");
    return CGSizeZero;
}

#pragma mark - Getters & Setters

- (void)setStringArray:(NSArray *)stringArray {
    _stringArray = stringArray;
    
    [self setNeedsLayout];
}

#pragma mark - Private Methods

+ (UIFont *)_preferredFontForTextAtIndex:(NSUInteger)index {

    return (index == 0) ? [UIFont boldSystemFontOfSize:kFontSizeLarge] : [UIFont systemFontOfSize:kFontSizeDefault];
}

+ (CGSize)_boundingSizeWithCellSize:(CGSize)cellSize {
    return CGSizeMake(cellSize.width - kXOffset - kXTrailing,
                      cellSize.height);
}

@end
