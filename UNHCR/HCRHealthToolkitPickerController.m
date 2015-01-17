//
//  HCRHealthTallySheetViewController.m
//  UNHCR
//
//  Created by Sean Conrad on 10/6/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRHealthToolkitPickerController.h"
#import "HCRTableFlowLayout.h"
#import "HCRTableButtonCell.h"
#import "HCRTallySheetDetailViewController.h"

////////////////////////////////////////////////////////////////////////////////

NSString *const kHealthToolkitCellIdentifier = @"kHealthToolkitCellIdentifier";
NSString *const kHealthToolkitHeaderIdentifier = @"kHealthToolkitHeaderIdentifier";
NSString *const kHealthToolkitFooterIdentifier = @"kHealthToolkitFooterIdentifier";

////////////////////////////////////////////////////////////////////////////////

@interface HCRHealthToolkitPickerController ()

@end

////////////////////////////////////////////////////////////////////////////////

@implementation HCRHealthToolkitPickerController

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
    
    NSParameterAssert(self.campClusterData);
    
    self.highlightCells = YES;
    
    HCRTableFlowLayout *tableLayout = (HCRTableFlowLayout *)self.collectionView.collectionViewLayout;
    NSParameterAssert([tableLayout isKindOfClass:[HCRTableFlowLayout class]]);
    [tableLayout setDisplayHeader:YES withSize:[HCRHeaderView preferredHeaderSizeForCollectionView:self.collectionView]];
    
    [self.collectionView registerClass:[HCRTableButtonCell class]
            forCellWithReuseIdentifier:kHealthToolkitCellIdentifier];
    
    [self.collectionView registerClass:[HCRHeaderView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:kHealthToolkitHeaderIdentifier];
    
    [self.collectionView registerClass:[HCRFooterView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                   withReuseIdentifier:kHealthToolkitFooterIdentifier];
    
}

#pragma mark - Class Methods

+ (UICollectionViewLayout *)preferredLayout {
    return [[HCRTableFlowLayout alloc] init];
}

#pragma mark - UICollectionView Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    NSArray *tallySheets = [self.campClusterData objectForKey:@"TallySheets" ofClass:@"NSArray"];
    return tallySheets.count;
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HCRTableButtonCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kHealthToolkitCellIdentifier
                                                                         forIndexPath:indexPath];
    
    NSArray *tallySheets = [self.campClusterData objectForKey:@"TallySheets" ofClass:@"NSArray"];
    NSDictionary *sheet = [tallySheets objectAtIndex:indexPath.row ofClass:@"NSDictionary"];
    
    cell.tableButtonTitle = [sheet objectForKey:@"Name" ofClass:@"NSString"];
    
    [cell setBottomLineStatusForCollectionView:collectionView atIndexPath:indexPath];
    
    return cell;
    
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        
        HCRHeaderView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                   withReuseIdentifier:kHealthToolkitHeaderIdentifier
                                                                          forIndexPath:indexPath];
        
        header.titleString = @"Tally Sheets";
        
        return header;
        
    } else if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        
        HCRFooterView *footer = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                                                   withReuseIdentifier:kHealthToolkitFooterIdentifier
                                                                          forIndexPath:indexPath];
        
        return footer;
        
    }
    
    return nil;
    
}

#pragma mark - UICollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HCRTallySheetDetailViewController *tallyDetail = [[HCRTallySheetDetailViewController alloc] initWithCollectionViewLayout:[HCRTallySheetDetailViewController preferredLayout]];
    
    NSArray *tallySheets = [self.campClusterData objectForKey:@"TallySheets" ofClass:@"NSArray"];
    
    tallyDetail.tallySheetData = [tallySheets objectAtIndex:indexPath.row ofClass:@"NSDictionary"];
    
    UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:tallyDetail];
    
    [self presentViewController:navigation animated:YES completion:nil];
    
}

#pragma mark - UICollectionView Delegate Flow Layout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    
    if (section == [collectionView numberOfSections] - 1) {
        return [HCRFooterView preferredFooterSizeForCollectionView:collectionView];
    }
    
    return [HCRFooterView preferredFooterSizeWithBottomLineOnlyForCollectionView:collectionView];
    
}

@end
