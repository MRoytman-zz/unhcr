//
//  HCRSurveyController.h
//  UNHCR
//
//  Created by Sean Conrad on 1/5/14.
//  Copyright (c) 2014 Sean Conrad. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HCRSurveyController : UICollectionViewController
<UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSString *answerSetID;

+ (UICollectionViewLayout *)preferredLayout;

@end
