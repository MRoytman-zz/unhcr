//
//  HCRAlertCell.m
//  UNHCR
//
//  Created by Sean Conrad on 10/7/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCREmergencyCell.h"

////////////////////////////////////////////////////////////////////////////////

//  @{@"Emergency": @YES,
//    @"Time": @"Yesterday 07:22",
//    @"Category": @"Fire",
//    @"Camp": @"Domiz, Iraq",
//    @"Location": @"Phase 4, Row 2",
//    @"Deaths": @"20",
//    @"Hurt": @"100",
//    @"Contact": @{@"Name": @"Edrees Nabi Salih",
//                  @"Email": @"edress.salih@qandil.org",
//                  @"Cluster": @"Education"},
//    @"Status": @"Half the kids I work with are suffering from severe diarrhea. Are you guys aware of this?",
//    @"Needs": @"Half the kids I work with are suffering from severe diarrhea. Are you guys aware of this?"}

////////////////////////////////////////////////////////////////////////////////

NSString *const kUnknownString = @"Unknown";

////////////////////////////////////////////////////////////////////////////////

static const CGFloat kEmergencyBannerHeight = 30.0;

static const CGFloat kXContentIndent = 20.0;
static const CGFloat kXContentTrailing = 20.0;
static const CGFloat kXContentPadding = 4.0;

static const CGFloat kXContentIndentForValueLabel = 110.0;

static const CGFloat kYLabelOffset = 8.0;
static const CGFloat kYLabelPadding = 16.0;
static const CGFloat kYLabelTrailing = 8.0;

static const CGFloat kDividerViewHeightSmall = 0.5;
static const CGFloat kDividerViewHeightLarge = 1.0;

static const CGFloat kFontSizeHeader = 20.0;
static const CGFloat kFontSizeLabel = 16.0;

static const CGFloat kLabelHeight = 20.0;

////////////////////////////////////////////////////////////////////////////////

@interface HCREmergencyCell ()

@property (nonatomic, readwrite) UIButton *emailContactButton;
@property (nonatomic, readonly) CGRect frameForEmailContactButton;

// sweet jesus
@property (nonatomic, readonly) CGRect frameForBackgroundTemplate;
@property (nonatomic, readonly) CGRect frameForCategoryLabel;
@property (nonatomic, readonly) CGRect frameForTimeLabel;

@property (nonatomic, readonly) CGRect frameForCampLabel;
@property (nonatomic, readonly) CGRect frameForLocationLabel;
@property (nonatomic, readonly) CGRect frameForDeathsLabel;
@property (nonatomic, readonly) CGRect frameForHurtLabel;
@property (nonatomic, readonly) CGRect frameForStatusLabel;
@property (nonatomic, readonly) CGRect frameForNeedsLabel;
@property (nonatomic, readonly) CGRect frameForContactLabel;

@property (nonatomic, readonly) CGRect frameForCampValueLabel;
@property (nonatomic, readonly) CGRect frameForLocationValueLabel;
@property (nonatomic, readonly) CGRect frameForDeathsValueLabel;
@property (nonatomic, readonly) CGRect frameForHurtValueLabel;
@property (nonatomic, readonly) CGRect frameForStatusValueLabel;
@property (nonatomic, readonly) CGRect frameForNeedsValueLabel;
@property (nonatomic, readonly) CGRect frameForContactValueLabel;

@property UIView *backgroundTemplate;

@property UILabel *categoryLabel;
@property UILabel *timeLabel;

@property UILabel *campLabel;
@property UILabel *locationLabel;
@property UILabel *deathsLabel;
@property UILabel *hurtLabel;
@property UILabel *statusLabel;
@property UILabel *needsLabel;
@property UILabel *contactLabel;

@property UILabel *campValueLabel;
@property UILabel *locationValueLabel;
@property UILabel *deathsValueLabel;
@property UILabel *hurtValueLabel;
@property UILabel *statusValueLabel;
@property UILabel *needsValueLabel;
@property UILabel *contactValueLabel;

@end

////////////////////////////////////////////////////////////////////////////////

