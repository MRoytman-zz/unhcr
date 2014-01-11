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
#import "HCRParticipantToolbar.h"
#import "HCRSurveyQuestion.h"

#import <MBProgressHUD.h>

////////////////////////////////////////////////////////////////////////////////

@interface HCRSurveyController ()

@property CGRect keyboardBounds;
@property NSTimeInterval keyboardAnimationTime;
@property UIViewAnimationOptions keyboardAnimationOptions;

@property UITapGestureRecognizer *tapRecognizer;
@property UITextField *textFieldToDismiss;

@property UIBarButtonItem *doneBarButton;

@property BOOL selectingCell;

@property (nonatomic, strong) HCRSurveyAnswerSetParticipant *currentParticipant;

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
    
    self.title = @"Lebanon: Access to Care";
    
//    self.collectionView.scrollEnabled = NO;
    self.collectionView.backgroundColor = [UIColor tableBackgroundColor];
    self.collectionView.pagingEnabled = YES;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    
    // KEYBOARD AND INPUTS
    self.tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_dismissKeyboard)];
    [self.view addGestureRecognizer:self.tapRecognizer];
    
    self.tapRecognizer.cancelsTouchesInView = NO;
    
    // TOOLBAR
    HCRParticipantToolbar *toolbar = (HCRParticipantToolbar *)self.navigationController.toolbar;
    NSParameterAssert([toolbar isKindOfClass:[HCRParticipantToolbar class]]);
    
    toolbar.addParticipant.target = self;
    toolbar.addParticipant.action = @selector(_addParticipantButtonPressed);
    
    toolbar.nextParticipant.target = self;
    toolbar.nextParticipant.action = @selector(_nextParticipantButtonPressed);
    
    toolbar.previousParticipant.target = self;
    toolbar.previousParticipant.action = @selector(_previousParticipantButtonPressed);
    
    toolbar.removeParticipant.target = self;
    toolbar.removeParticipant.action = @selector(_removeParticipantButtonPressed);
    
    [toolbar.centerButton addTarget:self
                             action:@selector(_toolbarParticipantPressed:)
                   forControlEvents:UIControlEventTouchUpInside];
    
    // NOTIFICATIONS
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
    
    // test whether likely first load - if so, refresh
    if ([self.answerSet participantWithID:0].questions.count == 0) {
        [self _refreshModelDataForCollectionView:nil];
    }
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    HCRParticipantToolbar *toolbar = (HCRParticipantToolbar *)self.navigationController.toolbar;
    NSParameterAssert([toolbar isKindOfClass:[HCRParticipantToolbar class]]);
    
    if (!toolbar.currentParticipant) {
        // this means it's the first load - workaround for toolbar not loading in proper order
        self.currentParticipant = [self.answerSet participantWithID:0];
    }
    
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
            
            HCRSurveyQuestion *surveyQuestion = [self _surveyQuestionForSection:indexPath.section inCollectionView:collectionView];
            
            [header setSurveyQuestion:surveyQuestion
                      withParticipant:self.currentParticipant];
            
            header.questionAnswered = (question.answer != nil || question.answerString != nil);
            
            return header;
        } else if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
            HCRSurveyQuestionFooter *footer =
            [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                               withReuseIdentifier:kSurveyFooterIdentifier
                                                      forIndexPath:indexPath];
            
            BOOL bottomLine = (indexPath.section == collectionView.numberOfSections - 1);
            footer.showMSFLogo = bottomLine;
            
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
        HCRSurveyQuestion *question = [self _surveyQuestionForSection:section inCollectionView:collectionView];
        return [HCRSurveyQuestionHeader sizeForHeaderInCollectionView:(HCRSurveyParticipantView *)collectionView
                                                     withQuestionData:question
                                                      withParticipant:self.currentParticipant];
        
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
        BOOL bottomLine = (section == collectionView.numberOfSections - 1);
        
        return (bottomLine) ? [HCRSurveyQuestionFooter preferredFooterSizeForCollectionView:collectionView] : [HCRSurveyQuestionFooter preferredFooterSizeWithBottomLineOnlyForCollectionView:collectionView];
        
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
        UIToolbar *toolbar = self.navigationController.toolbar;
        UIEdgeInsets navigationInsets = UIEdgeInsetsMake(CGRectGetMinY(navBar.frame) + CGRectGetHeight(navBar.bounds),
                                                         0,
                                                         CGRectGetHeight(toolbar.bounds),
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

#pragma mark - UIScrollView

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    [self _updateCurrentParticipantWithActiveScrollView:scrollView];
    
}

//- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
//    
//    [self _updateCurrentParticipantWithActiveScrollView:scrollView];
//    
//}

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

- (void)setCurrentParticipant:(HCRSurveyAnswerSetParticipant *)currentParticipant {
    
    _currentParticipant = currentParticipant;
    
    // set data
    [self _refreshToolbarData];
    
    // slide to correct position..
    CGFloat screenWidth = CGRectGetWidth([UIScreen mainScreen].bounds);
    CGPoint targetOffset = CGPointMake(screenWidth * [self.answerSet.participants indexOfObject:currentParticipant],
                                       self.collectionView.contentOffset.y);

    [self.collectionView setContentOffset:targetOffset
                                 animated:YES];
    
    [self _refreshModelDataForParticipantID:currentParticipant.participantID.integerValue];
    
}

#pragma mark - Private Methods (Layout)

- (void)_refreshModelDataForCollectionView:(UICollectionView *)collectionView {
    
    if ([collectionView isKindOfClass:[HCRSurveyParticipantView class]]) {
        NSInteger participantID = [self _participantIDForSurveyView:collectionView];
        [self _refreshModelDataForParticipantID:participantID];
    } else {
        [[HCRDataManager sharedManager] refreshSurveyResponsesForAllParticipantsWithAnswerSet:self.answerSet];
    }
    
}

- (void)_refreshModelDataForParticipantID:(NSInteger)participantID {
    
    [[HCRDataManager sharedManager] refreshSurveyResponsesForParticipantID:participantID withAnswerSet:self.answerSet];
}

- (void)_reloadAllData {
    [self _reloadLayoutData:YES inSections:nil withCollectionView:self.collectionView animated:YES withLayoutChanges:nil];
}

