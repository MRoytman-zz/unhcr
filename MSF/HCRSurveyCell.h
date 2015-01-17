//
//  HCRSurveyCell.h
//  UNHCR
//
//  Created by Sean Conrad on 1/6/14.
//  Copyright (c) 2014 Sean Conrad. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HCRSurveyParticipantView;

@interface HCRSurveyCell : UICollectionViewCell

@property (nonatomic, strong) HCRSurveyParticipantView *participantCollection;

@property (nonatomic, strong) NSNumber *participantID;
@property (nonatomic, strong) id<UICollectionViewDataSource, UICollectionViewDelegate> participantDataSourceDelegate;

@end
