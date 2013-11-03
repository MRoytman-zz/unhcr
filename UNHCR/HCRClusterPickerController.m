//
//  HCRCampDetailController.m
//  UNHCR
//
//  Created by Sean Conrad on 10/1/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import <MapKit/MapKit.h>

#import "HCRClusterPickerController.h"
#import "HCRClusterFlowLayout.h"
#import "HCRClusterPickerCell.h"
#import "HCRClusterToolsViewController.h"
#import "HCRHeaderView.h"
#import "HCRFooterView.h"

////////////////////////////////////////////////////////////////////////////////

NSString *const kClusterCellIdentifier = @"kClusterCellIdentifier";
NSString *const kClusterHeaderIdentifier = @"kClusterHeaderIdentifier";
NSString *const kClusterFooterIdentifier = @"kClusterFooterIdentifier";

////////////////////////////////////////////////////////////////////////////////

@interface HCRClusterPickerController ()

@end

////////////////////////////////////////////////////////////////////////////////

@implementation HCRClusterPickerController

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
    
    NSParameterAssert(self.campDictionary);
    
    // TODO: background displays in white; make collection a single cell of a larger table collection? easier to show footer that way, too.
    
    self.title = [self.campDictionary objectForKey:@"Name"];
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    HCRClusterFlowLayout *clusterLayout = (HCRClusterFlowLayout *)self.collectionView.collectionViewLayout;
    NSParameterAssert([clusterLayout isKindOfClass:[HCRClusterFlowLayout class]]);
    [clusterLayout setDisplayHeader:YES withSize:[HCRHeaderView preferredHeaderSizeForCollectionView:self.collectionView]];
    [clusterLayout setDisplayFooter:YES withSize:[HCRFooterView preferredFooterSizeForCollectionView:self.collectionView]];
    
    [self.collectionView registerClass:[HCRClusterPickerCell class]
            forCellWithReuseIdentifier:kClusterCellIdentifier];
    
    [self.collectionView registerClass:[HCRHeaderView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:kClusterHeaderIdentifier];
    
    [self.collectionView registerClass:[HCRFooterView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                   withReuseIdentifier:kClusterFooterIdentifier];
    
}

#pragma mark - Class Methods

+ (UICollectionViewLayout *)preferredLayout {
    return [[HCRClusterFlowLayout alloc] init];
}

#pragma mark - UICollectionView Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [HCRDataSource clusterLayoutMetaDataArray].count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HCRClusterPickerCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:kClusterCellIdentifier forIndexPath:indexPath];
    
    NSArray *clustersArray = [HCRDataSource clusterLayoutMetaDataArray];
    cell.clusterDictionary = [clustersArray objectAtIndex:indexPath.row];
    
    return cell;
    
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        
        HCRHeaderView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                   withReuseIdentifier:kClusterHeaderIdentifier
                                                                          forIndexPath:indexPath];
        
        header.titleString = @"Clusters";
        
        return header;
        
    } else if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        
        HCRFooterView *footer = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                                                   withReuseIdentifier:kClusterFooterIdentifier
                                                                          forIndexPath:indexPath];
        
        CGSize buttonSize = CGSizeMake(180, CGRectGetHeight(footer.bounds));
        UIButton *footerButton = [UIButton buttonWithUNHCRTextStyleWithString:@"Compare Clusters"
                                                          horizontalAlignment:UIControlContentHorizontalAlignmentCenter
                                                                         buttonSize:buttonSize
                                                                     fontSize:@16.0];
        [footer addSubview:footerButton];
        
        footerButton.center = CGPointMake(CGRectGetMidX(footer.bounds), CGRectGetMidY(footer.bounds));
        
        [footerButton addTarget:self
                         action:@selector(_footerButtonPressed)
               forControlEvents:UIControlEventTouchUpInside];
        
        return footer;
        
    }
    
    return nil;
    
}

#pragma mark - UICollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HCRClusterToolsViewController *campClusterDetail = [[HCRClusterToolsViewController alloc] initWithCollectionViewLayout:[HCRClusterToolsViewController preferredLayout]];
    
    [self.navigationController pushViewController:campClusterDetail animated:YES];
    
}

#pragma mark - Private Methods

- (void)_footerButtonPressed {
    
//    HCRRequestsDataViewController *campClusterCompareController = [[HCRRequestsDataViewController alloc] initWithCollectionViewLayout:[HCRRequestsDataViewController preferredLayout]];
//    campClusterCompareController.campDictionary = self.campDictionary;
//    
//    [self.navigationController pushViewController:campClusterCompareController animated:YES];
    
}

@end
