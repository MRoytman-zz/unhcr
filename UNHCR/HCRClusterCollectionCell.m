//
//  HCRClusterCollectionCell.m
//  UNHCR
//
//  Created by Sean Conrad on 10/2/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRClusterCollectionCell.h"

////////////////////////////////////////////////////////////////////////////////

static const CGFloat kImageToTextRatio = 0.6;

////////////////////////////////////////////////////////////////////////////////

@interface HCRClusterCollectionCell ()

@property UILabel *clusterLabel;
@property UIImageView *clusterImageView;

@property UIButton *disclosureButton;

@end

////////////////////////////////////////////////////////////////////////////////

@implementation HCRClusterCollectionCell

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

#pragma mark - Getters & Setters

- (void)setClusterDictionary:(NSDictionary *)clusterDictionary {
    
    _clusterDictionary = clusterDictionary;
    
    if ( clusterDictionary == nil ) {
        
        [self.clusterImageView removeFromSuperview];
        self.clusterImageView = nil;
        
        [self.clusterLabel removeFromSuperview];
        self.clusterLabel = nil;
        
        [self.disclosureButton removeFromSuperview];
        self.disclosureButton = nil;
        
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
    if ( !self.clusterLabel && clusterName ) {
        
        CGFloat xPadding = 4;
        CGRect clusterLabelFrame = CGRectMake(xPadding,
                                              CGRectGetHeight(self.bounds) * kImageToTextRatio,
                                              CGRectGetWidth(self.bounds) - 2 * xPadding,
                                              CGRectGetHeight(self.bounds) * (1 - kImageToTextRatio));
        
        self.clusterLabel = [[UILabel alloc] initWithFrame:clusterLabelFrame];
        [self addSubview:self.clusterLabel];
        
        self.clusterLabel.font = [UIFont systemFontOfSize:13];
        
        self.clusterLabel.textColor = [UIColor darkGrayColor];
        self.clusterLabel.backgroundColor = [UIColor clearColor];
        
        self.clusterLabel.numberOfLines = 2;
        self.clusterLabel.textAlignment = NSTextAlignmentCenter;
        
    }
    
    self.clusterLabel.text = clusterName;
    
    [self.clusterLabel sizeToFit];
    self.clusterLabel.center = CGPointMake(CGRectGetMidX(self.bounds),
                                           CGRectGetHeight(self.bounds) * kImageToTextRatio + CGRectGetMidY(self.clusterLabel.bounds) + 4);
    
    if ([HCRDataSource globalAlertsData].count > 0) {
        
        BOOL showDisclosure = NO;
        
        for (NSDictionary *alertsDictionary in [HCRDataSource globalAlertsData]) {
            
            NSString *alertCluster = [alertsDictionary objectForKey:@"Cluster" ofClass:@"NSString"];
            if ([alertCluster isEqualToString:clusterName]) {
                showDisclosure = YES;
                break;
            }
            
        }
        
        if (showDisclosure) {
            
            if (!self.disclosureButton) {
                self.disclosureButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
                [self addSubview:self.disclosureButton];
                
                self.disclosureButton.tintColor = [UIColor redColor];
                self.disclosureButton.userInteractionEnabled = NO;
            }
            
            self.disclosureButton.center = CGPointMake(CGRectGetMaxX(self.bounds) - CGRectGetMidX(self.disclosureButton.bounds),
                                                       CGRectGetMidY(self.disclosureButton.bounds));
        }
        
    }
    
}

@end
