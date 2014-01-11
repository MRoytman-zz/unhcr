//
//  HCRSurveyQuestionHeader.h
//  UNHCR
//
//  Created by Sean Conrad on 1/6/14.
//  Copyright (c) 2014 Sean Conrad. All rights reserved.
//

#import "HCRHeaderView.h"
#import "HCRSurveyParticipantView.h"

@class HCRSurveyQuestion;

@interface HCRSurveyQuestionHeader : HCRHeaderView

@property (nonatomic, readonly) HCRSurveyQuestion *surveyQuestion;
@property (nonatomic, readonly) HCRSurveyAnswerSetParticipant *participant;

@property (nonatomic) BOOL questionAnswered;

+ (CGSize)sizeForHeaderInCollectionView:(HCRSurveyParticipantView *)collectionView withQuestionData:(HCRSurveyQuestion *)surveyQuestion withParticipant:(HCRSurveyAnswerSetParticipant *)participant;

- (void)setSurveyQuestion:(HCRSurveyQuestion *)surveyQuestion withParticipant:(HCRSurveyAnswerSetParticipant *)participant;

@end
