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

#import <MBProgressHUD.h>

////////////////////////////////////////////////////////////////////////////////

@interface HCRSurveyController ()

@property CGRect keyboardBounds;
@property NSTimeInterval keyboardAnimationTime;
@property UIViewAnimationOptions keyboardAnimationOptions;

@property UITapGestureRecognizer *tapRecognizer;
@property UITextField *textFieldToDismiss;

@property UIBarButtonItem *doneBarButton;

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
    
    // KEYBOARD AND INPUTS
    self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_dismissKeyboard)];
    [self.view addGestureRecognizer:self.tapRecognizer];
    
    self.tapRecognizer.cancelsTouchesInView = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    // LAYOUT AND REUSABLES
    [self.collectionView registerClass:[HCRSurveyCell class]
            forCellWithReuseIdentifier:kSurveyCellIdentifier];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // refresh on load
    [self _refreshModelData];
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
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
    
    self.textFieldToDismiss = signInCell.inputField;
    
    // position text field / collection view
    HCRSurveyAnswerFreeformCell *freeformCell = (HCRSurveyAnswerFreeformCell *)signInCell;
    NSParameterAssert([freeformCell isKindOfClass:[HCRSurveyAnswerFreeformCell class]]);
    
    // next loop so keyboard data populates
    dispatch_async(dispatch_get_main_queue(), ^{
        
        CGFloat yTarget = CGRectGetMinY(freeformCell.frame) + CGRectGetMidY(freeformCell.bounds);
        CGFloat midPoint = 0.5 * (CGRectGetHeight(freeformCell.participantView.bounds) - CGRectGetHeight(self.keyboardBounds));
        
        [UIView animateWithDuration:self.keyboardAnimationTime
                              delay:0
                            options:self.keyboardAnimationOptions
                         animations:^{
                             [freeformCell.participantView setContentOffset:CGPointMake(0, yTarget - midPoint)];
                         } completion:nil];
        
    });
    
}

- (void)dataEntryFieldCellDidPressDone:(HCRDataEntryFieldCell *)signInCell {
    
    [signInCell.inputField resignFirstResponder];
    
}