@implementation HCREmergencyCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.indentForContent = kXContentIndent;
        self.trailingSpaceForContent = kXContentTrailing;
        
        self.emailContactButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.contentView addSubview:self.emailContactButton];
        
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.emergencyDictionary = nil;
    [self.emailContactButton removeTarget:nil
                                   action:NULL
                         forControlEvents:UIControlEventAllEvents];
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.backgroundTemplate.frame = self.frameForBackgroundTemplate;
    self.categoryLabel.frame = self.frameForCategoryLabel;
    self.timeLabel.frame = self.frameForTimeLabel;

    self.campValueLabel.frame = self.frameForCampValueLabel;
    self.locationValueLabel.frame = self.frameForLocationValueLabel;
    self.deathsValueLabel.frame = self.frameForDeathsValueLabel;
    self.hurtValueLabel.frame = self.frameForHurtValueLabel;
    self.statusValueLabel.frame = self.frameForStatusValueLabel;
    self.needsValueLabel.frame = self.frameForNeedsValueLabel;
    self.contactValueLabel.frame = self.frameForContactValueLabel;
    
    self.campLabel.frame = self.frameForCampLabel;
    self.locationLabel.frame = self.frameForLocationLabel;
    self.deathsLabel.frame = self.frameForDeathsLabel;
    self.hurtLabel.frame = self.frameForHurtLabel;
    self.statusLabel.frame = self.frameForStatusLabel;
    self.needsLabel.frame = self.frameForNeedsLabel;
    self.contactLabel.frame = self.frameForContactLabel;
    
    self.emailContactButton.frame = self.frameForEmailContactButton;
    
}

#pragma mark - Class Methods

+ (CGSize)sizeForCellInCollectionView:(UICollectionView *)collectionView withEmergencyDictionary:(NSDictionary *)emergencyDictionary {
    
    return [HCREmergencyCell _sizeForContentWithBoundingSize:collectionView.bounds.size withEmergencyDictionary:emergencyDictionary];
    
}

+ (CGSize)preferredSizeForCollectionView:(UICollectionView *)collectionView {
    NSAssert(NO, @"Size of cell must be dynamic!");
    return CGSizeZero;
}

#pragma mark - Getters & Setters

- (CGRect)frameForCategoryLabel {
    return CGRectMake(0,
                      0,
                      CGRectGetWidth(self.contentView.bounds),
                      kEmergencyBannerHeight);
}

- (CGRect)frameForTimeLabel {
    return CGRectMake(0,
                      CGRectGetMaxY(self.categoryLabel.frame),
                      CGRectGetWidth(self.contentView.bounds),
                      kEmergencyBannerHeight);
}

- (CGRect)frameForCampValueLabel {
    return [self _rectForValueLabelString:self.campValueLabel.text withPreviousLabel:self.timeLabel];
}

- (CGRect)frameForCampLabel {
    return [self _rectForLabelWithValueLabel:self.campValueLabel];
}

- (CGRect)frameForLocationValueLabel {
    return [self _rectForValueLabelString:self.locationValueLabel.text withPreviousLabel:self.campValueLabel];
}

- (CGRect)frameForLocationLabel {
    return [self _rectForLabelWithValueLabel:self.locationValueLabel];
}

- (CGRect)frameForDeathsValueLabel {
    return [self _rectForValueLabelString:self.deathsValueLabel.text withPreviousLabel:self.locationValueLabel];
}

- (CGRect)frameForDeathsLabel {
    return [self _rectForLabelWithValueLabel:self.deathsValueLabel];
}

- (CGRect)frameForHurtValueLabel {
    return [self _rectForValueLabelString:self.hurtValueLabel.text withPreviousLabel:self.deathsValueLabel];
}

- (CGRect)frameForHurtLabel {
    return [self _rectForLabelWithValueLabel:self.hurtValueLabel];
}

- (CGRect)frameForStatusValueLabel {
    return [self _rectForValueLabelString:self.statusValueLabel.text withPreviousLabel:self.hurtValueLabel];
}

- (CGRect)frameForStatusLabel {
    return [self _rectForLabelWithValueLabel:self.statusValueLabel];
}

- (CGRect)frameForNeedsValueLabel {
    return [self _rectForValueLabelString:self.needsValueLabel.text withPreviousLabel:self.statusValueLabel];
}

- (CGRect)frameForNeedsLabel {
    return [self _rectForLabelWithValueLabel:self.needsValueLabel];
}

- (CGRect)frameForContactValueLabel {
    return [self _rectForValueLabelString:self.contactValueLabel.text withPreviousLabel:self.needsValueLabel];
}

