//
//  HCRDataEntryCell.m
//  UNHCR
//
//  Created by Sean Conrad on 10/6/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRDataEntryCell.h"

////////////////////////////////////////////////////////////////////////////////

// dataDictionary fields
// Header - BOOL - if present, line is header object and deserves more weight
// Title - NSString - left aligned bolded string
// Subtitle - NSString - left aligned non-bolded string below title
// Input - NSString - right aligned string representing input (blue button if notCompleted, green checkmark if completed, black if static)

////////////////////////////////////////////////////////////////////////////////

static const CGFloat kHeaderFontSize = 20.0;
static const CGFloat kTitleFontSize = 18.0;
static const CGFloat kSubtitleFontSize = 15.0;

static const CGFloat kXLabelPadding = 8;

////////////////////////////////////////////////////////////////////////////////

@interface HCRDataEntryCell ()

@property UILabel *titleLabel;
@property UILabel *staticTextLabel;

@property (nonatomic, readwrite) UIButton *dataEntryButton;

@end

////////////////////////////////////////////////////////////////////////////////

@implementation HCRDataEntryCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
//        self.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.1];
        
    }
    return self;
}

- (void)prepareForReuse {
    
    self.cellStatus = HCRDataEntryCellStatusNotCompleted;
    self.dataDictionary = nil;
    
    [self.titleLabel removeFromSuperview];
    self.titleLabel = nil;
    
    [self.dataEntryButton removeFromSuperview];
    self.dataEntryButton = nil;
    
    [self.staticTextLabel removeFromSuperview];
    self.staticTextLabel = nil;
    
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    NSParameterAssert(self.dataDictionary);
    
    // title & subtitle
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:self.titleLabel];
    
//    self.titleLabel.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.2];
    
    BOOL isHeader = [[self.dataDictionary objectForKey:@"Header" ofClass:@"NSNumber" mustExist:NO] boolValue];
    self.titleLabel.font = (isHeader) ? [UIFont helveticaNeueBoldFontOfSize:kTitleFontSize] : [UIFont helveticaNeueFontOfSize:kTitleFontSize];
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    
    self.titleLabel.numberOfLines = 2;
    
    NSString *titleString = [self.dataDictionary objectForKey:@"Title" ofClass:@"NSString"];
    NSString *subtitleString = [self.dataDictionary objectForKey:@"Subtitle" ofClass:@"NSString" mustExist:NO];
    if (subtitleString) {
        
        NSString *combinedString = [NSString stringWithFormat:@"%@\n%@",
                                    titleString,
                                    subtitleString];
        
        NSDictionary *lightAttribute = @{NSFontAttributeName: [UIFont helveticaNeueLightFontFontOfSize:kSubtitleFontSize],
                                         NSObliquenessAttributeName: @0.1};
        NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] initWithString:combinedString];
        [mutableAttributedString addAttributes:lightAttribute
                                         range:NSMakeRange(titleString.length,
                                                           combinedString.length - titleString.length)];
        
        self.titleLabel.attributedText = mutableAttributedString;
        
    } else {
        self.titleLabel.text = titleString;
    }
    
    [self.titleLabel sizeToFit];
    
    self.titleLabel.center = CGPointMake(kXLabelPadding + CGRectGetMidX(self.titleLabel.bounds),
                                         CGRectGetMidY(self.contentView.bounds));
    
    // input
    NSString *inputString = [self.dataDictionary objectForKey:@"Input" ofClass:@"NSString"];
    switch (self.cellStatus) {
        case HCRDataEntryCellStatusNotCompleted:
        {
            CGSize buttonSize = CGSizeMake(CGRectGetWidth(self.contentView.bounds) - CGRectGetWidth(self.titleLabel.bounds),
                                           CGRectGetHeight(self.contentView.bounds));
            
            self.dataEntryButton = [UIButton buttonWithUNHCRTextStyleWithString:inputString
                                                            horizontalAlignment:UIControlContentHorizontalAlignmentRight
                                                                     buttonSize:buttonSize
                                                                       fontSize:[NSNumber numberWithFloat:kTitleFontSize]];
            [self.contentView addSubview:self.dataEntryButton];
            
            self.dataEntryButton.userInteractionEnabled = NO;
            
            self.dataEntryButton.center = [self _inputCenterForInputView:self.dataEntryButton];
            
            break;
        }
            
        case HCRDataEntryCellStatusCompleted:
            break;
            
        case HCRDataEntryCellStatusStatic:
            self.staticTextLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            [self.contentView addSubview:self.staticTextLabel];
            
            self.staticTextLabel.text = inputString;
            self.staticTextLabel.font = [UIFont helveticaNeueLightFontFontOfSize:kTitleFontSize];
            
            [self.staticTextLabel sizeToFit];
            self.staticTextLabel.center = [self _inputCenterForInputView:self.staticTextLabel];
            
            break;
    }
    
}

#pragma mark - Getters & Setters

- (void)setDataDictionary:(NSDictionary *)dataDictionary {
    _dataDictionary = dataDictionary;
    [self setNeedsLayout];
}

#pragma mark - Private Methods

- (CGPoint)_inputCenterForInputView:(UIView *)view {
    return CGPointMake(CGRectGetWidth(self.contentView.bounds) - CGRectGetMidX(view.bounds) - kXLabelPadding,
                       CGRectGetMidY(self.contentView.bounds));
}

@end
