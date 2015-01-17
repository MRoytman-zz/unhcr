//
//  HCRDirectMessageCell.m
//  UNHCR
//
//  Created by Sean Conrad on 10/30/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRDirectMessageCell.h"

////////////////////////////////////////////////////////////////////////////////

//  @{@"From": @"",
//    @"Messages": @[
//            @{@"Time": @"",
//              @"Message": @"",
//              @"Read": @BOOL}
//            ]
//    },

////////////////////////////////////////////////////////////////////////////////

static const CGFloat kDefaultCellHeight = 82.0;

static const CGFloat kYPadding = 12.0;
static const CGFloat kXTrailingSpace = 12.0;
static const CGFloat kXPadding = 10.0;

static const CGFloat kOneLineLabelHeight = 15.0;
static const CGFloat kTwoLineLabelHeight = 40.0;

static const CGFloat kForwardButtonPadding = 10.0;
static const CGFloat kForwardButtonDimension = kOneLineLabelHeight;
static const CGFloat kForwardButtonWidthRatio = 0.75;

static const CGFloat kTimeTrailingSpace = 4.0;

static const CGFloat kYMessagePadding = 6.0;

static const CGFloat kFontSizeDefault = 14.0;
static const CGFloat kFontSizeName = 16.0;

////////////////////////////////////////////////////////////////////////////////

@interface HCRDirectMessageCell ()

@property (nonatomic, readonly) CGPoint forwardImageViewCenter;
@property (nonatomic, readonly) CGRect timeLabelFrame;
@property (nonatomic, readonly) CGRect nameLabelFrame;
@property (nonatomic, readonly) CGRect messageLabelFrame;

@property UILabel *timeLabel;
@property UILabel *nameLabel;
@property UILabel *messageLabel;
@property UIImageView *forwardImageView;

@property NSDictionary *messageTextAttributes;

@end

////////////////////////////////////////////////////////////////////////////////

@implementation HCRDirectMessageCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.contentView.backgroundColor = [UIColor whiteColor];
        
        // message text attributes
        NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
        paragraphStyle.alignment = NSTextAlignmentLeft;
        paragraphStyle.lineSpacing = 3.0;
        paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
        self.messageTextAttributes = @{NSFontAttributeName: [UIFont systemFontOfSize:kFontSizeDefault],
                                       NSForegroundColorAttributeName: [UIColor midGrayColor],
                                       NSParagraphStyleAttributeName: paragraphStyle};
        
        // forward image
        CGSize forwardImageSize = CGSizeMake(kForwardButtonDimension * kForwardButtonWidthRatio,
                                             kForwardButtonDimension);
        UIImage *forwardImage = [UIImage imageNamed:@"forward-button"];
        forwardImage = [forwardImage colorImage:[UIColor lightGrayColor]
                                  withBlendMode:kCGBlendModeNormal
                               withTransparency:YES];
        forwardImage = [forwardImage resizeImageToSize:forwardImageSize
                                      withResizingMode:RMImageResizingModeExact];
        
        self.forwardImageView = [[UIImageView alloc] initWithImage:forwardImage];
        [self.contentView addSubview:self.forwardImageView];
        
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.messageDictionary = nil;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // NOTE: ORDER IS IMPORTANT; frames/positions based off each other
    self.forwardImageView.center = self.forwardImageViewCenter;
    self.timeLabel.frame = self.timeLabelFrame;
    self.nameLabel.frame = self.nameLabelFrame;
    self.messageLabel.frame = self.messageLabelFrame;
    
//    self.forwardImageView.backgroundColor = [UIColor greenColor];
//    self.timeLabel.backgroundColor = [UIColor blueColor];
//    self.nameLabel.backgroundColor = [UIColor orangeColor];
//    self.messageLabel.backgroundColor = [UIColor purpleColor];
    
}

#pragma mark - Class Methods

