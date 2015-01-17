//
//  HCRAlertsViewController.m
//  UNHCR
//
//  Created by Sean Conrad on 10/7/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCREmergencyListViewController.h"
#import "HCREmergencyCell.h"
#import "HCRTableFlowLayout.h"
#import "HCREmergencyBroadcastController.h"
#import "EAEmailUtilities.h"

////////////////////////////////////////////////////////////////////////////////

NSString *const kEmergencyCellIdentifier = @"kEmergencyCellIdentifier";
NSString *const kEmergencyHeaderIdentifier = @"kEmergencyHeaderIdentifier";
NSString *const kEmergencyFooterIdentifier = @"kEmergencyFooterIdentifier";

////////////////////////////////////////////////////////////////////////////////

@interface HCREmergencyListViewController ()

@property (nonatomic, strong) NSArray *emergenciesList;

@end

////////////////////////////////////////////////////////////////////////////////

@implementation HCREmergencyListViewController

- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        // Custom initialization
        self.emergenciesList = [HCRDataSource globalEmergenciesData];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.title = @"Emergencies";
    
    // LAYOUT AND REUSABLES
    HCRTableFlowLayout *tableLayout = (HCRTableFlowLayout *)self.collectionView.collectionViewLayout;
    NSParameterAssert([tableLayout isKindOfClass:[HCRTableFlowLayout class]]);
    
    [tableLayout setDisplayHeader:YES withSize:[HCRHeaderView preferredHeaderSizeWithoutTitleForCollectionView:self.collectionView]];
    
    [self.collectionView registerClass:[HCREmergencyCell class]
            forCellWithReuseIdentifier:kEmergencyCellIdentifier];
    
    [self.collectionView registerClass:[HCRHeaderView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:kEmergencyHeaderIdentifier];
    
    [self.collectionView registerClass:[HCRFooterView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                   withReuseIdentifier:kEmergencyFooterIdentifier];
    
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

#pragma mark - UICollectionView

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.emergenciesList.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HCREmergencyCell *emergencyCell = [collectionView dequeueReusableCellWithReuseIdentifier:kEmergencyCellIdentifier
                                                                        forIndexPath:indexPath];
    
    emergencyCell.emergencyDictionary = [self.emergenciesList objectAtIndex:indexPath.section ofClass:@"NSDictionary"];
    
    emergencyCell.emailContactButton.tag = indexPath.section;
    [emergencyCell.emailContactButton addTarget:self
                                         action:@selector(_emergencyEmailButtonPressed:)
                               forControlEvents:UIControlEventTouchUpInside];
    
    [emergencyCell setBottomLineStatusForCollectionView:collectionView atIndexPath:indexPath];
    
    return emergencyCell;
    
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        
        HCRHeaderView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                   withReuseIdentifier:kEmergencyHeaderIdentifier
                                                                          forIndexPath:indexPath];
        
        return header;
        
    } else if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        
        HCRFooterView *footer = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                                                   withReuseIdentifier:kEmergencyFooterIdentifier
                                                                          forIndexPath:indexPath];
        
        return footer;
        
    }
    
    return nil;
    
}

#pragma mark - UICollectionView Delegate Flow Layout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return [HCREmergencyCell sizeForCellInCollectionView:collectionView withEmergencyDictionary:[self.emergenciesList objectAtIndex:indexPath.section ofClass:@"NSDictionary"]];
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    
    return (section == ([collectionView numberOfSections] - 1)) ? [HCRFooterView preferredFooterSizeForCollectionView:collectionView] : [HCRFooterView preferredFooterSizeWithBottomLineOnlyForCollectionView:self.collectionView];
    
}

#pragma mark - Private Methods

- (void)_composeButtonPressed {
    
    HCREmergencyBroadcastController *broadcastController = [[HCREmergencyBroadcastController alloc] initWithCollectionViewLayout:[HCREmergencyBroadcastController preferredLayout]];
    
    [self presentViewController:broadcastController animated:YES completion:nil];
    
}

- (void)_emergencyEmailButtonPressed:(UIButton *)emailButton {
    
    NSDictionary *emergencyDictionary = [self.emergenciesList objectAtIndex:emailButton.tag ofClass:@"NSDictionary"];
    [[EAEmailUtilities sharedUtilities] emailFromViewController:self
                                        withEmergencyDictionary:emergencyDictionary
                                                 withCompletion:nil];
    
}

@end