- (CGRect)frameForContactLabel {
    return [self _rectForLabelWithValueLabel:self.contactValueLabel];
}

- (CGRect)frameForEmailContactButton {
    return self.contactValueLabel.frame;
}

- (void)setEmergencyDictionary:(NSDictionary *)emergencyDictionary {
    _emergencyDictionary = emergencyDictionary;
    
    if (!emergencyDictionary) {
        
        self.categoryLabel.text = nil;
        self.timeLabel.text = nil;
        self.campValueLabel.text = nil;
        self.locationValueLabel.text = nil;
        self.deathsValueLabel.text = nil;
        self.hurtValueLabel.text = nil;
        self.statusValueLabel.text = nil;
        self.needsValueLabel.text = nil;
        self.contactValueLabel.text = nil;
        
    } else {
        
        // GET STRINGS
        NSDictionary *contactDictionary = [emergencyDictionary objectForKey:@"Contact" ofClass:@"NSDictionary"];
        
        NSString *categoryString = [[emergencyDictionary objectForKey:@"Category" ofClass:@"NSString"] uppercaseString];
        NSString *timeString = [emergencyDictionary objectForKey:@"Time" ofClass:@"NSString"];
        NSString *campString = [emergencyDictionary objectForKey:@"Camp" ofClass:@"NSString"];
        NSString *locationString = [emergencyDictionary objectForKey:@"Location" ofClass:@"NSString"];
        NSString *deathsString = [emergencyDictionary objectForKey:@"Deaths" ofClass:@"NSString"];
        NSString *hurtString = [emergencyDictionary objectForKey:@"Hurt" ofClass:@"NSString"];
        NSString *statusString = [emergencyDictionary objectForKey:@"Status" ofClass:@"NSString" mustExist:NO];
        NSString *needsString = [emergencyDictionary objectForKey:@"Needs" ofClass:@"NSString" mustExist:NO];
        NSString *contactString = [NSString stringWithFormat:@"%@\n%@",
                                   [contactDictionary objectForKey:@"Name" ofClass:@"NSString"],
                                   [contactDictionary objectForKey:@"Email" ofClass:@"NSString"]];
        
        if (!statusString) {
            statusString = kUnknownString;
        }
        
        if (!needsString) {
            needsString = kUnknownString;
        }
        
        // SIZES OF LABELS
        CGFloat templateWidth = CGRectGetWidth(self.contentView.bounds);
        CGSize commonBoundingSize = [HCREmergencyCell _boundingSizeForValueLabelInViewWithWidth:templateWidth];
        UIFont *commonFont = [HCREmergencyCell _preferredFontForLabelBold:YES];
        
        CGSize campValueLabelSize = [campString sizeforMultiLineStringWithBoundingSize:commonBoundingSize
                                                                                  withFont:commonFont
                                                                                   rounded:YES];
        
        CGSize locationValueLabelSize = [locationString sizeforMultiLineStringWithBoundingSize:commonBoundingSize
                                                                                      withFont:commonFont
                                                                                       rounded:YES];
        CGSize deathsValueLabelSize = [deathsString sizeforMultiLineStringWithBoundingSize:commonBoundingSize
                                                                                  withFont:commonFont
                                                                                   rounded:YES];
        CGSize hurtValueLabelSize = [hurtString sizeforMultiLineStringWithBoundingSize:commonBoundingSize
                                                                              withFont:commonFont
                                                                               rounded:YES];
        CGSize statusValueLabelSize = [statusString sizeforMultiLineStringWithBoundingSize:commonBoundingSize
                                                                                  withFont:commonFont
                                                                                   rounded:YES];
        CGSize needsValueLabelSize = [needsString sizeforMultiLineStringWithBoundingSize:commonBoundingSize
                                                                                withFont:commonFont
                                                                                 rounded:YES];
//        CGSize contactValueLabelSize = [needsString sizeforMultiLineStringWithBoundingSize:commonBoundingSize
//                                                                                  withFont:commonFont
//                                                                                   rounded:YES];
        
        // BACKGROUND TEMPLATE
        if (!self.backgroundTemplate) {
            
            self.backgroundTemplate = [[UIView alloc] initWithFrame:CGRectZero];
            [self.contentView addSubview:self.backgroundTemplate];
            
            self.backgroundTemplate.backgroundColor = [UIColor whiteColor];
            
            // EMERGENCY HEADER SUBVIEWS
            CGSize emergencyHeaderSize = CGSizeMake(templateWidth,
                                                    kEmergencyBannerHeight);
            UIView *emergencyHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                                   0,
                                                                                   emergencyHeaderSize.width,
                                                                                   emergencyHeaderSize.height)];
            [self.backgroundTemplate addSubview:emergencyHeaderView];
            
            emergencyHeaderView.backgroundColor = [UIColor redColor];
            
            UIView *headerDivider = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                             CGRectGetMaxY(emergencyHeaderView.frame) - 0.5 * kDividerViewHeightLarge,
                                                                             emergencyHeaderSize.width,
                                                                             kDividerViewHeightLarge)];
            [self.contentView addSubview:headerDivider];
            
            headerDivider.backgroundColor = [UIColor whiteColor];
            
            UIView *emergencySubHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                                      emergencyHeaderSize.height,
                                                                                      emergencyHeaderSize.width,
                                                                                      emergencyHeaderSize.height)];
            [self.backgroundTemplate addSubview:emergencySubHeaderView];
            
            emergencySubHeaderView.backgroundColor = [UIColor redColor];
            
            // LABEL DIVIDER SUBVIEWS
            CGFloat campLocOrigin = 2 * kEmergencyBannerHeight + kYLabelOffset + campValueLabelSize.height + 0.5 * kYLabelPadding - 0.5 * kDividerViewHeightSmall;
            CGRect campLocRect = [self _dividerFrameForLabelWithYOrigin:campLocOrigin];
            UIView *campLocationDivider = [[UIView alloc] initWithFrame:campLocRect];
            [self.contentView addSubview:campLocationDivider];
            
            campLocationDivider.backgroundColor = [UIColor tableDividerColor];
            
            // TODO: could put this in to a loop - refactor later
            UIView *locationDeathsDivider = [self _dividerViewPositionedWithPreviousDivider:campLocationDivider
                                                                      withPreviousLabelSize:locationValueLabelSize
                                                                           addToContentView:YES];
            
            UIView *deathsHurtDivider = [self _dividerViewPositionedWithPreviousDivider:locationDeathsDivider
                                                                  withPreviousLabelSize:deathsValueLabelSize
                                                                       addToContentView:YES];
            
            UIView *hurtStatusDivider = [self _dividerViewPositionedWithPreviousDivider:deathsHurtDivider
                                                                  withPreviousLabelSize:hurtValueLabelSize
                                                                       addToContentView:YES];
            
            UIView *statusNeedsDivider = [self _dividerViewPositionedWithPreviousDivider:hurtStatusDivider
                                                                   withPreviousLabelSize:statusValueLabelSize
                                                                        addToContentView:YES];
            
