//
//  HCRSurveyController.h
//  UNHCR
//
//  Created by Sean Conrad on 1/5/14.
//  Copyright (c) 2014 Sean Conrad. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HCRDataEntryFieldCell.h"

@interface HCRSurveyController : UICollectionViewController
<UICollectionViewDelegateFlowLayout, HCRDataEntryCellDelegate>

@property (nonatomic, strong) NSString *surveyID;
@property (nonatomic, strong) NSString *answerSetID;

+ (UICollectionViewLayout *)preferredLayout;

@end
