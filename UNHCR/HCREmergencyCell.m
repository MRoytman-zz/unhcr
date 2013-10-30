//
//  HCRAlertCell.m
//  UNHCR
//
//  Created by Sean Conrad on 10/7/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCREmergencyCell.h"

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

@interface HCREmergencyCell ()

@property UILabel *fromLabel;
@property UILabel *locationClusterLabel;
@property UILabel *messageLabel;

@end

////////////////////////////////////////////////////////////////////////////////

@implementation HCREmergencyCell

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
    self.emergencyDictionary = nil;
}

- (void)layoutSubviews {
    
    static const CGFloat kMultiLineLabelHeight = 55.0;
    static const CGFloat kOneLineLabelHeight = 20.0;
    static const CGFloat kYLabelPadding = 0.0;
    static const CGFloat kLabelFontSize = 14.0;
    
    CGFloat sharedLabelWidth = CGRectGetWidth(self.contentView.bounds) - 2 * self.indentForContent;
    
    // LOCATION
    if (self.showLocation) {
        if (!self.locationClusterLabel) {
            CGRect locationFrame = CGRectMake(self.indentForContent,
                                              0,
                                              sharedLabelWidth,
                                              kOneLineLabelHeight);
            self.locationClusterLabel = [[UILabel alloc] initWithFrame:locationFrame];
            
            [self.contentView addSubview:self.locationClusterLabel];
            
            self.locationClusterLabel.font = [UIFont helveticaNeueFontOfSize:kLabelFontSize];
            self.locationClusterLabel.textAlignment = NSTextAlignmentLeft;
            self.locationClusterLabel.textColor = [UIColor redColor];
        }
        
        NSString *alertCountry = [self.emergencyDictionary objectForKey:@"Country" ofClass:@"NSString"];
        NSString *alertCamp = [self.emergencyDictionary objectForKey:@"Camp" ofClass:@"NSString"];
        NSString *alertCluster = [self.emergencyDictionary objectForKey:@"Cluster" ofClass:@"NSString"];
        NSString *locationString = [NSString stringWithFormat:@"%@ > %@ > %@",
                                    alertCountry,
                                    alertCamp,
                                    alertCluster];
        
        self.locationClusterLabel.text = locationString;
    }
    
    // ALERT
    if (!self.messageLabel) {
        CGRect alertFrame = CGRectMake(self.indentForContent,
                                       (self.showLocation) ? CGRectGetMaxY(self.locationClusterLabel.frame) + kYLabelPadding : 0,
                                       sharedLabelWidth,
                                       kMultiLineLabelHeight);
        self.messageLabel = [[UILabel alloc] initWithFrame:alertFrame];
        [self.contentView addSubview:self.messageLabel];
        
        self.messageLabel.font = [UIFont helveticaNeueBoldFontOfSize:kLabelFontSize];
        self.messageLabel.textAlignment = NSTextAlignmentLeft;
        self.messageLabel.textColor = [UIColor darkGrayColor];
        self.messageLabel.numberOfLines = 3;
    }
    
    self.messageLabel.text = [self.emergencyDictionary objectForKey:@"Alert" ofClass:@"NSString"];
    
    // FROM
    if (!self.fromLabel) {
        CGRect fromFrame = CGRectMake(self.indentForContent,
                                      CGRectGetMaxY(self.messageLabel.frame) + kYLabelPadding,
                                      sharedLabelWidth,
                                      kOneLineLabelHeight);
        self.fromLabel = [[UILabel alloc] initWithFrame:fromFrame];
        [self.contentView addSubview:self.fromLabel];
        
        self.fromLabel.font = [UIFont helveticaNeueLightFontOfSize:kLabelFontSize];
        self.fromLabel.textAlignment = NSTextAlignmentLeft;
        self.fromLabel.textColor = [UIColor UNHCRBlue];
        
        self.fromLabel.adjustsFontSizeToFitWidth = YES;
    }
    
    NSDictionary *contactDictionary = [self.emergencyDictionary objectForKey:@"Contact" ofClass:@"NSDictionary"];
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

- (void)setEmergencyDictionary:(NSDictionary *)alertDictionary {
    _emergencyDictionary = alertDictionary;
    [self setNeedsLayout];
    
}

- (void)setShowLocation:(BOOL)showLocation {
    _showLocation = showLocation;
    [self setNeedsLayout];
}

@end