//            UIView *needsContactDivider =
            [self _dividerViewPositionedWithPreviousDivider:statusNeedsDivider
                                      withPreviousLabelSize:needsValueLabelSize
                                           addToContentView:YES];
            
        }
        
        // MAKE LABELS
        if (!self.categoryLabel) {
            self.categoryLabel = [UILabel new];
            [self.contentView addSubview:self.categoryLabel];
            
            self.categoryLabel.textColor = [UIColor whiteColor];
            
            self.categoryLabel.textAlignment = NSTextAlignmentCenter;
            self.categoryLabel.font = [UIFont boldSystemFontOfSize:kFontSizeHeader];
        }
        
        if (!self.timeLabel) {
            self.timeLabel = [UILabel new];
            [self.contentView addSubview:self.timeLabel];
            
            self.timeLabel.textColor = [UIColor whiteColor];
            
            self.timeLabel.textAlignment = NSTextAlignmentCenter;
            self.timeLabel.font = [UIFont systemFontOfSize:kFontSizeLabel];
        }
        
        if (!self.campLabel) {
            self.campLabel = [self _valueLabelWithString:@"Camp" withBoldText:NO addToContentView:YES];
        }
        
        if (!self.campValueLabel) {
            self.campValueLabel = [self _valueLabelWithString:nil withBoldText:YES addToContentView:YES];
        }
        
        if (!self.locationLabel) {
            self.locationLabel = [self _valueLabelWithString:@"Location" withBoldText:NO addToContentView:YES];
        }
        
        if (!self.locationValueLabel) {
            self.locationValueLabel = [self _valueLabelWithString:nil withBoldText:YES addToContentView:YES];
        }
        
        if (!self.deathsLabel) {
            self.deathsLabel = [self _valueLabelWithString:@"Deaths" withBoldText:NO addToContentView:YES];
            
        }
        
        if (!self.deathsValueLabel) {
            self.deathsValueLabel = [self _valueLabelWithString:nil withBoldText:YES addToContentView:YES];
        }
        
        if (!self.hurtLabel) {
            NSString *hurtLabelString = ([[categoryString lowercaseString] isEqualToString:[@"Outbreak" lowercaseString]]) ? @"Cases" : @"Injured";
            self.hurtLabel = [self _valueLabelWithString:hurtLabelString withBoldText:NO addToContentView:YES];
            
        }
        
        if (!self.hurtValueLabel) {
            self.hurtValueLabel = [self _valueLabelWithString:nil withBoldText:YES addToContentView:YES];
        }
        
        if (!self.statusLabel) {
            self.statusLabel = [self _valueLabelWithString:@"Status" withBoldText:NO addToContentView:YES];
            
        }
        
        if (!self.statusValueLabel) {
            self.statusValueLabel = [self _valueLabelWithString:nil withBoldText:YES addToContentView:YES];
        }
        
        if (!self.needsLabel) {
            self.needsLabel = [self _valueLabelWithString:@"Requests" withBoldText:NO addToContentView:YES];
            
        }
        
        if (!self.needsValueLabel) {
            self.needsValueLabel = [self _valueLabelWithString:nil withBoldText:YES addToContentView:YES];
        }
        
        if (!self.contactLabel) {
            self.contactLabel = [self _valueLabelWithString:@"Contact" withBoldText:NO addToContentView:YES];
        }
        
        if (!self.contactValueLabel) {
            self.contactValueLabel = [self _valueLabelWithString:nil withBoldText:NO addToContentView:YES];
            self.contactValueLabel.textColor = [UIColor UNHCRBlue];
        }
        
        // SET TEXT
        self.categoryLabel.text = categoryString;
        self.timeLabel.text = timeString;
        self.campValueLabel.text = campString;
        self.locationValueLabel.text = locationString;
        self.deathsValueLabel.text = deathsString;
        self.hurtValueLabel.text = hurtString;
        self.statusValueLabel.text = statusString;
        self.needsValueLabel.text = needsString;
        self.contactValueLabel.text = contactString;
        
    }
    
    [self setNeedsLayout];
    
}

