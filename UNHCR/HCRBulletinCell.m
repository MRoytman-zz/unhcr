//
//  HCRBulletinCell.m
//  UNHCR
//
//  Created by Sean Conrad on 10/30/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRBulletinCell.h"

////////////////////////////////////////////////////////////////////////////////

static const CGFloat kIndentGlobalCustom = 44.0;
static const CGFloat kIndentClusterImage = 12.0;

static const CGFloat kYOffset = 14.0;
static const CGFloat kXTrailing = 8.0;

static const CGFloat kFontSizeDefault = 16.0;
static const CGFloat kFontSizeTime = 14.0;

static const CGFloat kButtonHeight = 35.0;

static const CGFloat kClusterImageHeight = 25.0;

static const CGFloat kYTimePadding = 8.0;
static const CGFloat kYButtonPadding = 8.0;

static const CGFloat kOneLineLabelHeight = 20.0;
static const CGFloat kTwoLineLabelHeight = 35.0;
static const CGFloat kThreeLineLabelHeight = 55.0;

////////////////////////////////////////////////////////////////////////////////

@interface HCRBulletinCell ()

@property (nonatomic, readonly) CGRect clusterImageFrame;
@property (nonatomic, readonly) CGRect messageLabelFrame;
@property (nonatomic, readonly) CGRect nameLabelFrame;
//@property (nonatomic, readonly) CGRect timeLabelFrame;

@property UIImageView *clusterImage;
@property UILabel *messageLabel;
@property UILabel *nameLabel;
//@property UILabel *timeLabel;

@property (nonatomic, readonly) CGRect replyButtonFrame;
@property (nonatomic, readonly) CGRect forwardButtonFrame;

@property (nonatomic, readwrite) UIButton *replyButton;
@property (nonatomic, readwrite) UIButton *forwardButton;

@end

////////////////////////////////////////////////////////////////////////////////

