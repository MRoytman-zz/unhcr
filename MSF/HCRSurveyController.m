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
    self.collectionView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    
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
        
        if (question.answer) {
            numberOfItemsInSection = 1; // the answer is all that remains :)
        } else {
            HCRSurveyQuestion *surveyQuestion = [[HCRDataManager sharedManager] surveyQuestionWithQuestionID:question.question];
            
            if (surveyQuestion.freeformLabel) {
                numberOfItemsInSection = 1; // free-form question
            } else {
                numberOfItemsInSection = surveyQuestion.answers.count; // normal :)
            }
        }

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
        return [self _cellForParticipantCollectionView:collectionView
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
            HCRSurveyAnswerSetParticipantQuestion *question = [self _participantQuestionForSection:indexPath.section inCollectionView:collectionView];
            header.titleString = [self _questionStringForSection:indexPath.section inCollectionView:collectionView];
            header.questionAnswered = (question.answer != nil || question.answerString != nil);
            
            return header;
        } else if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
            HCRSurveyQuestionFooter *footer =
            [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                               withReuseIdentifier:kSurveyFooterIdentifier
                                                      forIndexPath:indexPath];
            
//            footer.questionAnswered = [self _participantQuestionForSection:indexPath.section inCollectionView:collectionView].answer.boolValue;
            
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
        
        [self _surveyAnswerCellPressedInCollectionView:collectionView AtIndexPath:indexPath withFreeformAnswer:nil];
        
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

#pragma mark - HCRDataFieldCell Delegate

- (void)dataEntryFieldCellDidBecomeFirstResponder:(HCRDataEntryFieldCell *)signInCell {
    
    // TODO: center signInCell in view
    
}

- (void)dataEntryFieldCellDidPressDone:(HCRDataEntryFieldCell *)signInCell {
    
    [signInCell.inputField resignFirstResponder];
    
}