#pragma mark - Private Methods - Class Methods

+ (CGSize)_sizeForContentWithBoundingSize:(CGSize)boundingSize withEmergencyDictionary:(NSDictionary *)emergencyDictionary {
    
    CGFloat height;
    
    // vars we need
    NSArray *stringArray = [HCREmergencyCell _arrayOfStringsForValueLabelsWithEmergencyDictionary:emergencyDictionary];
    CGSize finalBounding = [HCREmergencyCell _boundingSizeForValueLabelInViewWithWidth:boundingSize.width];
    
    // start with padding
    NSInteger amountOfPadding = (stringArray.count - 1) * kYLabelPadding;
    height = kEmergencyBannerHeight + kEmergencyBannerHeight + kYLabelOffset + amountOfPadding + kYLabelTrailing;
    
    // then add size of objects
    for (NSString *string in stringArray) {
        
        CGSize stringSize = [string sizeforMultiLineStringWithBoundingSize:finalBounding
                                                                  withFont:[HCREmergencyCell _preferredFontForLabelBold:YES]
                                                                   rounded:YES];
        
        height += stringSize.height;
        
    }
    
    return CGSizeMake(boundingSize.width,
                      height);
    
}

+ (CGSize)_boundingSizeForStandardLabel {
    return CGSizeMake(kXContentIndentForValueLabel - kXContentIndent - kXContentPadding,
                      HUGE_VALF);
}

+ (CGSize)_boundingSizeForValueLabelInViewWithWidth:(CGFloat)viewWidth {
    return CGSizeMake(viewWidth - kXContentIndentForValueLabel - kXContentTrailing,
                      HUGE_VALF);
}

