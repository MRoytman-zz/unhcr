//
//  HCRSurveyAnswerFreeformCell.h
//  UNHCR
//
//  Created by Sean Conrad on 1/6/14.
//  Copyright (c) 2014 Sean Conrad. All rights reserved.
//

#import "HCRDataEntryFieldCell.h"

@class HCRSurveyParticipantView;

@interface HCRSurveyAnswerFreeformCell : HCRDataEntryFieldCell

@property (nonatomic) BOOL answered;

@property (nonatomic, strong) HCRSurveyParticipantView *participantView;

@end
