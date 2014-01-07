//
//  HCRSurveyParticipantView.h
//  UNHCR
//
//  Created by Sean Conrad on 1/6/14.
//  Copyright (c) 2014 Sean Conrad. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HCRTableFlowLayout.h"
#import "HCRSurveyNoteCell.h"
#import "HCRSurveyAnswerCell.h"
#import "HCRSurveyAnswerFreeformCell.h"
#import "HCRSurveyQuestionHeader.h"
#import "HCRSurveyQuestionFooter.h"

////////////////////////////////////////////////////////////////////////////////

extern NSString *const kSurveyHeaderIdentifier;
extern NSString *const kSurveyFooterIdentifier;

extern NSString *const kSurveyCellIdentifier;
extern NSString *const kSurveyNoteCellIdentifier;
extern NSString *const kSurveyAnswerCellIdentifier;
extern NSString *const kSurveyAnswerFreeformCellIdentifier;

////////////////////////////////////////////////////////////////////////////////

@interface HCRSurveyParticipantView : UICollectionView

@property (nonatomic, strong) NSNumber *participantID;

+ (UICollectionViewLayout *)preferredLayout;

@end