- (void)dataEntryFieldCellDidResignFirstResponder:(HCRDataEntryFieldCell *)signInCell {
    
    HCRSurveyAnswerFreeformCell *freeformCell = (HCRSurveyAnswerFreeformCell *)signInCell;
    NSParameterAssert([freeformCell isKindOfClass:[HCRSurveyAnswerFreeformCell class]]);
    
    NSIndexPath *cellIndexPath = [freeformCell.participantView indexPathForCell:freeformCell];
    
    if (signInCell.inputField.text) {
        [self _surveyAnswerCellPressedInCollectionView:freeformCell.participantView AtIndexPath:cellIndexPath withFreeformAnswer:(signInCell.inputField.text) ? signInCell.inputField.text : nil];
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

- (void)_reloadAllData {
    [self _reloadData:YES inSections:nil withCollectionView:self.collectionView animated:NO withLayoutChanges:nil];
}

- (void)_reloadData:(BOOL)reloadData inSections:(NSIndexSet *)sections withCollectionView:(UICollectionView *)collectionView animated:(BOOL)animated withLayoutChanges:(void (^)(void))layoutChanges {
    
    if (animated == NO ||
        (reloadData && !layoutChanges)) {
        [collectionView reloadData];
    }
    
    if (layoutChanges) {
        [collectionView performBatchUpdates:layoutChanges completion:^(BOOL finished) {
            if (reloadData) {
                if (sections) {
                    [collectionView reloadSections:sections];
                } else {
                    [collectionView reloadData];
                }
            }
        }];
    }
    
}

- (void)_refreshModelData {
    
    [[HCRDataManager sharedManager] refreshSurveyResponsesForAllParticipantsWithAnswerSet:self.answerSet];
    
    [self _reloadData:YES inSections:nil withCollectionView:self.collectionView animated:YES withLayoutChanges:nil];
    
}

- (UICollectionViewCell *)_cellForParticipantCollectionView:(UICollectionView *)collectionView atIndexPath:(NSIndexPath *)indexPath {
    
    HCRCollectionCell *cell;
    
    // initial vars
    HCRSurveyQuestion *surveyQuestion = [self _surveyQuestionForSection:indexPath.section inCollectionView:collectionView];
    HCRSurveyAnswerSetParticipantQuestion *participantQuestion = [self _participantQuestionForSection:indexPath.section inCollectionView:collectionView];
    
    // get answer
    HCRSurveyQuestionAnswer *answer;
    if (participantQuestion.answer) {
        // traditional answer
        answer = [surveyQuestion answerForAnswerCode:participantQuestion.answer];
    } else {
        // get answer for index
        NSArray *answerStrings = surveyQuestion.answers;
        answer = [answerStrings objectAtIndex:indexPath.row];
    }
    
    BOOL answered = (participantQuestion.answer != nil || participantQuestion.answerString != nil);
    BOOL freeformAnswer = [answer.freeform boolValue];
    
    if (surveyQuestion.freeformLabel ||
        freeformAnswer) {
        
        // FREE FORM CELL
        HCRSurveyAnswerFreeformCell *freeformCell =
        [collectionView dequeueReusableCellWithReuseIdentifier:kSurveyAnswerFreeformCellIdentifier
                                                  forIndexPath:indexPath];
        cell = freeformCell;
        
        freeformCell.participantView = (HCRSurveyParticipantView *)collectionView;
        freeformCell.answered = answered;
        
        NSString *labelTitle = (surveyQuestion.freeformLabel) ? surveyQuestion.freeformLabel : answer.string;
        freeformCell.labelTitle = [NSString stringWithFormat:@"%@:",[labelTitle capitalizedString]];
        freeformCell.inputPlaceholder = @"(tap here to answer)";
        freeformCell.inputField.text = participantQuestion.answerString;
        
        freeformCell.fieldType = HCRDataEntryFieldTypeNumber;
        freeformCell.dataDelegate = self;
        
        freeformCell.lastFieldInSeries = YES;
        
    } else {
        
        // NORMAL ANSWER CELL
        
        HCRSurveyAnswerCell *answerCell =
        [collectionView dequeueReusableCellWithReuseIdentifier:kSurveyAnswerCellIdentifier
                                                  forIndexPath:indexPath];
        cell = answerCell;
        
        answerCell.title = (participantQuestion.answerString) ? participantQuestion.answerString : answer.string;
        answerCell.answered = answered;
    }
    
    [cell setBottomLineStatusForCollectionView:collectionView atIndexPath:indexPath];
    
    return cell;
    
}

- (UICollectionViewCell *)_collectionViewSurveyForIndexPath:(NSIndexPath *)indexPath {
    
    HCRSurveyCell *surveyCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:kSurveyCellIdentifier
                                                                               forIndexPath:indexPath];
    
    surveyCell.participantDataSourceDelegate = self;
    surveyCell.participantID = @(indexPath.row);
    surveyCell.participantCollection.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    
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

- (HCRSurveyQuestion *)_surveyQuestionForSection:(NSInteger)section inCollectionView:(UICollectionView *)collectionView {
    
    HCRSurveyAnswerSetParticipantQuestion *question = [self _participantQuestionForSection:section inCollectionView:collectionView];
    return [[HCRDataManager sharedManager] surveyQuestionWithQuestionID:question.question];
    
}

- (NSString *)_questionStringForSection:(NSInteger)section inCollectionView:(UICollectionView *)collectionView {
    HCRSurveyQuestion *question = [self _surveyQuestionForSection:section inCollectionView:collectionView];
    NSString *questionNumber = question.questionCode;
    NSString *questionString = question.questionString;
    
    return [NSString stringWithFormat:@"%@: %@",questionNumber,questionString];
}

- (NSArray *)_answerIndexPathsForQuestion:(HCRSurveyQuestion *)question withParticipantResponse:(HCRSurveyAnswerSetParticipantQuestion *)response atSection:(NSInteger)section {
    
    NSMutableArray *indexPaths = @[].mutableCopy;
    
    for (HCRSurveyQuestionAnswer *answer in question.answers) {
        if (response &&
            answer.code != response.answer) {
            NSUInteger answerIndex = [question.answers indexOfObject:answer];
            NSIndexPath *deadIndexPath = [NSIndexPath indexPathForRow:answerIndex inSection:section];
            [indexPaths addObject:deadIndexPath];
        }
    }
    
    return indexPaths;
    
}

- (void)_surveyAnswerCellPressedInCollectionView:(UICollectionView *)collectionView AtIndexPath:(NSIndexPath *)indexPath withFreeformAnswer:(NSString *)freeformString {
    
    // get question and answer codes
    HCRSurveyQuestion *questionAnswered = [self _surveyQuestionForSection:indexPath.section inCollectionView:collectionView];
    NSString *questionCode = questionAnswered.questionCode;
    
    NSInteger participantID = [self _participantIDForSurveyView:collectionView];
    
    // TODO: figure out logic for when a blank freeform question is answered - how to UNSET it!
    
    // if answer already exists, unset it and reload info
    HCRSurveyAnswerSetParticipantQuestion *question = [self _participantQuestionForSection:indexPath.section inCollectionView:collectionView];
    if (question.answer) {
        
        [self _reloadData:YES
               inSections:[NSIndexSet indexSetWithIndex:indexPath.section]
       withCollectionView:collectionView
                 animated:YES
        withLayoutChanges:^{
            
            NSArray *indexPathsToAdd = [self _answerIndexPathsForQuestion:questionAnswered
                                                  withParticipantResponse:question
                                                                atSection:indexPath.section];
            
            [collectionView insertItemsAtIndexPaths:indexPathsToAdd];
            
            [[HCRDataManager sharedManager] removeAnswerForQuestion:questionCode withAnswerSetID:self.answerSetID withParticipantID:participantID];
            
        }];
        
    } else {
        
        HCRSurveyQuestionAnswer *answer = [questionAnswered.answers objectAtIndex:indexPath.row];
        
        [[HCRDataManager sharedManager] setAnswerCode:answer.code withFreeformString:freeformString forQuestion:questionCode withAnswerSetID:self.answerSetID withParticipantID:participantID];
        
        [self _reloadData:YES
               inSections:[NSIndexSet indexSetWithIndex:indexPath.section]
       withCollectionView:collectionView
                 animated:YES
        withLayoutChanges:^{
            
            NSArray *indexPathsToDelete = [self _answerIndexPathsForQuestion:questionAnswered
                                                     withParticipantResponse:question
                                                                   atSection:indexPath.section];
            
            [collectionView deleteItemsAtIndexPaths:indexPathsToDelete];
            
        }];
        
    }
    
}

@end
