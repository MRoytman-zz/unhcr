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
    
    // TODO: refactor - see HCRTableCell
    
    static const CGFloat kThreeLabelHeight = 55.0;
    static const CGFloat kTwoLineLabelHeight = 35.0;
    static const CGFloat kOneLineLabelHeight = 20.0;
    static const CGFloat kYLabelPadding = 0.0;
    static const CGFloat kYLabelOffset = 12.0;
    static const CGFloat kLabelFontSize = 14.0;
    
    CGFloat sharedLabelWidth = CGRectGetWidth(self.contentView.bounds) - 2 * self.indentForContent;
    
    // LOCATION
    if (!self.locationClusterLabel) {
        CGRect locationFrame = CGRectMake(self.indentForContent,
                                          kYLabelOffset,
                                          sharedLabelWidth,
                                          kOneLineLabelHeight);
        self.locationClusterLabel = [[UILabel alloc] initWithFrame:locationFrame];
        
        [self.contentView addSubview:self.locationClusterLabel];
        
        self.locationClusterLabel.font = [UIFont helveticaNeueFontOfSize:kLabelFontSize];
        self.locationClusterLabel.textAlignment = NSTextAlignmentLeft;
        self.locationClusterLabel.textColor = [UIColor redColor];
        self.locationClusterLabel.numberOfLines = 1;
        self.locationClusterLabel.textAlignment = NSTextAlignmentLeft;
    }
    
    NSString *targetTime = [self.emergencyDictionary objectForKey:@"Time" ofClass:@"NSString"];
    NSString *locationString = [NSString stringWithFormat:@"%@",
                                targetTime];
    
    self.locationClusterLabel.text = locationString;

    
    // MESSAGE
    if (!self.messageLabel) {
        CGRect alertFrame = CGRectMake(self.indentForContent,
                                       CGRectGetMaxY(self.locationClusterLabel.frame) + kYLabelPadding,
                                       sharedLabelWidth,
                                       kThreeLabelHeight);
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
                                      kTwoLineLabelHeight);
        self.fromLabel = [[UILabel alloc] initWithFrame:fromFrame];
        [self.contentView addSubview:self.fromLabel];
        
        self.fromLabel.font = [UIFont helveticaNeueLightFontOfSize:kLabelFontSize];
        self.fromLabel.textAlignment = NSTextAlignmentRight;
        self.fromLabel.textColor = [UIColor UNHCRBlue];
        
        self.fromLabel.numberOfLines = 2;
    }
    
    NSDictionary *contactDictionary = [self.emergencyDictionary objectForKey:@"Contact" ofClass:@"NSDictionary"];
    NSString *name = [contactDictionary objectForKey:@"Name" ofClass:@"NSString"];
    NSString *agency = [contactDictionary objectForKey:@"Agency" ofClass:@"NSString"];
    NSString *email = [contactDictionary objectForKey:@"Email" ofClass:@"NSString"];
    self.fromLabel.text = [NSString stringWithFormat:@"%@ | %@\n%@",
                           name,
                           agency,
                           email];
    
}

#pragma mark - Class Methods

+ (CGFloat)preferredCellHeight {
    return 149.0;
}

#pragma mark - Getters & Setters

- (void)setEmergencyDictionary:(NSDictionary *)alertDictionary {
    _emergencyDictionary = alertDictionary;
    [self setNeedsLayout];
    
}

@end
