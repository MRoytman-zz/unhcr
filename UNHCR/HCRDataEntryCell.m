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

static const CGFloat kStepperNumberFontSize = 25.0;
static const CGFloat kHeaderFontSize = 20.0;
static const CGFloat kTitleFontSize = 18.0;
static const CGFloat kSubtitleFontSize = 15.0;

static const CGFloat kXLabelPadding = 8;

////////////////////////////////////////////////////////////////////////////////

@interface HCRDataEntryCell ()

@property UILabel *titleLabel;
@property UILabel *staticTextLabel;
@property UILabel *dataEntryStepperLabel;

@property (nonatomic, readwrite) UIButton *dataEntryButton;
@property (nonatomic, readwrite) UIStepper *dataEntryStepper;

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
    
    [self.titleLabel removeFromSuperview];
    self.titleLabel = nil;
    
    [self.dataEntryButton removeFromSuperview];
    self.dataEntryButton = nil;
    
    [self.dataEntryStepper removeFromSuperview];
    self.dataEntryStepper = nil;
    
    [self.dataEntryStepperLabel removeFromSuperview];
    self.dataEntryStepperLabel = nil;
    
    [self.staticTextLabel removeFromSuperview];
    self.staticTextLabel = nil;
    
    self.cellStatus = HCRDataEntryCellStatusNone;
    self.dataDictionary = nil;
    
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    NSParameterAssert(self.dataDictionary);
    
    // input
    UIView *inputView;
    CGFloat titleLabelFontSize = kTitleFontSize;
    NSString *inputString = [self.dataDictionary objectForKey:@"Input" ofClass:@"NSString" mustExist:NO];
    switch (self.cellStatus) {
        case HCRDataEntryCellStatusNone:
            break;
            
        case HCRDataEntryCellStatusChildNotCompleted:
        {
            NSParameterAssert(inputString);
            CGSize buttonSize = CGSizeMake(60,
                                           CGRectGetHeight(self.contentView.bounds));
            
            self.dataEntryButton = [UIButton buttonWithUNHCRTextStyleWithString:inputString
                                                            horizontalAlignment:UIControlContentHorizontalAlignmentRight
                                                                     buttonSize:buttonSize
                                                                       fontSize:[NSNumber numberWithFloat:kTitleFontSize]];
            [self.contentView addSubview:self.dataEntryButton];
            
            self.dataEntryButton.userInteractionEnabled = NO;
            
            self.dataEntryButton.center = [self _inputCenterForInputView:self.dataEntryButton];
            
            inputView = self.dataEntryButton;
            
            break;
        }
            
        case HCRDataEntryCellStatusChildCompleted:
            NSParameterAssert(inputString);
            break;
            
        case HCRDataEntryCellStatusStepperInputReady:
        {
            
            titleLabelFontSize = kSubtitleFontSize;
            
            self.dataEntryStepper = [UIStepper new];
            [self.contentView addSubview:self.dataEntryStepper];
            
            self.dataEntryStepper.maximumValue = HUGE_VALF;
            
            self.dataEntryStepper.center = [self _inputCenterForInputView:self.dataEntryStepper];
            
            [self.dataEntryStepper addTarget:self
                                      action:@selector(_stepperValueChanged:)
                            forControlEvents:UIControlEventValueChanged];
            
            CGFloat labelWidth = 40;
            self.dataEntryStepperLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(self.dataEntryStepper.frame) - labelWidth,
                                                                                   0,
                                                                                   labelWidth,
                                                                                   CGRectGetHeight(self.contentView.bounds))];
            [self.contentView addSubview:self.dataEntryStepperLabel];
            
            self.dataEntryStepperLabel.text = @"0";
            self.dataEntryStepperLabel.font = [UIFont helveticaNeueBoldFontOfSize:kStepperNumberFontSize];
            self.dataEntryStepperLabel.textAlignment = NSTextAlignmentCenter;
            self.dataEntryStepperLabel.textColor = [UIColor UNHCRBlue];
            
            self.dataEntryStepperLabel.adjustsFontSizeToFitWidth = YES;
            
            inputView = self.dataEntryStepperLabel;
            
            break;
        }
            
        case HCRDataEntryCellStatusStatic:
            NSParameterAssert(inputString);
            self.staticTextLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            [self.contentView addSubview:self.staticTextLabel];
            
            self.staticTextLabel.text = inputString;
            self.staticTextLabel.font = [UIFont helveticaNeueLightFontFontOfSize:kTitleFontSize];
            
            [self.staticTextLabel sizeToFit];
            self.staticTextLabel.center = [self _inputCenterForInputView:self.staticTextLabel];
            
            inputView = self.staticTextLabel;
            
            break;
    }
    
    // title & subtitle
    CGRect titleLabelFrame = CGRectMake(kXLabelPadding,
                                        0,
                                        CGRectGetMinX(inputView.frame) - kXLabelPadding,
                                        CGRectGetHeight(self.contentView.bounds));
    self.titleLabel = [[UILabel alloc] initWithFrame:titleLabelFrame];
    [self.contentView addSubview:self.titleLabel];
    
//    self.titleLabel.backgroundColor = [[UIColor purpleColor] colorWithAlphaComponent:0.2];
    
    BOOL isHeader = [[self.dataDictionary objectForKey:@"Header" ofClass:@"NSNumber" mustExist:NO] boolValue];
    self.titleLabel.font = (isHeader) ? [UIFont helveticaNeueBoldFontOfSize:titleLabelFontSize] : [UIFont helveticaNeueFontOfSize:kTitleFontSize];
    self.titleLabel.textAlignment = NSTextAlignmentLeft;
    
    self.titleLabel.numberOfLines = 0;
    
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
    
}

#pragma mark - Getters & Setters

- (void)setDataDictionary:(NSDictionary *)dataDictionary {
    _dataDictionary = dataDictionary;
    
    if (dataDictionary) {
        [self setNeedsLayout];
    }
}

#pragma mark - Private Methods

- (CGPoint)_inputCenterForInputView:(UIView *)view {
    return CGPointMake(CGRectGetWidth(self.contentView.bounds) - CGRectGetMidX(view.bounds) - kXLabelPadding,
                       CGRectGetMidY(self.contentView.bounds));
}

- (void)_stepperValueChanged:(UIStepper *)stepper {
    
    self.dataEntryStepperLabel.text = [NSString stringWithFormat:@"%.0f",stepper.value];
    
}

@end
