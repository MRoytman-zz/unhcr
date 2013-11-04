//
//  HCRHeaderTallyView.m
//  UNHCR
//
//  Created by Sean Conrad on 11/3/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRHeaderTallyView.h"

////////////////////////////////////////////////////////////////////////////////

static const CGFloat kFontSizeTitle = 19.0;
static const CGFloat kFontSizeSubtitle = 15.0;

static const CGFloat kYLabelOffset = 16.0;
static const CGFloat kYLabelTrailing = 8.0;

static const CGFloat kXCustomIndent = 20.0;
static const CGFloat kXLabelTrailing = 10.0;

////////////////////////////////////////////////////////////////////////////////

@interface HCRHeaderTallyView ()

@property (nonatomic, readonly) CGRect frameForHeaderLabel;

@property UILabel *headerLabel;

@end

////////////////////////////////////////////////////////////////////////////////

@implementation HCRHeaderTallyView

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
    
    self.headerLabel.frame = self.frameForHeaderLabel;
}

#pragma mark - Class Methods

+ (CGSize)sizeForTallyHeaderInCollectionView:(UICollectionView *)collectionView withStringArray:(NSArray *)stringArray {
    
    CGFloat height = kYLabelOffset + kYLabelTrailing;
    
    CGSize boundingSize = CGSizeMake(CGRectGetWidth(collectionView.bounds),
                                     CGRectGetHeight(collectionView.bounds));
    
    height += [self _heightForStringArray:stringArray withBoundingSize:boundingSize];
    
    return CGSizeMake(CGRectGetWidth(collectionView.bounds),
                      height);
    
}

#pragma mark - Getters & Setters

- (CGRect)frameForHeaderLabel {
    
    CGFloat headerLabelHeight = [HCRHeaderTallyView _heightForStringArray:self.stringArray withBoundingSize:self.bounds.size];
    
    return CGRectMake(kXCustomIndent,
                      CGRectGetHeight(self.bounds) - headerLabelHeight - kYLabelTrailing,
                      CGRectGetWidth(self.bounds) - kXCustomIndent - kXLabelTrailing,
                      headerLabelHeight);
}

- (void)setStringArray:(NSArray *)stringArray {
    
    _stringArray = stringArray;
    
    if (!stringArray) {
        [self.headerLabel removeFromSuperview];
        self.headerLabel = nil;
    } else if (stringArray) {
        
        self.headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self addSubview:self.headerLabel];
        
        self.headerLabel.numberOfLines = 2;
        self.headerLabel.backgroundColor = [UIColor tableBackgroundColor];
        
    }
    
    NSMutableAttributedString *attributedString = [NSMutableAttributedString new];
    
    for (NSString *string in self.stringArray) {
        
        BOOL firstString = ([self.stringArray indexOfObject:string] == 0);
        
        if (!firstString) {
            [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
        }
        
        NSDictionary *attributes = (firstString) ? [HCRHeaderTallyView _attributesForHeaderTitle] : [HCRHeaderTallyView _attributesForHeaderSubtitle];
        
        NSAttributedString *oneLiner = [[NSAttributedString alloc] initWithString:string attributes:attributes];
        
        [attributedString appendAttributedString:oneLiner];
        
    }
    
    self.headerLabel.attributedText = attributedString;
    
    [self setNeedsLayout];
    
}

#pragma mark - Private Methods

+ (CGFloat)_heightForStringArray:(NSArray *)stringArray withBoundingSize:(CGSize)boundingSize {
    
    CGFloat height = 0;
    
    for (NSString *string in stringArray) {
        
        NSDictionary *attributes = ([stringArray indexOfObject:string] == 0) ? [HCRHeaderTallyView _attributesForHeaderTitle] : [HCRHeaderTallyView _attributesForHeaderSubtitle];
        
        CGSize labelSize = [string sizeforMultiLineStringWithBoundingSize:boundingSize
                                                           withAttributes:attributes
                                                                  rounded:YES];
        
        height += labelSize.height;
        
    }
    
    return height;
    
}

+ (NSDictionary *)_attributesForHeaderTitle {
    
    NSMutableDictionary *attributes = [HCRHeaderTallyView _attributesWithFont:[UIFont systemFontOfSize:kFontSizeTitle]];
    
    return attributes;
    
}

+ (NSDictionary *)_attributesForHeaderSubtitle {
    
    NSMutableDictionary *attributes = [HCRHeaderTallyView _attributesWithFont:[UIFont systemFontOfSize:kFontSizeSubtitle]];
    
    return attributes;
    
}

+ (NSMutableDictionary *)_attributesWithFont:(UIFont *)font {
    
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.alignment = NSTextAlignmentLeft;
    
    return @{NSFontAttributeName: font,
             NSForegroundColorAttributeName: [UIColor tableHeaderTitleColor]}.mutableCopy;
}

@end