+ (CGSize)preferredSizeForCollectionView:(UICollectionView *)collectionView {
    return CGSizeMake(CGRectGetWidth(collectionView.bounds),
                      kDefaultCellHeight);
}

#pragma mark - Getters & Setters

- (CGPoint)forwardImageViewCenter {
    return CGPointMake(CGRectGetWidth(self.contentView.bounds) - kForwardButtonPadding - CGRectGetMidX(self.forwardImageView.bounds),
                       kYPadding + CGRectGetMidY(self.forwardImageView.bounds));
}

- (CGRect)timeLabelFrame {
    
    CGSize smallestSize = CGSizeZero;
    if (self.timeLabel) {
        smallestSize = [self.timeLabel.text sizeWithAttributes:@{NSFontAttributeName:self.timeLabel.font}];
    }
    CGSize timeLabelSize = CGSizeMake(smallestSize.width,
                                      kOneLineLabelHeight);
    
    return CGRectMake(CGRectGetMinX(self.forwardImageView.frame) - kTimeTrailingSpace - timeLabelSize.width,
                      kYPadding,
                      timeLabelSize.width,
                      timeLabelSize.height);
}

- (CGRect)nameLabelFrame {
    CGFloat xOffset = self.indentForContent;
    return CGRectMake(xOffset,
                      kYPadding,
                      CGRectGetMinX(self.timeLabel.frame) - xOffset,
                      kOneLineLabelHeight);
}

- (CGRect)messageLabelFrame {
    
    CGFloat xOffset = self.indentForContent;
    
    CGSize maxSize = CGSizeMake(CGRectGetMaxX(self.forwardImageView.frame) - xOffset,
                                kTwoLineLabelHeight);
    CGSize labelSize = [self.messageLabel sizeThatFits:maxSize];
    
    return CGRectMake(xOffset,
                      CGRectGetMaxY(self.nameLabel.frame) + kYMessagePadding,
                      labelSize.width,
                      labelSize.height);
}

- (void)setMessageDictionary:(NSDictionary *)messageDictionary {
    
    // TODO: refactor - don't nil out labels unless actually needed
    _messageDictionary = messageDictionary;
    
    NSString *timeString = [messageDictionary objectForKey:@"Time" ofClass:@"NSString"];
    NSString *nameString = [messageDictionary objectForKey:@"From" ofClass:@"NSString"];
    NSString *messageString = [messageDictionary objectForKey:@"Message" ofClass:@"NSString"];
    
    if (messageDictionary) {
        
        if (!self.timeLabel) {
            self.timeLabel = [[UILabel alloc] init];
            [self.contentView addSubview:self.timeLabel];
            
            self.timeLabel.font = [UIFont helveticaNeueLightFontOfSize:kFontSizeDefault];
            self.timeLabel.textAlignment = NSTextAlignmentRight;
            self.timeLabel.textColor = [UIColor midGrayColor];
            
            self.timeLabel.numberOfLines = 1;
        }
        
        if (!self.nameLabel) {
            self.nameLabel = [[UILabel alloc] init];
            [self.contentView addSubview:self.nameLabel];
            
            self.nameLabel.font = [UIFont boldSystemFontOfSize:kFontSizeName];
            self.nameLabel.textAlignment = NSTextAlignmentLeft;
            self.nameLabel.textColor = [UIColor darkTextColor];
            
            self.nameLabel.numberOfLines = 1;
        }
        
        if (!self.messageLabel) {
            self.messageLabel = [[UILabel alloc] init];
            [self.contentView addSubview:self.messageLabel];
            
            self.messageLabel.numberOfLines = 2;
        }
        
        self.timeLabel.text = timeString;
        self.nameLabel.text = nameString;
        
        self.messageLabel.attributedText = [[NSAttributedString alloc] initWithString:messageString
                                                                           attributes:self.messageTextAttributes];
        
        [self setNeedsLayout];
    }
    
}

@end
