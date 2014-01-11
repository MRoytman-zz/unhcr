//
//  HCRSurveyQuestionHeader.m
//  UNHCR
//
//  Created by Sean Conrad on 1/6/14.
//  Copyright (c) 2014 Sean Conrad. All rights reserved.
//

#import "HCRSurveyQuestionHeader.h"
#import "HCRSurveyQuestion.h"

////////////////////////////////////////////////////////////////////////////////

static const CGFloat kXContentIndent = 20;
static const CGFloat kXContentTrailing = 20;
static const CGFloat kYContentPadding = 30;
static const CGFloat kYContentTrailing = 10;

////////////////////////////////////////////////////////////////////////////////

@interface HCRSurveyQuestionHeader ()

@property NSAttributedString *questionString;
@property UIColor *unansweredBackgroundColor;
@property UIColor *defaultBackgroundColor;

@property (nonatomic, strong) HCRSurveyQuestion *surveyQuestion;
@property (nonatomic, strong) HCRSurveyAnswerSetParticipant *participant;

@end

////////////////////////////////////////////////////////////////////////////////

@implementation HCRSurveyQuestionHeader

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.defaultBackgroundColor = [UIColor tableBackgroundColor];
        self.unansweredBackgroundColor = [UIColor headerUnansweredBackgroundColor];
        self.backgroundColor = self.defaultBackgroundColor;
        
        self.titleLabel.numberOfLines = 0;
        self.titleLabel.textColor = [UIColor flatDarkBlackColor];
        
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.surveyQuestion = nil;
    self.questionAnswered = NO;
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.backgroundColor = (self.questionAnswered) ? self.defaultBackgroundColor : self.unansweredBackgroundColor;
    
    CGSize boundingSize = [HCRSurveyQuestionHeader _boundingSizeForContainingView:self];
    CGSize labelSize = [self.questionString.string sizeforMultiLineStringWithBoundingSize:boundingSize
                                                                                 withAttributes:[HCRSurveyQuestionHeader _attributesForSurveyQuestion]
                                                                                  rounded:YES];
    self.titleLabel.frame = CGRectMake(kXContentIndent,
                                       kYContentPadding,
                                       labelSize.width,
                                       labelSize.height);
    
}

#pragma mark - Class Methods

+ (CGSize)sizeForHeaderInCollectionView:(HCRSurveyParticipantView *)collectionView withQuestionData:(HCRSurveyQuestion *)surveyQuestion withParticipant:(HCRSurveyAnswerSetParticipant *)participant {
    
    CGFloat height;
    
    // the maximum dimensions the label can be
    CGSize finalBounding = [HCRSurveyQuestionHeader _boundingSizeForContainingView:collectionView];
    
    // start with padding
    height = kYContentPadding + kYContentTrailing;
    
    // then add height of label
    NSAttributedString *attributedString = [HCRSurveyQuestionHeader _attributedStringForSurveyQuestion:surveyQuestion withParticipant:participant];
    CGSize preferredSize = [attributedString.string sizeforMultiLineStringWithBoundingSize:finalBounding withAttributes:[HCRSurveyQuestionHeader _attributesForSurveyQuestion] rounded:YES];
    
    height += preferredSize.height;
    
    return CGSizeMake(preferredSize.width,
                      height);
    
}

#pragma mark - Getters & Setters

- (void)setQuestionAnswered:(BOOL)questionAnswered {
    _questionAnswered = questionAnswered;
    [self setNeedsLayout];
}

#pragma mark - Public Methods

- (void)setSurveyQuestion:(HCRSurveyQuestion *)surveyQuestion withParticipant:(HCRSurveyAnswerSetParticipant *)participant {
    _surveyQuestion = surveyQuestion;
    _participant = participant;
    
    self.questionString = (surveyQuestion) ? [HCRSurveyQuestionHeader _attributedStringForSurveyQuestion:surveyQuestion withParticipant:participant] : nil;
    self.titleLabel.attributedText = self.questionString;
    
    [self setNeedsLayout];
    
}

#pragma mark - Private Methods

+ (NSAttributedString *)_attributedStringForSurveyQuestion:(HCRSurveyQuestion *)surveyQuestion withParticipant:(HCRSurveyAnswerSetParticipant *)participant {
    
    NSString *questionLabel = [[NSString stringWithFormat:@"Question %@",surveyQuestion.questionCode] uppercaseString];
    NSString *questionString = surveyQuestion.questionString;
    NSString *totalString = [NSString stringWithFormat:@"%@\n%@",
                             questionLabel,
                             questionString];
    
    if ([totalString rangeOfString:@"%@"].location != NSNotFound) {
        NSString *participantName = [participant localizedParticipantName];
        totalString = [totalString stringByReplacingOccurrencesOfString:@"%@" withString:participantName];
    }
    
    NSDictionary *questionAttributes = [HCRSurveyQuestionHeader _attributesForSurveyQuestion];
    NSMutableDictionary *labelAttributes = questionAttributes.mutableCopy;
    [labelAttributes setObject:[HCRSurveyQuestionHeader _fontForQuestionBold:NO] forKey:NSFontAttributeName];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:totalString
                                                                                         attributes:questionAttributes];
    
    [attributedString setAttributes:labelAttributes range:[totalString rangeOfString:questionLabel]];
    
    return attributedString;
    
}

+ (CGSize)_boundingSizeForContainingView:(UIView *)containingView {
    
    return CGSizeMake(CGRectGetWidth(containingView.bounds) - kXContentIndent - kXContentTrailing,
                      HUGE_VALF);
    
}

+ (UIFont *)_fontForQuestionBold:(BOOL)bold {
    
    CGFloat fontSize = (bold) ? 16 : 14;
    
    return (bold) ? [UIFont boldSystemFontOfSize:fontSize] : [UIFont systemFontOfSize:fontSize];
}

+ (NSDictionary *)_attributesForSurveyQuestion {
    
    NSMutableParagraphStyle *paragraphStyle = [NSParagraphStyle defaultParagraphStyle].mutableCopy;
    paragraphStyle.paragraphSpacing = 5;
    
    return @{NSFontAttributeName: [HCRSurveyQuestionHeader _fontForQuestionBold:YES],
             NSParagraphStyleAttributeName: paragraphStyle};
    
}


@end