- (void)_reloadLayoutData:(BOOL)reloadData inSections:(NSIndexSet *)sections withCollectionView:(UICollectionView *)collectionView animated:(BOOL)animated withLayoutChanges:(void (^)(void))layoutChanges {
    
    void (^percentCompleteCheck)(void) = ^{
        NSInteger percentComplete = [[HCRDataManager sharedManager] percentCompleteForAnswerSet:self.answerSet];
        [self _updateAnswersCompleted:(percentComplete == 100)];
    };
    
    // completion code (update UI, etc)
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

#pragma mark - Private Methods (Navigation)

- (void)_doneButtonPressed {
    
    [UIAlertView showConfirmationDialogWithTitle:@"Submit Survey"
                                         message:@"Are you sure you want to submit this survey? Once you submit the survey, you may not make any changes."
                                         handler:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                             
                                             if (buttonIndex != alertView.cancelButtonIndex) {
                                                 
                                                 [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                                                 
                                             }
                                             
                                         }];
    
}

- (void)_addParticipantButtonPressed {
    
    HCRSurveyAnswerSetParticipant *newParticipant = [[HCRDataManager sharedManager] createNewParticipantForAnswerSet:self.answerSet];
    
    [self _refreshModelDataForParticipantID:newParticipant.participantID.integerValue];
    [self _reloadAllData];
    
    self.currentParticipant = newParticipant;
    
}

- (void)_nextParticipantButtonPressed {
    
    HCRSurveyAnswerSetParticipant *participant = [self _nextParticipantFromCurrentParticipant];
    if (participant) {
        self.currentParticipant = participant;
    } else {
        NSAssert(NO, @"Should not be able to toggle to this participant!");
    }
    
}

- (void)_previousParticipantButtonPressed {
    
    HCRSurveyAnswerSetParticipant *participant = [self _previousParticipantFromCurrentParticipant];
    if (participant) {
        self.currentParticipant = participant;
    } else {
        NSAssert(NO, @"Should not be able to toggle to this participant!");
    }
    
}

- (void)_removeParticipantButtonPressed {
    
    if (self.answerSet.participants.count > 1) {
        
        NSIndexPath *oldIndexPath = [NSIndexPath indexPathForItem:[self.answerSet.participants indexOfObject:self.currentParticipant] inSection:0];
        HCRSurveyAnswerSetParticipant *oldParticipant = self.currentParticipant;
        
        HCRSurveyAnswerSetParticipant *nextParticipant = [self _nextParticipantFromCurrentParticipant];
        HCRSurveyAnswerSetParticipant *prevParticipant = [self _previousParticipantFromCurrentParticipant];
        
        HCRSurveyAnswerSetParticipant *newParticipant = (nextParticipant) ? nextParticipant : prevParticipant;
        
        if (!newParticipant) {
            newParticipant = [self.answerSet.participants objectAtIndex:0];
        }
        
        [[HCRDataManager sharedManager] removeParticipant:oldParticipant fromAnswerSet:self.answerSet];
        
        [self _refreshModelDataForCollectionView:self.collectionView];
        
        [self _reloadLayoutData:YES
                     inSections:[NSIndexSet indexSetWithIndex:0]
             withCollectionView:self.collectionView
                       animated:YES
              withLayoutChanges:^{
                  
                  [self.collectionView deleteItemsAtIndexPaths:@[oldIndexPath]];
                  
              }];
        
        // TODO: participant surveys are disappearing! nooo!
        self.currentParticipant = newParticipant;
        
    }
    
}

- (void)_refreshToolbarData {
    
    if (self.currentParticipant) {
        HCRParticipantToolbar *toolbar = (HCRParticipantToolbar *)self.navigationController.toolbar;
        NSParameterAssert([toolbar isKindOfClass:[HCRParticipantToolbar class]]);
        
        toolbar.participants = self.answerSet.participants;
        
        toolbar.currentParticipant = self.currentParticipant;
        
        // check for 100% completion
        NSInteger percentComplete = [[HCRDataManager sharedManager] percentCompleteForParticipantID:self.currentParticipant.participantID.integerValue withAnswerSet:self.answerSet];
        
        toolbar.backgroundColor = (percentComplete == 100) ? [UIColor flatGreenColor] : toolbar.defaultToolbarColor;
    }
    
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
        
        HCRDataEntryFieldType fieldType;
        
        if ([surveyQuestion.keyboard isEqualToString:HCRSurveyQuestionKeyboardNumberKey]) {
            fieldType = HCRDataEntryFieldTypeNumber;
        } else if ([surveyQuestion.keyboard isEqualToString:HCRSurveyQuestionKeyboardStringKey]) {
            fieldType = HCRDataEntryFieldTypeDefault;
        } else {
            NSAssert(NO, @"Unhandled keyboard field type!");
            fieldType = HCRDataEntryFieldTypeDefault;
        }
        
        freeformCell.fieldType = fieldType;
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
    
    cell.processingViewPosition = HCRCollectionCellProcessingViewPositionCenter;
    
    [cell setBottomLineStatusForCollectionView:collectionView atIndexPath:indexPath];
    
    return cell;
    
}

- (UICollectionViewCell *)_collectionViewSurveyForIndexPath:(NSIndexPath *)indexPath {
    
    HCRSurveyCell *surveyCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:kSurveyCellIdentifier
                                                                               forIndexPath:indexPath];
    
    HCRSurveyAnswerSetParticipant *participant = [self.answerSet.participants objectAtIndex:indexPath.row];
    
    surveyCell.participantDataSourceDelegate = self;
    surveyCell.participantID = participant.participantID;
    surveyCell.participantCollection.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    
    return surveyCell;
    
}

- (NSInteger)_participantIDForSurveyView:(UICollectionView *)collectionView {
    
    HCRSurveyParticipantView *surveyView = (HCRSurveyParticipantView *)collectionView;
    NSParameterAssert([surveyView isKindOfClass:[HCRSurveyParticipantView class]]);
    
    return surveyView.participantID.integerValue;
    
}

- (HCRSurveyAnswerSetParticipantQuestion *)_currentParticipantQuestionForSection:(NSInteger)section {
    
    // get question code
    return [self.currentParticipant.questions objectAtIndex:section];
    
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
        if (response && ![answer.code isEqualToNumber:response.answer]) {
            NSUInteger answerIndex = [question.answers indexOfObject:answer];
            NSIndexPath *deadIndexPath = [NSIndexPath indexPathForRow:answerIndex inSection:section];
            [indexPaths addObject:deadIndexPath];
        }
    }
    
    return indexPaths;
    
}

