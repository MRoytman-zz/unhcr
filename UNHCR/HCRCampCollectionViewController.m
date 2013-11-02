//
//  HCRCampCollectionViewController.m
//  UNHCR
//
//  Created by Sean Conrad on 9/30/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import <MapKit/MapKit.h>

#import "HCRCampCollectionViewController.h"
#import "HCRTableFlowLayout.h"
#import "HCRClusterCollectionController.h"
#import "HCRHeaderView.h"
#import "HCRFooterView.h"
#import "HCRTableCell.h"
#import "HCRCampOverviewController.h"

////////////////////////////////////////////////////////////////////////////////

NSString *const kCampCellIdentifier = @"kCampCellIdentifier";
NSString *const kCampHeaderReuseIdentifier = @"kCampHeaderReuseIdentifier";
NSString *const kCampFooterReuseIdentifier = @"kCampFooterReuseIdentifier";

////////////////////////////////////////////////////////////////////////////////

@interface HCRCampCollectionViewController ()

@property NSArray *campDataArray;

@end

////////////////////////////////////////////////////////////////////////////////

@implementation HCRCampCollectionViewController

- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        // Custom initialization
        self.campDataArray = [HCRDataSource globalCampDataArray];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.title = @"Refugee Camps";
    
    self.highlightCells = YES;
    
    HCRTableFlowLayout *tableLayout = (HCRTableFlowLayout *)self.collectionView.collectionViewLayout;
    NSParameterAssert([tableLayout isKindOfClass:[HCRTableFlowLayout class]]);
    [tableLayout setDisplayHeader:YES withSize:[HCRHeaderView preferredHeaderSizeForCollectionView:self.collectionView]];
    [tableLayout setDisplayFooter:YES withSize:[HCRFooterView preferredFooterSizeWithBottomLineOnlyForCollectionView:self.collectionView]];
    
    [self.collectionView registerClass:[HCRTableCell class]
            forCellWithReuseIdentifier:kCampCellIdentifier];
    
    [self.collectionView registerClass:[HCRHeaderView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:kCampHeaderReuseIdentifier];
    
    [self.collectionView registerClass:[HCRFooterView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                   withReuseIdentifier:kCampFooterReuseIdentifier];    
    
}

#pragma mark - Class Methods

+ (UICollectionViewLayout *)preferredLayout {
    return [[HCRTableFlowLayout alloc] init];
}

#pragma mark - UICollectionViewController Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [HCRDataSource globalCampDataArray].count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self _campsArrayForIndexPathSection:section].count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HCRTableCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:kCampCellIdentifier
                                                                                 forIndexPath:indexPath];
    
    cell.title = [[self _campDictionaryForIndexPath:indexPath] objectForKey:@"Name" ofClass:@"NSString"];
    
    // TODO: REMOVE DEBUG
    if (indexPath.section != 0 || indexPath.row != 0) {
        cell.detailString = @"No Data";
    }
    // DEBUG
    
    [cell setBottomLineStatusForCollectionView:collectionView atIndexPath:indexPath];
    
    return cell;
    
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        
        HCRHeaderView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                   withReuseIdentifier:kCampHeaderReuseIdentifier
                                                                          forIndexPath:indexPath];
        
        header.titleString = [[self _countryDictionaryForIndexPathSection:indexPath.section] objectForKey:@"Name" ofClass:@"NSString"];
        
        return header;
        
    } else if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        HCRFooterView *footer = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                                                   withReuseIdentifier:kCampFooterReuseIdentifier
                                                                          forIndexPath:indexPath];
        
        return footer;
    }
    
    return nil;
    
}

#pragma mark - UICollectionViewController Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // TODO: hook up rest of cells
    if (indexPath.section == 0 && indexPath.row == 0) {
        HCRCampOverviewController *campOverview = [[HCRCampOverviewController alloc] initWithCollectionViewLayout:[HCRCampOverviewController preferredLayout]];
        
        campOverview.campName = [[self _campDictionaryForIndexPath:indexPath] objectForKey:@"Name" ofClass:@"NSString"];
        
        [self.navigationController pushViewController:campOverview animated:YES];
    }
    
}

#pragma mark - Private Methods

- (NSDictionary *)_countryDictionaryForIndexPathSection:(NSInteger)section {
    return [self.campDataArray objectAtIndex:section ofClass:@"NSDictionary"];
}

- (NSArray *)_campsArrayForIndexPathSection:(NSInteger)section {
    return [[self _countryDictionaryForIndexPathSection:section] objectForKey:@"Camps" ofClass:@"NSArray"];
}

- (NSDictionary *)_campDictionaryForIndexPath:(NSIndexPath *)indexPath {
    
    NSArray *campsArray = [[self _countryDictionaryForIndexPathSection:indexPath.section] objectForKey:@"Camps" ofClass:@"NSArray"];
    return [campsArray objectAtIndex:indexPath.row ofClass:@"NSDictionary"];
    
}

@end
