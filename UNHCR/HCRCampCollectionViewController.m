//
//  HCRCampCollectionViewController.m
//  UNHCR
//
//  Created by Sean Conrad on 9/30/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import <MapKit/MapKit.h>

#import "HCRCampCollectionViewController.h"
#import "HCRCampCollectionCell.h"
#import "HCRTableFlowLayout.h"
#import "HCRClusterCollectionController.h"
#import "HCRHeaderView.h"
#import "HCRFooterView.h"

////////////////////////////////////////////////////////////////////////////////

NSString *const kCampCellIdentifier = @"kCampCellIdentifier";
NSString *const kCampHeaderReuseIdentifier = @"kCampHeaderReuseIdentifier";
NSString *const kCampFooterReuseIdentifier = @"kCampFooterReuseIdentifier";

////////////////////////////////////////////////////////////////////////////////

@interface HCRCampCollectionViewController ()

@end

////////////////////////////////////////////////////////////////////////////////

@implementation HCRCampCollectionViewController

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
    
    NSParameterAssert(self.countryDictionary);
    
    self.title = [self.countryDictionary objectForKey:@"Name"];
    
    self.highlightCells = YES;
    
    HCRTableFlowLayout *tableLayout = (HCRTableFlowLayout *)self.collectionView.collectionViewLayout;
    NSParameterAssert([tableLayout isKindOfClass:[HCRTableFlowLayout class]]);
    [tableLayout setDisplayHeader:YES withSize:[HCRHeaderView preferredHeaderSizeForCollectionView:self.collectionView]];
    [tableLayout setDisplayFooter:YES withSize:[HCRFooterView preferredFooterSizeWithTopLineForCollectionView:self.collectionView]];
    
    [self.collectionView registerClass:[HCRCampCollectionCell class]
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
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSArray *campsArray = [self.countryDictionary objectForKey:@"Camps"];
    return campsArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HCRCampCollectionCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:kCampCellIdentifier forIndexPath:indexPath];
    
    NSArray *campsArray = [self.countryDictionary objectForKey:@"Camps"];
    cell.campDictionary = [campsArray objectAtIndex:indexPath.row];
    
    [cell setBottomLineStatusForCollectionView:collectionView atIndexPath:indexPath];
    
    return cell;
    
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        
        HCRHeaderView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                   withReuseIdentifier:kCampHeaderReuseIdentifier
                                                                          forIndexPath:indexPath];
        
        header.titleString = @"Refugee Camps";
        
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
    
    HCRCampCollectionCell *cell = (HCRCampCollectionCell *)[collectionView cellForItemAtIndexPath:indexPath];
    NSParameterAssert([cell isKindOfClass:[HCRCampCollectionCell class]]);
    
    HCRClusterCollectionController *campDetail = [[HCRClusterCollectionController alloc] initWithCollectionViewLayout:[HCRClusterCollectionController preferredLayout]];
    
    campDetail.countryName = [self.countryDictionary objectForKey:@"Name" ofClass:@"NSString"];
    campDetail.campDictionary = cell.campDictionary;
    
    [self.navigationController pushViewController:campDetail animated:YES];
    
}

@end