- (void)_updateCollectionView:(UICollectionView *)collectionView withOldQuestions:(NSArray *)oldQuestions {
    
    NSMutableIndexSet *indexesToDelete = [NSIndexSet indexSet].mutableCopy;
    NSMutableIndexSet *indexesToAdd = [NSIndexSet indexSet].mutableCopy;
    
    NSMutableArray *oldQuestionCodes = @[].mutableCopy;
    
    for (HCRSurveyAnswerSetParticipantQuestion *question in oldQuestions) {
        [oldQuestionCodes addObject:question.question];
    }
    
    // for all section questions, check if the participant has them
    for (NSString *questionCode in oldQuestionCodes) {
        
        // if not, add to delete
        if (![self.currentParticipant questionWithID:questionCode]) {
            [indexesToDelete addIndex:[oldQuestionCodes indexOfObject:questionCode]];
        }
        
    }
    
    // for all participant questions, check if section has them
    for (HCRSurveyAnswerSetParticipantQuestion *question in self.currentParticipant.questions) {
        
        // if not, add
        if (![oldQuestionCodes containsObject:question.question]) {
            [indexesToAdd addIndex:[self.currentParticipant.questions indexOfObject:question]];
        }
        
    }
    
    [collectionView deleteSections:indexesToDelete];
    [collectionView insertSections:indexesToAdd];
    
}

- (void)_surveyAnswerCellPressedInCollectionView:(UICollectionView *)collectionView AtIndexPath:(NSIndexPath *)indexPath withFreeformAnswer:(NSString *)freeformString {
    
    if (!self.selectingCell) {
        
        // set UI
        self.selectingCell = YES;
        
        HCRCollectionCell *answerCell = (HCRCollectionCell *)[collectionView cellForItemAtIndexPath:indexPath];
        NSParameterAssert([answerCell isKindOfClass:[HCRCollectionCell class]]);
        answerCell.processingAction = YES;
        
        // get question and answer codes
        HCRSurveyQuestion *questionAnswered = [self _surveyQuestionForSection:indexPath.section inCollectionView:collectionView];
        NSString *questionCode = questionAnswered.questionCode;
        
        NSInteger participantID = [self _participantIDForSurveyView:collectionView];
        NSArray *oldQuestions = [[self.answerSet participantWithID:participantID].questions copy];
        
        // if answer already exists, unset it and reload info
        HCRSurveyAnswerSetParticipantQuestion *question = [self _participantQuestionForSection:indexPath.section inCollectionView:collectionView];
        
        // get answer - by code if it's an existing answer, or by index if it's fresh
        HCRSurveyQuestionAnswer *answer = (question.answer) ? [questionAnswered answerForAnswerCode:question.answer] : [questionAnswered.answers objectAtIndex:indexPath.row];
        
        // if there is no freeform string AND there is no answer of any sort, remove it
        if (!freeformString &&
            (question.answer || question.answerString || answer.freeform.boolValue)) {
            
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            
            dispatch_async(queue, ^{
                
                // background code
                
                // if the cells are non-standard, reset 'em..
                NSArray *indexPathsToAdd;
                if ([collectionView numberOfItemsInSection:indexPath.section] != questionAnswered.answers.count) {
                    
                    indexPathsToAdd = [self _answerIndexPathsForQuestion:questionAnswered
                                                 withParticipantResponse:question
                                                               atSection:indexPath.section];
                    
                }
                
                // reload data
                [[HCRDataManager sharedManager] removeAnswerForQuestion:questionCode withAnswerSetID:self.answerSetID withParticipantID:participantID];
                [self _refreshModelDataForCollectionView:collectionView];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    // completion code (update UI, etc)
                    [self _reloadLayoutData:YES
                                 inSections:[NSIndexSet indexSetWithIndex:indexPath.section]
                         withCollectionView:collectionView
                                   animated:YES
                          withLayoutChanges:^{
                              
                              [collectionView insertItemsAtIndexPaths:indexPathsToAdd];
                              
                              if ([collectionView numberOfSections] != [self.answerSet participantWithID:participantID].questions.count) {
                                  [self _updateCollectionView:collectionView withOldQuestions:oldQuestions];
                              }
                              
                              self.selectingCell = NO;
                              answerCell.processingAction = NO;
                              
                          }];
                    
                });
                
            });
            
        } else {
            
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            
            dispatch_async(queue, ^{
                
                // background code
                [[HCRDataManager sharedManager] setAnswerCode:answer.code withFreeformString:freeformString forQuestion:questionCode withAnswerSetID:self.answerSetID withParticipantID:participantID];
                
                [self _refreshModelDataForCollectionView:collectionView];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    // completion code (update UI, etc)
                    [self _reloadLayoutData:YES
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
                              
                              if ([collectionView numberOfSections] != [self.answerSet participantWithID:participantID].questions.count) {
                                  [self _updateCollectionView:collectionView withOldQuestions:oldQuestions];
                              }
                              
                              self.selectingCell = NO;
                              answerCell.processingAction = NO;
                              
                          }];
                    
                });
                
            });
            
        }
        
    }
    
}