+ (UIFont *)_preferredFontForLabelBold:(BOOL)bold {
    return (bold) ? [UIFont boldSystemFontOfSize:kFontSizeLabel] : [UIFont systemFontOfSize:kFontSizeLabel];
}

+ (NSArray *)_arrayOfStringsForValueLabelsWithEmergencyDictionary:(NSDictionary *)emergencyDictionary {
    
    NSMutableArray *strings = @[[emergencyDictionary objectForKey:@"Camp" ofClass:@"NSString"],
                                [emergencyDictionary objectForKey:@"Location" ofClass:@"NSString"],
                                [emergencyDictionary objectForKey:@"Deaths" ofClass:@"NSString"],
                                [emergencyDictionary objectForKey:@"Hurt" ofClass:@"NSString"]].mutableCopy;
    
    NSString *statusString = [emergencyDictionary objectForKey:@"Status" ofClass:@"NSString" mustExist:NO];
    [strings addObject:(statusString) ? statusString : kUnknownString];
    
    NSString *needsString = [emergencyDictionary objectForKey:@"Needs" ofClass:@"NSString" mustExist:NO];
    [strings addObject:(needsString) ? needsString : kUnknownString];
    
    NSDictionary *contactDictionary = [emergencyDictionary objectForKey:@"Contact" ofClass:@"NSDictionary"];
    NSString *contactString = [NSString stringWithFormat:@"%@\n%@",
                               [contactDictionary objectForKey:@"Name" ofClass:@"NSString"],
                               [contactDictionary objectForKey:@"Email" ofClass:@"NSString"]];
    [strings addObject:contactString];
    
    return strings;
}

#pragma mark - Private Methods

- (CGRect)_dividerFrameForLabelWithYOrigin:(CGFloat)yOrigin {
    return CGRectMake(self.indentForContent,
                      yOrigin,
                      CGRectGetWidth(self.contentView.bounds) - self.indentForContent,
                      kDividerViewHeightSmall);
}

- (CGRect)_rectForValueLabelString:(NSString *)string withPreviousLabel:(UILabel *)label {
    
    CGSize commonBoundingSize = [HCREmergencyCell _boundingSizeForValueLabelInViewWithWidth:CGRectGetWidth(self.contentView.bounds)];
    UIFont *commonFont = [HCREmergencyCell _preferredFontForLabelBold:YES];
    CGSize stringSize = [string sizeforMultiLineStringWithBoundingSize:commonBoundingSize
                                                              withFont:commonFont
                                                               rounded:YES];
    CGFloat padding = (label == self.timeLabel) ? kYLabelOffset : kYLabelPadding;
    return CGRectMake(kXContentIndentForValueLabel,
                      CGRectGetMaxY(label.frame) + padding,
                      stringSize.width,
                      stringSize.height);
}

- (CGRect)_rectForLabelWithValueLabel:(UILabel *)valueLabel {
    return CGRectMake(self.indentForContent,
                      CGRectGetMinY(valueLabel.frame),
                      kXContentIndentForValueLabel - self.indentForContent,
                      kLabelHeight);
}

- (UILabel *)_valueLabelWithString:(NSString *)string withBoldText:(BOOL)bold addToContentView:(BOOL)addToContentView {
    
    UILabel *label = [UILabel new];
    
    if (addToContentView) {
        [self.contentView addSubview:label];
    }
    
    label.font = (bold) ? [UIFont boldSystemFontOfSize:kFontSizeLabel] : [UIFont systemFontOfSize:kFontSizeLabel];
    label.text = string;
    
    label.numberOfLines = 0;
    
    return label;
    
}

- (UIView *)_dividerViewPositionedWithPreviousDivider:(UIView *)previousDivider withPreviousLabelSize:(CGSize)labelSize addToContentView:(BOOL)addToContentView {
    
    CGFloat dividerOrigin = CGRectGetMaxY(previousDivider.frame) + labelSize.height + kYLabelPadding;
    CGRect dividerRect = [self _dividerFrameForLabelWithYOrigin:dividerOrigin];
    UIView *divider = [[UIView alloc] initWithFrame:dividerRect];
    
    if (addToContentView) {
        [self.contentView addSubview:divider];
    }
    
    divider.backgroundColor = [UIColor tableDividerColor];
    
    return divider;
    
}

@end
