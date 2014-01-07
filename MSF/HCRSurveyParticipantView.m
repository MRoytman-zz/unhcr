//
//  HCRSurveyParticipantView.m
//  UNHCR
//
//  Created by Sean Conrad on 1/6/14.
//  Copyright (c) 2014 Sean Conrad. All rights reserved.
//

#import "HCRSurveyParticipantView.h"

////////////////////////////////////////////////////////////////////////////////

NSString *const kSurveyHeaderIdentifier = @"kSurveyHeaderIdentifier";
NSString *const kSurveyFooterIdentifier = @"kSurveyFooterIdentifier";

NSString *const kSurveyCellIdentifier = @"kSurveyCellIdentifier";
NSString *const kSurveyNoteCellIdentifier = @"kSurveyNoteCellIdentifier";
NSString *const kSurveyAnswerCellIdentifier = @"kSurveyAnswerCellIdentifier";
NSString *const kSurveyAnswerFreeformCellIdentifier = @"kSurveyAnswerFreeformCellIdentifier";

////////////////////////////////////////////////////////////////////////////////

@implementation HCRSurveyParticipantView

- (id)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout {
    
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        // Initialization code
        
        self.backgroundColor = [UIColor tableBackgroundColor];
        
        [self registerClass:[HCRSurveyQuestionHeader class]
 forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
        withReuseIdentifier:kSurveyHeaderIdentifier];
        
        [self registerClass:[HCRSurveyQuestionFooter class]
 forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
        withReuseIdentifier:kSurveyFooterIdentifier];
        
        [self registerClass:[HCRSurveyAnswerCell class]
 forCellWithReuseIdentifier:kSurveyAnswerCellIdentifier];
        
        [self registerClass:[HCRSurveyAnswerFreeformCell class]
 forCellWithReuseIdentifier:kSurveyAnswerFreeformCellIdentifier];
        
        [self registerClass:[HCRSurveyNoteCell class]
 forCellWithReuseIdentifier:kSurveyNoteCellIdentifier];
        
    }
    return self;
}

+ (UICollectionViewLayout *)preferredLayout {
    return [HCRTableFlowLayout new];
}

@end
