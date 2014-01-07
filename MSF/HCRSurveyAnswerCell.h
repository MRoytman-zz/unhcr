//
//  HCRSurveyAnswerCell.h
//  UNHCR
//
//  Created by Sean Conrad on 1/6/14.
//  Copyright (c) 2014 Sean Conrad. All rights reserved.
//

#import "HCRCollectionCell.h"

@interface HCRSurveyAnswerCell : HCRCollectionCell

@property (nonatomic) BOOL *freeform;
@property (nonatomic, strong) NSString *answerTitle;

@end
