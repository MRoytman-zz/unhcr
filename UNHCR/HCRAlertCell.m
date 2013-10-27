//
//  HCRAlertCell.m
//  UNHCR
//
//  Created by Sean Conrad on 10/7/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRAlertCell.h"

////////////////////////////////////////////////////////////////////////////////

//  @{@"Country": @"Iraq",
//    @"Camp": @"Domiz",
//    @"Cluster": @"Health",
//    @"Sender": @{@"Name": @"Edrees Nabi Salih",
//                 @"Email": @"edress.salih@qandil.org",
//                 @"Cluster": @"Education"},
//    @"Alert": @"Half the kids I work with are suffering from severe diarrhea. Are you guys aware of this?",
//    @"Severity": @1}

////////////////////////////////////////////////////////////////////////////////

@interface HCRAlertCell ()

@property UILabel *fromLabel;
@property UILabel *locationClusterLabel;
@property UILabel *alertLabel;

@end

////////////////////////////////////////////////////////////////////////////////

@implementation HCRAlertCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.alertDictionary = nil;
}

- (void)layoutSubviews {
    
    static const CGFloat kTwoLineLabelHeight = 35.0;
    static const CGFloat kOneLineLabelHeight = 20.0;
    static const CGFloat kYLabelPadding = 0.0;
    static const CGFloat kLabelFontSize = 14.0;
    static const CGFloat kXLabelOffset = 8.0;
    
    CGFloat sharedLabelWidth = CGRectGetWidth(self.contentView.bounds) - 2 * kXLabelOffset;
    
    // LOCATION
    if (self.showLocation) {
        if (!self.locationClusterLabel) {
            CGRect locationFrame = CGRectMake(kXLabelOffset,
                                              0,
                                              sharedLabelWidth,
                                              kOneLineLabelHeight);
            self.locationClusterLabel = [[UILabel alloc] initWithFrame:locationFrame];
            
            [self.contentView addSubview:self.locationClusterLabel];
            
            self.locationClusterLabel.font = [UIFont helveticaNeueFontOfSize:kLabelFontSize];
            self.locationClusterLabel.textAlignment = NSTextAlignmentLeft;
            self.locationClusterLabel.textColor = [UIColor redColor];
        }
        
        NSString *alertCountry = [self.alertDictionary objectForKey:@"Country" ofClass:@"NSString"];
        NSString *alertCamp = [self.alertDictionary objectForKey:@"Camp" ofClass:@"NSString"];
        NSString *alertCluster = [self.alertDictionary objectForKey:@"Cluster" ofClass:@"NSString"];
        NSString *locationString = [NSString stringWithFormat:@"%@ > %@ > %@",
                                    alertCountry,
                                    alertCamp,
                                    alertCluster];
        
        self.locationClusterLabel.text = locationString;
    }
    
    // ALERT
    if (!self.alertLabel) {
        CGRect alertFrame = CGRectMake(kXLabelOffset,
                                       (self.showLocation) ? CGRectGetMaxY(self.locationClusterLabel.frame) + kYLabelPadding : 0,
                                       sharedLabelWidth,
                                       kTwoLineLabelHeight);
        self.alertLabel = [[UILabel alloc] initWithFrame:alertFrame];
        [self.contentView addSubview:self.alertLabel];
        
        self.alertLabel.font = [UIFont helveticaNeueBoldFontOfSize:kLabelFontSize];
        self.alertLabel.textAlignment = NSTextAlignmentLeft;
        self.alertLabel.textColor = [UIColor darkGrayColor];
        self.alertLabel.numberOfLines = 2;
    }
    
    self.alertLabel.text = [self.alertDictionary objectForKey:@"Alert" ofClass:@"NSString"];
    
    // FROM
    if (!self.fromLabel) {
        CGRect fromFrame = CGRectMake(kXLabelOffset,
                                      CGRectGetMaxY(self.alertLabel.frame) + kYLabelPadding,
                                      sharedLabelWidth,
                                      kOneLineLabelHeight);
        self.fromLabel = [[UILabel alloc] initWithFrame:fromFrame];
        [self.contentView addSubview:self.fromLabel];
        
        self.fromLabel.font = [UIFont helveticaNeueLightFontOfSize:kLabelFontSize];
        self.fromLabel.textAlignment = NSTextAlignmentLeft;
        self.fromLabel.textColor = [UIColor UNHCRBlue];
        
        self.fromLabel.adjustsFontSizeToFitWidth = YES;
    }
    
    NSDictionary *contactDictionary = [self.alertDictionary objectForKey:@"Contact" ofClass:@"NSDictionary"];
    NSString *name = [contactDictionary objectForKey:@"Name" ofClass:@"NSString"];
//    NSString *cluster = [contactDictionary objectForKey:@"Cluster" ofClass:@"NSString"];
    NSString *email = [contactDictionary objectForKey:@"Email" ofClass:@"NSString"];
    self.fromLabel.text = [NSString stringWithFormat:@"%@ | %@",
                           name,
//                           cluster,
                           email];
    
}

#pragma mark - Class Methods

+ (CGFloat)preferredCellHeight {
    return 95.0;
}

+ (CGFloat)preferredCellHeightWithoutLocation {
    return 75.0;
}

#pragma mark - Getters & Setters

- (void)setAlertDictionary:(NSDictionary *)alertDictionary {
    _alertDictionary = alertDictionary;
    [self setNeedsLayout];
    
}

- (void)setShowLocation:(BOOL)showLocation {
    _showLocation = showLocation;
    [self setNeedsLayout];
}

@end
