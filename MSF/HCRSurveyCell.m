//
//  HCRSurveyCell.m
//  UNHCR
//
//  Created by Sean Conrad on 1/6/14.
//  Copyright (c) 2014 Sean Conrad. All rights reserved.
//

#import "HCRSurveyCell.h"
#import "HCRSurveyParticipantView.h"

@implementation HCRSurveyCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.participantCollection = [[HCRSurveyParticipantView alloc] initWithFrame:CGRectZero collectionViewLayout:[HCRSurveyParticipantView preferredLayout]];
        [self.contentView addSubview:self.participantCollection];
    }
    return self;
}

- (void)dealloc {
    self.participantCollection.dataSource = nil;
    self.participantCollection.delegate = nil;
}

- (void)prepareForReuse {
    
    self.participantCollection.dataSource = nil;
    self.participantCollection.delegate = nil;
    self.participantID = nil;
    
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    self.participantCollection.frame = self.contentView.bounds;
    
}

#pragma mark - Getters & Setters

- (void)setParticipantID:(NSNumber *)participantID {
    
    _participantID = participantID;
    
    self.participantCollection.participantID = participantID;
    
    [self.participantCollection reloadData];
    
}

- (void)setParticipantDataSourceDelegate:(id<UICollectionViewDataSource,UICollectionViewDelegate>)participantDataSourceDelegate {
    
    _participantDataSourceDelegate = participantDataSourceDelegate;
    
    self.participantCollection.dataSource = participantDataSourceDelegate;
    self.participantCollection.delegate = participantDataSourceDelegate;
    
    [self.participantCollection reloadData];
    
}

@end
