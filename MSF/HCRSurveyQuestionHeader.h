//
//  HCRSurveyQuestionHeader.h
//  UNHCR
//
//  Created by Sean Conrad on 1/6/14.
//  Copyright (c) 2014 Sean Conrad. All rights reserved.
//

#import "HCRHeaderView.h"

@class HCRSurveyQuestion;

@interface HCRSurveyQuestionHeader : HCRHeaderView

+ (CGSize)sizeForHeaderInCollectionView:(UICollectionView *)collectionView withQuestionData:(HCRSurveyQuestion *)surveyQuestion;

@property (nonatomic, strong) HCRSurveyQuestion *surveyQuestion;

@property (nonatomic) BOOL questionAnswered;

@end