- (void)dataEntryFieldCellDidResignFirstResponder:(HCRDataEntryFieldCell *)signInCell {
    
    self.textFieldToDismiss = nil;
    
    HCRSurveyAnswerFreeformCell *freeformCell = (HCRSurveyAnswerFreeformCell *)signInCell;
    NSParameterAssert([freeformCell isKindOfClass:[HCRSurveyAnswerFreeformCell class]]);
    
    NSIndexPath *cellIndexPath = [freeformCell.participantView indexPathForCell:freeformCell];
    
    [self _surveyAnswerCellPressedInCollectionView:freeformCell.participantView AtIndexPath:cellIndexPath withFreeformAnswer:(signInCell.inputField.text.length > 0) ? signInCell.inputField.text : nil];
    
    // next loop so cells are regenerated
    dispatch_async(dispatch_get_main_queue(), ^{
        
        CGFloat yTarget = CGRectGetMinY(freeformCell.frame) + CGRectGetMidY(freeformCell.bounds);
        CGFloat midPoint = 0.33 * CGRectGetHeight(freeformCell.participantView.bounds);
        
        [UIView animateWithDuration:self.keyboardAnimationTime
                              delay:0
                            options:self.keyboardAnimationOptions
                         animations:^{
                             [freeformCell.participantView setContentOffset:CGPointMake(0, yTarget - midPoint)];
                         } completion:nil];
        
    });
    
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

#pragma mark - Private Methods (Layout)

- (void)_reloadAllData {
    [self _reloadData:YES inSections:nil withCollectionView:self.collectionView animated:NO withLayoutChanges:nil];
}

- (void)_reloadData:(BOOL)reloadData inSections:(NSIndexSet *)sections withCollectionView:(UICollectionView *)collectionView animated:(BOOL)animated withLayoutChanges:(void (^)(void))layoutChanges {
    
    void (^percentCompleteCheck)(void) = ^{
        NSInteger percentComplete = [[HCRDataManager sharedManager] percentCompleteForAnswerSet:self.answerSet];
        [self _updateAnswersCompleted:(percentComplete == 100)];
    };
    
    if (animated == NO ||
        (reloadData && !layoutChanges)) {
        [collectionView reloadData];
        
        percentCompleteCheck();
        
    }
    
    if (layoutChanges) {
        [collectionView performBatchUpdates:layoutChanges completion:^(BOOL finished) {
            if (reloadData) {
                if (sections) {
                    [collectionView reloadSections:sections];
                    percentCompleteCheck();
                } else {
                    [collectionView reloadData];
                    percentCompleteCheck();
                }
            }
        }];
    }
    
}

- (void)_refreshModelData {
    
    [[HCRDataManager sharedManager] refreshSurveyResponsesForAllParticipantsWithAnswerSet:self.answerSet];
    
    [self _reloadData:YES inSections:nil withCollectionView:self.collectionView animated:YES withLayoutChanges:nil];
    
}

#pragma mark - Private Methods (Keyboard)

- (void)_keyboardWillShow:(NSNotification *)notification {
    NSDictionary *dictionary = notification.userInfo;
    self.keyboardBounds = [[dictionary objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    self.keyboardAnimationTime = [[dictionary objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    self.keyboardAnimationOptions = [[dictionary objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue] << 16;
}

- (void)_keyboardWillHide:(NSNotification *)notification {
    NSDictionary *dictionary = notification.userInfo;
    self.keyboardBounds = [[dictionary objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    self.keyboardAnimationTime = [[dictionary objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    self.keyboardAnimationOptions = [[dictionary objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue] << 16;
}

#pragma mark - Private Methods

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
        
        freeformCell.fieldType = (freeformAnswer) ? HCRDataEntryFieldTypeDefault : HCRDataEntryFieldTypeNumber;
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
    
    // if answer already exists, unset it and reload info
    HCRSurveyAnswerSetParticipantQuestion *question = [self _participantQuestionForSection:indexPath.section inCollectionView:collectionView];
    
    // get answer - by code if it's an existing answer, or by index if it's fresh
    HCRSurveyQuestionAnswer *answer = (question.answer) ? [questionAnswered answerForAnswerCode:question.answer] : [questionAnswered.answers objectAtIndex:indexPath.row];
    
    // if there is no freeform string AND there is no answer of any sort, remove it
    if (!freeformString &&
        (question.answer || question.answerString || answer.freeform.boolValue)) {
        
        [self _reloadData:YES
               inSections:[NSIndexSet indexSetWithIndex:indexPath.section]
       withCollectionView:collectionView
                 animated:YES
        withLayoutChanges:^{
            
            // if the cells are non-standard, reset 'em..
            if ([collectionView numberOfItemsInSection:indexPath.section] != questionAnswered.answers.count) {
                
                NSArray *indexPathsToAdd = [self _answerIndexPathsForQuestion:questionAnswered
                                                      withParticipantResponse:question
                                                                    atSection:indexPath.section];
                
                [collectionView insertItemsAtIndexPaths:indexPathsToAdd];
                
            }
            
            [[HCRDataManager sharedManager] removeAnswerForQuestion:questionCode withAnswerSetID:self.answerSetID withParticipantID:participantID];
            
        }];
        
    } else {
        
        [[HCRDataManager sharedManager] setAnswerCode:answer.code withFreeformString:freeformString forQuestion:questionCode withAnswerSetID:self.answerSetID withParticipantID:participantID];
        
        [self _reloadData:YES
               inSections:[NSIndexSet indexSetWithIndex:indexPath.section]
       withCollectionView:collectionView
                 animated:YES
        withLayoutChanges:^{
            
            // if the cells appear normal, remove some
            if ([collectionView numberOfItemsInSection:indexPath.section] == questionAnswered.answers.count) {
                
                NSArray *indexPathsToDelete = [self _answerIndexPathsForQuestion:questionAnswered
                                                         withParticipantResponse:question
                                                                       atSection:indexPath.section];
                
                [collectionView deleteItemsAtIndexPaths:indexPathsToDelete];
                
            }
            
        }];
        
    }
    
}

- (void)_dismissKeyboard {
    HCRDebug(@"tapped!");
    [self.textFieldToDismiss resignFirstResponder];
    self.textFieldToDismiss = nil;
}

- (void)_updateAnswersCompleted:(BOOL)allAnswersComplete {
    
    if (!self.doneBarButton) {
        self.doneBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                           target:self
                                                                           action:@selector(_doneButtonPressed)];
    }
    
    UIBarButtonItem *newItem = (allAnswersComplete) ? self.doneBarButton : nil;
    
    [self.navigationItem setRightBarButtonItem:newItem animated:YES];
    
}

- (void)_doneButtonPressed {
    
    [UIAlertView showConfirmationDialogWithTitle:@"Submit Survey"
                                         message:@"Are you sure you want to submit this survey? Once you submit the survey, you may not make any changes."
                                         handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                             
                                             if (buttonIndex != alertView.cancelButtonIndex) {
                                                 
                                                 [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                                                 
                                             }
                                             
                                         }];
    
}

@end
