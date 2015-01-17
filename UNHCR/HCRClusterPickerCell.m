//
//  HCRClusterCollectionCell.m
//  UNHCR
//
//  Created by Sean Conrad on 10/2/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRClusterPickerCell.h"

////////////////////////////////////////////////////////////////////////////////

static const CGFloat kImageToTextRatio = 0.6;

static const CGFloat kDefaultItemSize = 93.0;

////////////////////////////////////////////////////////////////////////////////

@interface HCRClusterPickerCell ()

@property UILabel *clusterLabel;
@property UIImageView *clusterImageView;

@end

////////////////////////////////////////////////////////////////////////////////

@implementation HCRClusterPickerCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
//        self.backgroundColor = [[UIColor UNHCRBlue] colorWithAlphaComponent:0.5];
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.clusterDictionary = nil;
}

#pragma mark - Class Methods

+ (CGSize)preferredSizeForCollectionView:(UICollectionView *)collectionView {
    
    return CGSizeMake(kDefaultItemSize, kDefaultItemSize);
        
}

#pragma mark - Getters & Setters

- (void)setClusterDictionary:(NSDictionary *)clusterDictionary {
    
    _clusterDictionary = clusterDictionary;
    
    if ( clusterDictionary == nil ) {
        
        self.clusterImageView.image = nil;
        self.clusterLabel.text = nil;
        
        return;
    }
    
    // cluster image
    NSString *clusterImagePath = [clusterDictionary objectForKey:@"Image"];
    if ( !self.clusterImageView && clusterImagePath ) {
        
        CGRect clusterImageViewFrame = CGRectMake(0,
                                                  0,
                                                  CGRectGetWidth(self.bounds),
                                                  CGRectGetHeight(self.bounds) * kImageToTextRatio);
        
        self.clusterImageView = [[UIImageView alloc] initWithFrame:clusterImageViewFrame];
        [self addSubview:self.clusterImageView];
        
        self.clusterImageView.contentMode = UIViewContentModeScaleAspectFit;
        
    }
    
    self.clusterImageView.image = [[UIImage imageNamed:clusterImagePath] colorImage:[UIColor UNHCRBlue]
                                                                      withBlendMode:kCGBlendModeNormal
                                                                   withTransparency:YES];
    
    // cluster name
    NSString *clusterName = [clusterDictionary objectForKey:@"Name"];
    
    static const CGFloat kXPadding = 4;
    CGRect clusterLabelFrame = CGRectMake(kXPadding,
                                          CGRectGetHeight(self.bounds) * kImageToTextRatio,
                                          CGRectGetWidth(self.bounds) - 2 * kXPadding,
                                          CGRectGetHeight(self.bounds) * (1 - kImageToTextRatio));
    if ( !self.clusterLabel && clusterName ) {
        
        self.clusterLabel = [[UILabel alloc] initWithFrame:clusterLabelFrame];
        [self addSubview:self.clusterLabel];
        
        self.clusterLabel.font = [UIFont systemFontOfSize:13];
        
        self.clusterLabel.textColor = [UIColor darkGrayColor];
        self.clusterLabel.backgroundColor = [UIColor clearColor];
        
        self.clusterLabel.numberOfLines = 2;
        self.clusterLabel.textAlignment = NSTextAlignmentCenter;
        
    } else {
        self.clusterLabel.frame = clusterLabelFrame;
    }
    
    self.clusterLabel.text = clusterName;
    
    [self.clusterLabel sizeToFit];
    self.clusterLabel.center = CGPointMake(CGRectGetMidX(self.bounds),
                                           CGRectGetHeight(self.bounds) * kImageToTextRatio + CGRectGetMidY(self.clusterLabel.bounds) + 4);
    
}

@end
