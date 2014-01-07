//
//  HCRSurveyController.m
//  UNHCR
//
//  Created by Sean Conrad on 1/5/14.
//  Copyright (c) 2014 Sean Conrad. All rights reserved.
//

#import "HCRSurveyController.h"
#import "HCRSurveyCell.h"
#import "HCRSurveyParticipantView.h"

////////////////////////////////////////////////////////////////////////////////

@interface HCRSurveyController ()

@property (nonatomic, readonly) NSDictionary *answerSet;

@end

////////////////////////////////////////////////////////////////////////////////

@implementation HCRSurveyController

- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.title = @"Survey";
    
    self.collectionView.scrollEnabled = NO;
    
    // LAYOUT AND REUSABLES
    [self.collectionView registerClass:[HCRSurveyCell class]
            forCellWithReuseIdentifier:kSurveyCellIdentifier];
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    // refresh on load
    HCRDebug(@"time 1");
    [[HCRDataManager sharedManager] refreshSurveyResponsesForAllParticipantsWithAnswerSet:self.answerSet];
    HCRDebug(@"time 2");
    [self _reloadDataAnimated];
    
}

#pragma mark - Class Methods

+ (UICollectionViewLayout *)preferredLayout {
    
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    layout.itemSize = [UIScreen mainScreen].bounds.size;
    
    layout.sectionInset = UIEdgeInsetsZero;
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    
    return layout;
}

#pragma mark - UICollectionView Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    NSInteger numberOfSections;
    
    if (collectionView == self.collectionView) {
        
        // SURVEY PAGES
        numberOfSections = 1;
        
    } else if ([collectionView isKindOfClass:[HCRSurveyParticipantView class]]) {
        
        // CONTENTS OF SURVEY PAGES
        NSArray *responses = [[HCRDataManager sharedManager] getResponsesForAnswerSet:self.answerSet
                                                                    withParticipantID:[self _participantIDForSurveyView:collectionView]];
        numberOfSections = responses.count;
        
    } else {
        
        // WTF
        NSAssert(0, @"Unhandled collectionView type");
        numberOfSections = 0;
    }
    
    return numberOfSections;
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    NSInteger numberOfItemsInSection;
    
    if (collectionView == self.collectionView) {
        
        // SURVEY PAGES
        NSArray *participants = [[HCRDataManager sharedManager] getParticipantsForAnswerSet:self.answerSet];
        numberOfItemsInSection = participants.count;
        
    } else if ([collectionView isKindOfClass:[HCRSurveyParticipantView class]]) {
        
        // CONTENTS OF SURVEY PAGES
        NSInteger participantID = [self _participantIDForSurveyView:collectionView];
        
        NSArray *responses = [[HCRDataManager sharedManager] getResponsesForAnswerSet:self.answerSet
                                                                    withParticipantID:participantID];
        
        NSDictionary *responseData = [responses objectAtIndex:section];
        NSArray *answers = [[HCRDataManager sharedManager] getSurveyAnswersForResponseData:responseData];
        
        // if answers is empty, return 1 - it's freeform!
        numberOfItemsInSection = (answers) ? answers.count : 1;
        
    } else {
        
        // WTF
        NSAssert(0, @"Unhandled collectionView type");
        numberOfItemsInSection = 0;
    }
    
    return numberOfItemsInSection;
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (collectionView == self.collectionView) {
        
        // SURVEY PAGES
        return [self _collectionViewSurveyForIndexPath:indexPath];
        
    } else if ([collectionView isKindOfClass:[HCRSurveyParticipantView class]]) {
        
        // CONTENTS OF SURVEY PAGES
        NSInteger participantID = [self _participantIDForSurveyView:collectionView];
        
        return [self _cellForParticipantCollectionView:collectionView
                                     withParticipantID:participantID
                                           atIndexPath:indexPath];
        
    } else {
        NSAssert(NO, @"Unhandled collectionView type..");
        return nil;
    }
    
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    if (collectionView == self.collectionView) {
        
        // SURVEY PAGES
        // do nothing!
        
    } else if ([collectionView isKindOfClass:[HCRSurveyParticipantView class]]) {
        
        if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
            HCRSurveyQuestionHeader *header =
            [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                               withReuseIdentifier:kSurveyHeaderIdentifier
                                                      forIndexPath:indexPath];
            
            // ADD QUESTION
            
            return header;
        } else if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
            HCRSurveyQuestionFooter *footer =
            [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                               withReuseIdentifier:kSurveyFooterIdentifier
                                                      forIndexPath:indexPath];
            return footer;
        }
        
    } else {
        NSAssert(NO, @"Unhandled collectionView type..");
    }
    
    return nil;
    
}

#pragma mark - UICollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (collectionView == self.collectionView) {
        
        // SURVEY PAGES
        // do nothing
        
    } else if ([collectionView isKindOfClass:[HCRSurveyParticipantView class]]) {
        
        // CONTENTS OF SURVEY PAGES
        // highlight cell / transform section
        // record answer in data manager
        
    } else {
        NSAssert(NO, @"Unhandled collectionView type..");
    }
    
}

#pragma mark - UICollectionView Delegate Flow Layout

// header size dependent on text
// footer size probably just static space

#pragma mark - Getters & Setters

- (NSDictionary *)answerSet {
    
    return [[HCRDataManager sharedManager] getAnswerSetWithID:self.answerSetID];
    
}

#pragma mark - Private Methods

- (void)_reloadDataAnimated {
    [self.collectionView reloadData];
}

- (UICollectionViewCell *)_cellForParticipantCollectionView:(UICollectionView *)collectionView withParticipantID:(NSInteger)participantID atIndexPath:(NSIndexPath *)indexPath {
    
    HCRSurveyAnswerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kSurveyAnswerCellIdentifier
                                                                          forIndexPath:indexPath];
    
    return cell;
    
}

- (UICollectionViewCell *)_collectionViewSurveyForIndexPath:(NSIndexPath *)indexPath {
    
    HCRSurveyCell *surveyCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:kSurveyCellIdentifier
                                                                               forIndexPath:indexPath];
    
    surveyCell.participantDataSourceDelegate = self;
    surveyCell.participantID = @(indexPath.row);
    
    return surveyCell;
    
}

- (NSInteger)_participantIDForSurveyView:(UICollectionView *)collectionView {
    
    HCRSurveyParticipantView *surveyView = (HCRSurveyParticipantView *)collectionView;
    NSParameterAssert([surveyView isKindOfClass:[HCRSurveyParticipantView class]]);
    
    return surveyView.participantID.integerValue;
    
}

@end
