//
//  HCRBulletinViewController.m
//  UNHCR
//
//  Created by Sean Conrad on 10/30/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRBulletinViewController.h"
#import "HCRTableFlowLayout.h"
#import "HCRBulletinCell.h"
#import "HCREmergencyCell.h"
#import "EAEmailUtilities.h"

////////////////////////////////////////////////////////////////////////////////

NSString *const kBulletinCellIdentifier = @"kBulletinCellIdentifier";
NSString *const kBulletinHeaderIdentifier = @"kBulletinHeaderIdentifier";
NSString *const kBulletinFooterIdentifier = @"kBulletinFooterIdentifier";

NSString *const kBulletinEmergencyCellIdentifier = @"kBulletinEmergencyCellIdentifier";

////////////////////////////////////////////////////////////////////////////////

@interface HCRBulletinViewController ()

@property NSArray *bulletinArray;

@end

////////////////////////////////////////////////////////////////////////////////

@implementation HCRBulletinViewController

- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        // Custom initialization
        self.bulletinArray = [HCRDataSource globalAllBulletinsData];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.title = @"Bulletin Board";
    
    // LAYOUT AND REUSABLES
//    HCRTableFlowLayout *tableLayout = (HCRTableFlowLayout *)self.collectionView.collectionViewLayout;
//    NSParameterAssert([tableLayout isKindOfClass:[HCRTableFlowLayout class]]);
    
    [self.collectionView registerClass:[HCREmergencyCell class]
            forCellWithReuseIdentifier:kBulletinEmergencyCellIdentifier];
    
    [self.collectionView registerClass:[HCRBulletinCell class]
            forCellWithReuseIdentifier:kBulletinCellIdentifier];
    
    [self.collectionView registerClass:[HCRHeaderView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:kBulletinHeaderIdentifier];
    
    [self.collectionView registerClass:[HCRFooterView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                   withReuseIdentifier:kBulletinFooterIdentifier];
    
    // BAR BUTTONS
    UIBarButtonItem *composeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                                                                   target:self
                                                                                   action:@selector(_composeButtonPressed)];
    [self.navigationItem setRightBarButtonItem:composeButton];
}

#pragma mark - Class Methods

+ (UICollectionViewLayout *)preferredLayout {
    return [[HCRTableFlowLayout alloc] init];
}

#pragma mark - UICollectionView Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.bulletinArray.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HCRCollectionCell *cell;
    
    NSDictionary *cellDictionary = [self.bulletinArray objectAtIndex:indexPath.section ofClass:@"NSDictionary"];
    
    if ([self _emergencyStatusForBulletinAtIndexPath:indexPath]) {
        HCREmergencyCell *emergencyCell = [collectionView dequeueReusableCellWithReuseIdentifier:kBulletinEmergencyCellIdentifier
                                                                                    forIndexPath:indexPath];
        
        emergencyCell.emergencyDictionary = cellDictionary;
        
        emergencyCell.emailContactButton.tag = indexPath.section;
        [emergencyCell.emailContactButton addTarget:self
                                             action:@selector(_emergencyEmailButtonPressed:)
                                   forControlEvents:UIControlEventTouchUpInside];
        
        cell = emergencyCell;
    } else {
        HCRBulletinCell *bulletinCell = [collectionView dequeueReusableCellWithReuseIdentifier:kBulletinCellIdentifier
                                                                                  forIndexPath:indexPath];
        bulletinCell.bulletinDictionary = cellDictionary;
        
        bulletinCell.replyButton.tag = indexPath.section;
        bulletinCell.forwardButton.tag = indexPath.section;
        
        [bulletinCell.replyButton addTarget:self
                                     action:@selector(_replyButtonPressed:)
                           forControlEvents:UIControlEventTouchUpInside];
        
        [bulletinCell.forwardButton addTarget:self
                                       action:@selector(_forwardButtonPressed:)
                             forControlEvents:UIControlEventTouchUpInside];
        
        cell = bulletinCell;
    }
    
    [cell setBottomLineStatusForCollectionView:collectionView atIndexPath:indexPath];
    
    return cell;
    
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        
        HCRHeaderView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                   withReuseIdentifier:kBulletinHeaderIdentifier
                                                                          forIndexPath:indexPath];
        
        if (indexPath.section == 0) {
            header.titleString = @"Domiz, Iraq";
        }
        
        return header;
        
    } else if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        
        HCRFooterView *footer = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                                                   withReuseIdentifier:kBulletinFooterIdentifier
                                                                          forIndexPath:indexPath];
        
        return footer;
        
    }
    
    return nil;
    
}

#pragma mark - UICollectionView Delegate Flow Layout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    
    if (section == 0) {
        return [HCRHeaderView preferredHeaderSizeForCollectionView:collectionView];
    } else {
        return [HCRHeaderView preferredHeaderSizeWithLineOnlyForCollectionView:collectionView];
    }
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    return [HCRFooterView preferredFooterSizeForCollectionView:collectionView];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *cellDictionary = [self.bulletinArray objectAtIndex:indexPath.section ofClass:@"NSDictionary"];
    
    if ([self _emergencyStatusForBulletinAtIndexPath:indexPath]) {
        return [HCREmergencyCell sizeForCellInCollectionView:collectionView withEmergencyDictionary:cellDictionary];
    } else; {
        return [HCRBulletinCell sizeForCellInCollectionView:collectionView withBulletinDictionary:cellDictionary];
    }
    
}

#pragma mark - Private Methods

- (void)_composeButtonPressed {
    // TODO: compose
}

- (BOOL)_emergencyStatusForBulletinAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *cellDictionary = [self.bulletinArray objectAtIndex:indexPath.section ofClass:@"NSDictionary"];
    
    return [[cellDictionary objectForKey:@"Emergency" ofClass:@"NSNumber" mustExist:NO] boolValue];
    
}

- (void)_replyButtonPressed:(UIButton *)sender {
    
    HCRBulletinCell *bulletinCell = (HCRBulletinCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:sender.tag]];
    
    [[EAEmailUtilities sharedUtilities] emailFromViewController:self
                                               withToRecipients:@[[bulletinCell emailSenderString]]
                                                withSubjectText:[bulletinCell emailSubjectStringWithPrefix:@"[RIS] RE:"]
                                                   withBodyText:[bulletinCell emailBodyString]
                                                 withCompletion:nil];
    
}

- (void)_forwardButtonPressed:(UIButton *)sender {
    
    HCRBulletinCell *bulletinCell = (HCRBulletinCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:sender.tag]];
    
    [[EAEmailUtilities sharedUtilities] emailFromViewController:self
                                               withToRecipients:nil
                                                withSubjectText:[bulletinCell emailSubjectStringWithPrefix:@"[RIS] FWD:"]
                                                   withBodyText:[bulletinCell emailBodyString]
                                                 withCompletion:nil];
    
}

- (void)_emergencyEmailButtonPressed:(UIButton *)emailButton {
    
    NSDictionary *emergencyDictionary = [self.bulletinArray objectAtIndex:emailButton.tag ofClass:@"NSDictionary"];
    [[EAEmailUtilities sharedUtilities] emailFromViewController:self
                                        withEmergencyDictionary:emergencyDictionary
                                                 withCompletion:nil];
    
}

@end