- (void)_dismissKeyboard {
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

- (void)_updateCurrentParticipantWithActiveScrollView:(UIScrollView *)scrollView {
    
    // only do this for the core collectionview
    if ([scrollView isKindOfClass:[HCRSurveyParticipantView class]]) {
        return;
    }
    
    CGFloat width = CGRectGetWidth(scrollView.bounds);
    NSInteger page = (scrollView.contentOffset.x + 0.5 * width) / width;
    
    if (self.currentParticipant.participantID.integerValue != page) {
        self.currentParticipant = [self.answerSet.participants objectAtIndex:page];
    }
    
}

- (void)_toolbarParticipantPressed:(UIButton *)toolbarButton {
    
    if (self.currentParticipant) {
        
        NSIndexPath *indexPath = [self _indexPathForCurrentParticipantFirstUnansweredQuestion];
        
        if (indexPath) {
            
            HCRSurveyCell *surveyCell = [self _surveyCellForCurrectParticipant];
            
            [surveyCell.participantCollection scrollToItemAtIndexPath:indexPath
                                                     atScrollPosition:UICollectionViewScrollPositionCenteredVertically
                                                             animated:YES];
        }
        
    }
    
}

- (NSIndexPath *)_indexPathForCurrentParticipantFirstUnansweredQuestion {
    
    HCRSurveyAnswerSetParticipantQuestion *unanasweredQuestion = [self.currentParticipant firstUnansweredQuestion];
    
    for (HCRSurveyAnswerSetParticipantQuestion *question in self.currentParticipant.questions) {
        if (question == unanasweredQuestion) {
            
            return [NSIndexPath indexPathForItem:0
                                       inSection:[self.currentParticipant.questions indexOfObject:question]];
            
        }
    }
    
    return nil;
}

- (HCRSurveyCell *)_surveyCellForCurrectParticipant {
    
    NSIndexPath *indexPathForSurvey =
    [NSIndexPath indexPathForItem:[self.answerSet.participants indexOfObject:self.currentParticipant]
                        inSection:0];
    
    HCRSurveyCell *survey = (HCRSurveyCell *)[self.collectionView cellForItemAtIndexPath:indexPathForSurvey];
    NSParameterAssert([survey isKindOfClass:[HCRSurveyCell class]]);
    
    return survey;
    
}

- (HCRSurveyAnswerSetParticipant *)_nextParticipantFromCurrentParticipant {
    
    NSInteger indexOfNextParticipant = [self.answerSet.participants indexOfObject:self.currentParticipant] + 1;
    
    if (indexOfNextParticipant <= self.answerSet.participants.count - 1) {
        return [self.answerSet.participants objectAtIndex:indexOfNextParticipant];
    } else {
        return nil;
    }
}

- (HCRSurveyAnswerSetParticipant *)_previousParticipantFromCurrentParticipant {
    
    NSInteger indexOfPreviousParticipant = [self.answerSet.participants indexOfObject:self.currentParticipant] - 1;
    
    if (indexOfPreviousParticipant >= 0) {
        return [self.answerSet.participants objectAtIndex:indexOfPreviousParticipant];
    } else {
        return nil;
    }
}

@end
