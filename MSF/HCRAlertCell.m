//
//  HCRAlertCell.m
//  UNHCR
//
//  Created by Sean Conrad on 1/22/14.
//  Copyright (c) 2014 Sean Conrad. All rights reserved.
//

#import "HCRAlertCell.h"

////////////////////////////////////////////////////////////////////////////////

static const CGFloat kYLabelPadding = 10;

////////////////////////////////////////////////////////////////////////////////

@interface HCRAlertCell ()

@property NSDateFormatter *dateFormatter;

@property UILabel *fromLabel;
@property UILabel *timeLabel;
@property UILabel *messageLabel;

@end

////////////////////////////////////////////////////////////////////////////////

@implementation HCRAlertCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.dateFormatter = [NSDateFormatter dateFormatterWithFormat:HCRDateFormatSMSDatesWithTime forceEuropeanFormat:YES];
        
        // top label
        // other top label (clear, right aligned)
        // message label
        
        self.fromLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.fromLabel];
        
        self.fromLabel.backgroundColor = [[UIColor flatBlueColor] colorWithAlphaComponent:0.2];
        
        self.fromLabel.numberOfLines = 1;
        
        self.timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.timeLabel];
        
        self.timeLabel.backgroundColor = [UIColor clearColor];
        
        self.timeLabel.numberOfLines = 1;
        self.timeLabel.textAlignment = NSTextAlignmentRight;
        
        self.messageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.messageLabel];
        
        self.timeLabel.backgroundColor = [[UIColor flatYellowColor] colorWithAlphaComponent:0.2];
        
        self.messageLabel.numberOfLines = 0;
        
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    
    NSString *fromString = self.alert.authorName;
    NSString *dateString = [self.dateFormatter stringFromDate:self.alert.updatedAt];
    NSString *messageString = self.alert.message;
    
    self.fromLabel.text = fromString;
    self.timeLabel.text = dateString;
    self.messageLabel.text = messageString;
    
    CGSize topSize = [HCRTableCell preferredSizeForString:fromString inCollectionView:self.superview];
    CGSize messageSize = [HCRTableCell preferredSizeForString:messageString inCollectionView:self.superview];
    
    self.fromLabel.frame = CGRectMake(0, 0, topSize.width, topSize.height);
    self.timeLabel.frame = self.fromLabel.frame;
    self.messageLabel.frame = CGRectMake(0, 50, messageSize.width, messageSize.height);
    
}

#pragma mark - Class Methods

+ (CGSize)sizeForCellInCollectionView:(UICollectionView *)collectionView withAlert:(HCRAlert *)alert {
    
    // vars we need
    NSString *fromString = alert.authorName;
    NSString *messageString = alert.message;
    
    NSString *approximateString = [NSString stringWithFormat:@"%@\n%@",
                                   fromString,
                                   messageString];
    
    CGSize defaultSize = [HCRTableCell sizeForCollectionView:collectionView withAnswerString:approximateString];
    return CGSizeMake(defaultSize.width,
                      defaultSize.height + kYLabelPadding);
    
}

#pragma mark - Getters & Setters

- (void)setAlert:(HCRAlert *)alert {
    
    _alert = alert;
    
    [self setNeedsLayout];
    
}

@end
