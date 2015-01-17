//
//  HCRAlertCell.m
//  UNHCR
//
//  Created by Sean Conrad on 1/22/14.
//  Copyright (c) 2014 Sean Conrad. All rights reserved.
//

#import "HCRAlertCell.h"

////////////////////////////////////////////////////////////////////////////////

static const CGFloat kYLabelLeadingPadding = 0;
static const CGFloat kYLabelInterItemPadding = 10;
static const CGFloat kYLabelTrailingPadding = 20;

static const CGFloat kLabelHeight = 35;

////////////////////////////////////////////////////////////////////////////////

@interface HCRAlertCell ()

@property NSDateFormatter *dateFormatter;

@property UILabel *fromLabel;
@property UILabel *timeLabel;
@property UILabel *messageLabel;
@property UIView *topLabelBackground;

@end

////////////////////////////////////////////////////////////////////////////////

@implementation HCRAlertCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.dateFormatter = [NSDateFormatter dateFormatterWithFormat:HCRDateFormatSMSDatesWithTime forceEuropeanFormat:YES];
        
        // BACKGROUND
        self.topLabelBackground = [[UIView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.topLabelBackground];
        
        // NAME LABEL
        self.fromLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.fromLabel];
        
        self.fromLabel.backgroundColor = [UIColor clearColor];
        
        self.fromLabel.font = [HCRAlertCell preferredFontForName];
        self.fromLabel.textColor = [UIColor whiteColor];
        
        self.fromLabel.numberOfLines = 1;
        
        // TIME LABEL
        self.timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.timeLabel];
        
        self.timeLabel.backgroundColor = [UIColor clearColor];
        
        self.timeLabel.font = [HCRAlertCell preferredFontForTime];
        self.timeLabel.textColor = [UIColor whiteColor];
        
        self.timeLabel.numberOfLines = 1;
        self.timeLabel.textAlignment = NSTextAlignmentRight;
        
        // MESSAGE LABEL
        self.messageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.messageLabel];
        
        self.messageLabel.backgroundColor = [UIColor whiteColor];
        
        self.messageLabel.font = [HCRAlertCell preferredFontForMessage];
        
        self.messageLabel.numberOfLines = 0;
        
        self.bottomLineView.hidden = YES;
        
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.read = NO;
    self.bottomLineView.hidden = YES;
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    NSString *fromString = self.alert.authorName;
    NSString *dateString = [self.dateFormatter stringFromDate:self.alert.submittedTime];
    NSString *messageString = self.alert.message;
    
    self.fromLabel.text = fromString;
    self.timeLabel.text = dateString;
    self.messageLabel.text = messageString;
    
    CGSize messageSize = [HCRCollectionCell preferredSizeForString:messageString
                                                          withFont:[HCRAlertCell preferredFontForMessage]
                                                  inContainingView:self.superview];
    
    CGFloat maxWidth = CGRectGetWidth(self.contentView.bounds) - self.indentForContent - self.trailingSpaceForContent;
    self.fromLabel.frame = CGRectMake(self.indentForContent,
                                      kYLabelLeadingPadding,
                                      maxWidth,
                                      kLabelHeight);
    self.timeLabel.frame = self.fromLabel.frame;
    
    self.topLabelBackground.frame = CGRectMake(0,
                                               CGRectGetMinY(self.fromLabel.frame),
                                               CGRectGetWidth(self.contentView.bounds),
                                               CGRectGetHeight(self.fromLabel.bounds));
    
    self.messageLabel.frame = CGRectMake(self.indentForContent,
                                         CGRectGetMaxY(self.fromLabel.frame) + kYLabelInterItemPadding,
                                         maxWidth,
                                         messageSize.height);
    
}

#pragma mark - Class Methods

+ (CGSize)sizeForCellInCollectionView:(UICollectionView *)collectionView withAlert:(HCRAlert *)alert {
    
    NSString *messageString = alert.message;
    
    CGSize messageSize = [HCRCollectionCell preferredSizeForString:messageString
                                                          withFont:[HCRAlertCell preferredFontForMessage]
                                                  inContainingView:collectionView];
    
    CGFloat height = kYLabelLeadingPadding + kLabelHeight + kYLabelInterItemPadding + messageSize.height + kYLabelTrailingPadding;
    
    return CGSizeMake(CGRectGetWidth(collectionView.bounds),
                      height);
    
}

#pragma mark - Getters & Setters

- (void)setAlert:(HCRAlert *)alert {
    
    _alert = alert;
    
    [self setNeedsLayout];
    
}

- (void)setRead:(BOOL)read {
    
    _read = read;
    
    UIColor *sharedColor = [UIColor flatBlueColor];
    self.topLabelBackground.backgroundColor = (self.read) ? [sharedColor colorWithAlphaComponent:0.5] : sharedColor;
    
}

#pragma mark - Private Methods

+ (UIFont *)preferredFontForName {
    return [UIFont boldSystemFontOfSize:18];
}

+ (UIFont *)preferredFontForTime {
    return [UIFont systemFontOfSize:15];
}

+ (UIFont *)preferredFontForMessage {
    return [UIFont systemFontOfSize:15];
}

@end
