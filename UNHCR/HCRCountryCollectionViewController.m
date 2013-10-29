//
//  HCRCountryCollectionViewController.m
//  UNHCR
//
//  Created by Sean Conrad on 9/30/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRCountryCollectionViewController.h"
#import "HCRCountryCollectionCell.h"
#import "HCRCampCollectionViewController.h"
#import "HCRTableFlowLayout.h"
#import "HCRHeaderView.h"
#import "HCRFooterView.h"

////////////////////////////////////////////////////////////////////////////////

NSString *const kCountryCellIdentifier = @"kCountryCellIdentifier";
NSString *const kCountryHeaderIdentifier = @"kCountryHeaderIdentifier";
NSString *const kCountryFooterIdentifier = @"kCountryFooterIdentifier";

////////////////////////////////////////////////////////////////////////////////

@interface HCRCountryCollectionViewController ()

@end

////////////////////////////////////////////////////////////////////////////////

@implementation HCRCountryCollectionViewController

- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        // Custom initialization
        
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.title = @"Countries";
    
    self.highlightCells = YES;
    
    HCRTableFlowLayout *tableLayout = (HCRTableFlowLayout *)self.collectionView.collectionViewLayout;
    NSParameterAssert([tableLayout isKindOfClass:[HCRTableFlowLayout class]]);
    [tableLayout setDisplayHeader:YES withSize:[HCRHeaderView preferredHeaderSizeForCollectionView:self.collectionView]];
    [tableLayout setDisplayFooter:YES withSize:[HCRFooterView preferredFooterSizeWithTopLineForCollectionView:self.collectionView]];
    
    [self.collectionView registerClass:[HCRCountryCollectionCell class]
            forCellWithReuseIdentifier:kCountryCellIdentifier];
    
    [self.collectionView registerClass:[HCRHeaderView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:kCountryHeaderIdentifier];
    
    [self.collectionView registerClass:[HCRFooterView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                   withReuseIdentifier:kCountryFooterIdentifier];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

#pragma mark - Class Methods

+ (UICollectionViewLayout *)preferredLayout {
    return [[HCRTableFlowLayout alloc] init];
}

#pragma mark - UICollectionViewController Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [HCRDataSource globalDataArray].count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSArray *countriesArray = [[[HCRDataSource globalDataArray] objectAtIndex:section] objectForKey:@"Countries"];
    return countriesArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HCRCountryCollectionCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:kCountryCellIdentifier forIndexPath:indexPath];
    
    NSDictionary *categoryDictionary = [[HCRDataSource globalDataArray] objectAtIndex:indexPath.section];
    cell.countryDictionary = [[categoryDictionary objectForKey:@"Countries"] objectAtIndex:indexPath.row];
    
    [cell setBottomLineStatusForCollectionView:collectionView atIndexPath:indexPath];
    
    return cell;
    
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        
        NSString *categoryString = [[[HCRDataSource globalDataArray] objectAtIndex:indexPath.section] objectForKey:@"Category"];
        HCRHeaderView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                   withReuseIdentifier:kCountryHeaderIdentifier
                                                                          forIndexPath:indexPath];
        
        header.titleString = categoryString;
        
        return header;
    } else if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        HCRFooterView *footer = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                                                   withReuseIdentifier:kCountryFooterIdentifier
                                                                          forIndexPath:indexPath];
        
        return footer;
    }
    
    return nil;
    
}

#pragma mark - UICollectionViewController Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HCRCountryCollectionCell *cell = (HCRCountryCollectionCell *)[collectionView cellForItemAtIndexPath:indexPath];
    NSParameterAssert([cell isKindOfClass:[HCRCountryCollectionCell class]]);
    
    HCRCampCollectionViewController *campCollection = [[HCRCampCollectionViewController alloc] initWithCollectionViewLayout:[HCRCampCollectionViewController preferredLayout]];
    campCollection.countryDictionary = cell.countryDictionary;
    
    [self.navigationController pushViewController:campCollection animated:YES];
    
}

@end
