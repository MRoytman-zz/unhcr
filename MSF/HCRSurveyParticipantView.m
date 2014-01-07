//
//  HCRSurveyParticipantView.m
//  UNHCR
//
//  Created by Sean Conrad on 1/6/14.
//  Copyright (c) 2014 Sean Conrad. All rights reserved.
//

#import "HCRSurveyParticipantView.h"
#import "HCRTableFlowLayout.h"

@implementation HCRSurveyParticipantView

- (id)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout {
    
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        // Initialization code
    }
    return self;
}

+ (UICollectionViewLayout *)preferredLayout {
    return [HCRTableFlowLayout new];
}

@end