@implementation HCRBulletinCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.indentForContent = kIndentGlobalCustom;
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    [self.replyButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    [self.forwardButton removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.clusterImage.frame = self.clusterImageFrame;
    self.messageLabel.frame = self.messageLabelFrame;
//    self.timeLabel.frame = self.timeLabelFrame;
    self.nameLabel.frame = self.nameLabelFrame;
    
    self.replyButton.frame = self.replyButtonFrame;
    self.forwardButton.frame = self.forwardButtonFrame;
    
//    self.clusterImage.backgroundColor = [[UIColor blueColor] colorWithAlphaComponent:0.5];
//    self.timeLabel.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.5];
//    self.messageLabel.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.5];
//    self.nameLabel.backgroundColor = [[UIColor orangeColor] colorWithAlphaComponent:0.5];
//    self.replyButton.backgroundColor = [[UIColor purpleColor] colorWithAlphaComponent:0.5];
//    self.forwardButton.backgroundColor = [[UIColor yellowColor] colorWithAlphaComponent:0.5];
    
}

#pragma mark - Class Methods

+ (CGSize)sizeForCellInCollectionView:(UICollectionView *)collectionView withBulletinDictionary:(NSDictionary *)bulletinDictionary {
    
    NSString *messageString = [bulletinDictionary objectForKey:@"Message" ofClass:@"NSString"];
    
    CGSize boundingSize = CGSizeMake(CGRectGetWidth(collectionView.bounds) - kIndentGlobalCustom - kXTrailing,
                                     CGRectGetHeight(collectionView.bounds));
    
    CGSize messageSize = [messageString sizeWithBoundingSize:boundingSize
                                                    withFont:[HCRBulletinCell _preferredFontForMessageText]
                                                     rounded:YES];
    
    CGFloat height = kYOffset + messageSize.height + kYTimePadding + kThreeLineLabelHeight + kYButtonPadding + kButtonHeight;
    
    return CGSizeMake(CGRectGetWidth(collectionView.bounds),
                      height);
    
}

+ (CGSize)preferredSizeForCollectionView:(UICollectionView *)collectionView {
    NSAssert(NO, @"Size of cell must be dynamic!");
    return CGSizeZero;
}

#pragma mark - Getters & Setters

- (CGRect)clusterImageFrame {
    
    return CGRectMake(kIndentClusterImage,
                      kYOffset,
                      CGRectGetWidth(self.clusterImage.bounds),
                      CGRectGetHeight(self.clusterImage.bounds));
    
}

- (CGRect)messageLabelFrame {
    
    CGFloat xOrigin = self.indentForContent;
    
    CGSize boundingSize = CGSizeMake(CGRectGetWidth(self.contentView.bounds) - xOrigin - kXTrailing,
                                     CGRectGetHeight(self.contentView.bounds));
    CGSize labelSize = [self.messageLabel.text sizeWithBoundingSize:boundingSize
                                                           withFont:[HCRBulletinCell _preferredFontForMessageText]
                                                            rounded:YES];
    
    return CGRectMake(xOrigin,
                      kYOffset,
                      labelSize.width,
                      labelSize.height);
}

//- (CGRect)timeLabelFrame {
//    
//    CGFloat xOrigin = self.indentForContent;
//    CGFloat labelHeight = kOneLineLabelHeight;
//    
//    return CGRectMake(xOrigin,
//                      CGRectGetMaxY(self.messageLabel.frame) + kYTimePadding,
//                      CGRectGetWidth(self.contentView.bounds) - xOrigin - kXTrailing,
//                      labelHeight);
//}

- (CGRect)nameLabelFrame {
    
    CGFloat xOrigin = self.indentForContent;
    
    return CGRectMake(xOrigin,
                      CGRectGetMaxY(self.messageLabel.frame) + kYTimePadding,
                      CGRectGetWidth(self.contentView.bounds) - xOrigin - kXTrailing,
                      kThreeLineLabelHeight);
}

- (CGRect)replyButtonFrame {
    return CGRectMake(0,
                      CGRectGetMaxY(self.nameLabel.frame) + kYButtonPadding,
                      0.5 * CGRectGetWidth(self.contentView.bounds),
                      kButtonHeight);
}

- (CGRect)forwardButtonFrame {
    return CGRectMake(0.5 * CGRectGetWidth(self.contentView.bounds),
                      CGRectGetMaxY(self.nameLabel.frame) + kYButtonPadding,
                      0.5 * CGRectGetWidth(self.contentView.bounds),
                      kButtonHeight);
}

- (void)setBulletinDictionary:(NSDictionary *)bulletinDictionary {
    _bulletinDictionary = bulletinDictionary;
    
    // CLUSTER IMAGE
    // must be re-created every use due to unique size requirements
    [self.clusterImage removeFromSuperview];
    self.clusterImage = nil;
    
    if (!self.clusterImage) {
        
        NSString *imageName = [bulletinDictionary objectForKey:@"Cluster" ofClass:@"NSString"];
        UIImage *image = [HCRDataSource imageForClusterName:imageName];
        
        image = [image resizeImageToSize:CGSizeMake(kClusterImageHeight, kClusterImageHeight)
                        withResizingMode:RMImageResizingModeFitWithin];
        
        image = [image colorImage:[UIColor UNHCRBlue]
                    withBlendMode:kCGBlendModeNormal
                 withTransparency:YES];
        
        self.clusterImage = [[UIImageView alloc] initWithImage:image];
        [self.contentView addSubview:self.clusterImage];
        
    }
    
//    if (!self.timeLabel) {
//        
//        self.timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
//        [self.contentView addSubview:self.timeLabel];
//        
//        self.timeLabel.font = [UIFont systemFontOfSize:kFontSizeTime];
//        self.timeLabel.textAlignment = NSTextAlignmentLeft;
//        self.timeLabel.textColor = [UIColor midGrayColor];
//        self.timeLabel.numberOfLines = 1;
//        
//    }
    
    if (!self.messageLabel) {
        
        self.messageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.messageLabel];
        
        self.messageLabel.font = [UIFont systemFontOfSize:kFontSizeDefault];
        self.messageLabel.textAlignment = NSTextAlignmentLeft;
        self.messageLabel.textColor = [UIColor darkTextColor];
        self.messageLabel.numberOfLines = 0;
        
    }
    
    if (!self.nameLabel) {
        
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.nameLabel];
        
        self.nameLabel.font = [UIFont systemFontOfSize:kFontSizeTime];
        self.nameLabel.textAlignment = NSTextAlignmentLeft;
        self.nameLabel.textColor = [UIColor midGrayColor];
        self.nameLabel.numberOfLines = 3;
        
    }
    
//    self.timeLabel.text = [bulletinDictionary objectForKey:@"Time" ofClass:@"NSString"];
    self.messageLabel.text = [bulletinDictionary objectForKey:@"Message" ofClass:@"NSString"];
    
    NSDictionary *contactDictionary = [bulletinDictionary objectForKey:@"Contact" ofClass:@"NSDictionary"];
    NSString *nameString = [contactDictionary objectForKey:@"Name" ofClass:@"NSString"];
    NSString *emailString = [contactDictionary objectForKey:@"Email" ofClass:@"NSString"];
    NSString *timeString = [bulletinDictionary objectForKey:@"Time" ofClass:@"NSString"];
    self.nameLabel.text = [NSString stringWithFormat:@"%@\n%@\n%@",
                           nameString,
                           emailString,
                           timeString];
    
    // BUTTONS YAY
    if (!self.replyButton) {
        self.replyButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.contentView addSubview:self.replyButton];
        
        [self.replyButton setTitle:@"Reply" forState:UIControlStateNormal];
    }
    
    if (!self.forwardButton) {
        self.forwardButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [self.contentView addSubview:self.forwardButton];
        
        [self.forwardButton setTitle:@"Forward" forState:UIControlStateNormal];
    }
    
    [self setNeedsLayout];
}

#pragma mark - Private Methods

+ (UIFont *)_preferredFontForMessageText {
    return [UIFont systemFontOfSize:kFontSizeDefault];
}

@end
