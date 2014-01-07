//
//  HCRSurveyParticipantView.h
//  UNHCR
//
//  Created by Sean Conrad on 1/6/14.
//  Copyright (c) 2014 Sean Conrad. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HCRSurveyParticipantView : UICollectionView

@property (nonatomic, strong) NSNumber *participantID;

+ (UICollectionViewLayout *)preferredLayout;

@end
