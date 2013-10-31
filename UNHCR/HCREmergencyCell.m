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
//    @"Message": @"Half the kids I work with are suffering from severe diarrhea. Are you guys aware of this?",
//    @"Severity": @1}

////////////////////////////////////////////////////////////////////////////////

static const CGFloat kDefaultCellSize = 149.0;
static const CGFloat kEmergencyBannerSize = 25.0;

////////////////////////////////////////////////////////////////////////////////

@interface HCREmergencyCell ()

@property UILabel *fromLabel;
@property UILabel *timeLabel;
@property UILabel *messageLabel;

@property UILabel *emergencyLabel;
@property UIView *emergencyLineView;

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
    
    // TODO: refactor - see HCRTableCell, HCRDirectMessageCell, etc
    [super layoutSubviews];
    
    static const CGFloat kThreeLabelHeight = 55.0;
    static const CGFloat kTwoLineLabelHeight = 35.0;
    static const CGFloat kOneLineLabelHeight = 20.0;
    static const CGFloat kYLabelPadding = 6.0;
    static const CGFloat kYLabelOffset = 12.0;
    
    static const CGFloat kLabelFontSizeDefault = 14.0;
    static const CGFloat kLabelFontSizeMessage = 15.0;
    
    CGFloat sharedLabelWidth = CGRectGetWidth(self.contentView.bounds) - 2 * self.indentForContent;
    
    // EMERGENCY
    if (!self.emergencyLabel && self.showEmergencyBanner) {
        
        UIColor *emergencyColor = [[UIColor redColor] colorWithAlphaComponent:0.7];
        
        self.emergencyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                        0,
                                                                        CGRectGetWidth(self.contentView.bounds),
                                                                        kEmergencyBannerSize)];
        [self.contentView addSubview:self.emergencyLabel];
        
        self.emergencyLabel.text = [@"Emergency" uppercaseString];
        
        self.emergencyLabel.textAlignment = NSTextAlignmentCenter;
        self.emergencyLabel.numberOfLines = 1;
        
        self.emergencyLabel.font = [UIFont boldSystemFontOfSize:16];
        
        self.emergencyLabel.textColor = [UIColor whiteColor];
        self.emergencyLabel.backgroundColor = emergencyColor;
        
//        static const CGFloat kBottomLineHeight = 0.5;
//        self.emergencyLineView = [[UIView alloc] initWithFrame:CGRectMake(0,
//                                                                       CGRectGetHeight(self.contentView.bounds) - kBottomLineHeight,
//                                                                       CGRectGetWidth(self.contentView.bounds),
//                                                                       kBottomLineHeight)];
//        [self.contentView addSubview:self.emergencyLineView];
//        
//        self.emergencyLineView.backgroundColor = emergencyColor;
        
    }
    
    // LOCATION
    if (!self.timeLabel) {
        CGRect locationFrame = CGRectMake(self.indentForContent,
                                          CGRectGetHeight(self.emergencyLabel.bounds) + kYLabelOffset,
                                          sharedLabelWidth,
                                          kOneLineLabelHeight);
        self.timeLabel = [[UILabel alloc] initWithFrame:locationFrame];
        
        [self.contentView addSubview:self.timeLabel];
        
        self.timeLabel.font = [UIFont systemFontOfSize:kLabelFontSizeDefault];
        self.timeLabel.textAlignment = NSTextAlignmentLeft;
        self.timeLabel.textColor = [UIColor redColor];
        self.timeLabel.numberOfLines = 1;
        self.timeLabel.textAlignment = NSTextAlignmentLeft;
    }
    
    NSString *targetTime = [self.emergencyDictionary objectForKey:@"Time" ofClass:@"NSString"];
    NSString *locationString = [NSString stringWithFormat:@"%@",
                                targetTime];
    
    self.timeLabel.text = locationString;

    
    // MESSAGE
    if (!self.messageLabel) {
        CGRect alertFrame = CGRectMake(self.indentForContent,
                                       CGRectGetMaxY(self.timeLabel.frame),
                                       sharedLabelWidth,
                                       kThreeLabelHeight);
        self.messageLabel = [[UILabel alloc] initWithFrame:alertFrame];
        [self.contentView addSubview:self.messageLabel];
        
        self.messageLabel.font = [UIFont boldSystemFontOfSize:kLabelFontSizeMessage];
        self.messageLabel.textAlignment = NSTextAlignmentLeft;
        self.messageLabel.textColor = [UIColor darkTextColor];
        self.messageLabel.numberOfLines = 3;
    }
    
    self.messageLabel.text = [self.emergencyDictionary objectForKey:@"Message" ofClass:@"NSString"];
    
    // FROM
    if (!self.fromLabel) {
        CGRect fromFrame = CGRectMake(self.indentForContent,
                                      CGRectGetMaxY(self.messageLabel.frame) + kYLabelPadding,
                                      sharedLabelWidth,
                                      kTwoLineLabelHeight);
        self.fromLabel = [[UILabel alloc] initWithFrame:fromFrame];
        [self.contentView addSubview:self.fromLabel];
        
        self.fromLabel.font = [UIFont systemFontOfSize:kLabelFontSizeDefault];
        self.fromLabel.textAlignment = NSTextAlignmentRight;
        self.fromLabel.textColor = [UIColor midGrayColor];
        
        self.fromLabel.numberOfLines = 2;
    }
    
    NSDictionary *contactDictionary = [self.emergencyDictionary objectForKey:@"Contact" ofClass:@"NSDictionary"];
    NSString *name = [contactDictionary objectForKey:@"Name" ofClass:@"NSString"];
//    NSString *agency = [contactDictionary objectForKey:@"Agency" ofClass:@"NSString"];
    NSString *email = [contactDictionary objectForKey:@"Email" ofClass:@"NSString"];
    self.fromLabel.text = [NSString stringWithFormat:@"%@\n%@",
                           name,
//                           agency,
                           email];
    
}

#pragma mark - Class Methods

+ (CGSize)preferredSizeForCollectionView:(UICollectionView *)collectionView {
    return CGSizeMake(CGRectGetWidth(collectionView.bounds),
                      kDefaultCellSize);
}

+ (CGSize)preferredSizeWithEmergencyBannerForCollectionView:(UICollectionView *)collectionView {
    return CGSizeMake(CGRectGetWidth(collectionView.bounds),
                      kDefaultCellSize + kEmergencyBannerSize);
}

#pragma mark - Getters & Setters

- (void)setEmergencyDictionary:(NSDictionary *)alertDictionary {
    _emergencyDictionary = alertDictionary;
    [self setNeedsLayout];
    
}

- (void)setShowEmergencyBanner:(BOOL)showEmergencyBanner {
    
    _showEmergencyBanner = showEmergencyBanner;
    
    if (!showEmergencyBanner) {
        [self.emergencyLabel removeFromSuperview];
        self.emergencyLabel = nil;
        
        [self.emergencyLineView removeFromSuperview];
        self.emergencyLineView = nil;
    }
    
    [self setNeedsLayout];
    
}

@end
