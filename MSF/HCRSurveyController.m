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

@property (nonatomic, readonly) HCRSurveyAnswerSet *answerSet;
@property (nonatomic, readonly) UICollectionViewFlowLayout *flowLayout;

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
    [super viewWillAppear:animated];
    
    // refresh on load
    [self _refreshModelData];
    
}

#pragma mark - Class Methods

+ (UICollectionViewLayout *)preferredLayout {
    
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
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
        NSInteger participantID = [self _participantIDForSurveyView:collectionView];
        HCRSurveyAnswerSetParticipant *participant = [self.answerSet participantWithID:participantID];
        numberOfSections = participant.questions.count;
        
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
        numberOfItemsInSection = self.answerSet.participants.count;
        
    } else if ([collectionView isKindOfClass:[HCRSurveyParticipantView class]]) {
        
        // CONTENTS OF SURVEY PAGES
        
        HCRSurveyAnswerSetParticipantQuestion *question = [self _participantQuestionForSection:section inCollectionView:collectionView];
        HCRSurveyQuestion *surveyQuestion = [[HCRDataManager sharedManager] surveyQuestionWithQuestionID:question.question];
        
        // if answers is empty, return 1 - it's freeform!
        numberOfItemsInSection = (surveyQuestion.answers) ? surveyQuestion.answers.count : 1;
        
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

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    
    if (collectionView == self.collectionView) {
        
        // SURVEY PAGES
        return CGSizeZero;
        
    } else if ([collectionView isKindOfClass:[HCRSurveyParticipantView class]]) {
        
        // CONTENTS OF SURVEY PAGES
        return [HCRHeaderView preferredHeaderSizeForCollectionView:collectionView];
        
    } else {
        NSAssert(NO, @"Unhandled collectionView type..");
        return CGSizeZero;
    }
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    
    if (collectionView == self.collectionView) {
        
        // SURVEY PAGES
        return CGSizeZero;
        
    } else if ([collectionView isKindOfClass:[HCRSurveyParticipantView class]]) {
        
        // CONTENTS OF SURVEY PAGES
        return (section == collectionView.numberOfSections - 1) ? [HCRSurveyQuestionFooter preferredFooterSizeForCollectionView:collectionView] : [HCRSurveyQuestionFooter preferredFooterSizeWithBottomLineOnlyForCollectionView:collectionView];
        
    } else {
        NSAssert(NO, @"Unhandled collectionView type..");
        return CGSizeZero;
    }
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // not ideal to use this method on such a large collection, but there's some wackiness with the collectionview changing all over the place, so..
    
    if (collectionView == self.collectionView) {
        
        // SURVEY PAGES
        UINavigationBar *navBar = self.navigationController.navigationBar;
        UIEdgeInsets navigationInsets = UIEdgeInsetsMake(CGRectGetMinY(navBar.frame) + CGRectGetHeight(navBar.bounds),
                                                         0,
                                                         0,
                                                         0);
        
        return UIEdgeInsetsInsetRect(self.view.bounds, navigationInsets).size;
        
    } else if ([collectionView isKindOfClass:[HCRSurveyParticipantView class]]) {
        
        // CONTENTS OF SURVEY PAGES
        UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)collectionView.collectionViewLayout;
        return flowLayout.itemSize;
        
    } else {
        NSAssert(NO, @"Unhandled collectionView type..");
        return CGSizeZero;
    }
    
}

#pragma mark - Getters & Setters

- (HCRSurveyAnswerSet *)answerSet {
    
    return [[HCRDataManager sharedManager] surveyAnswerSetWithLocalID:self.answerSetID];
    
}

- (UICollectionViewFlowLayout *)flowLayout {
    
    UICollectionViewFlowLayout *flow = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    NSParameterAssert([flow isKindOfClass:[UICollectionViewFlowLayout class]]);
    
    return flow;
    
}

#pragma mark - Private Methods

- (void)_reloadLayout {
    
    [self.collectionView reloadData];
}

- (void)_refreshModelData {
    
    [[HCRDataManager sharedManager] refreshSurveyResponsesForAllParticipantsWithAnswerSet:self.answerSet];
    
    [self _reloadLayout];
    
}

- (UICollectionViewCell *)_cellForParticipantCollectionView:(UICollectionView *)collectionView withParticipantID:(NSInteger)participantID atIndexPath:(NSIndexPath *)indexPath {
    
    HCRSurveyAnswerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kSurveyAnswerCellIdentifier
                                                                          forIndexPath:indexPath];
    
    // get question code
    NSString *questionCode = [self _participantQuestionForSection:indexPath.section inCollectionView:collectionView].question;
    
    // get answer strings
    HCRSurveyQuestion *question = [[HCRDataManager sharedManager] surveyQuestionWithQuestionID:questionCode];
    NSArray *answerStrings = question.answers;
    HCRSurveyQuestionAnswer *answer = [answerStrings objectAtIndex:indexPath.row ofClass:@"HCRSurveyQuestionAnswer"];
    
    // check freeform status
    BOOL freeform = [answer.freeform boolValue];
    
    NSString *titleString = (freeform) ? [NSString stringWithFormat:@"%@ (freeform)",answer.string] : answer.string;
    
    cell.title = titleString;
    
    [cell setBottomLineStatusForCollectionView:collectionView atIndexPath:indexPath];
    
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

- (HCRSurveyAnswerSetParticipantQuestion *)_participantQuestionForSection:(NSInteger)section inCollectionView:(UICollectionView *)collectionView {
    
    // get question code
    NSInteger participantID = [self _participantIDForSurveyView:collectionView];
    return [[self.answerSet participantWithID:participantID].questions objectAtIndex:section];
    
}

@end
