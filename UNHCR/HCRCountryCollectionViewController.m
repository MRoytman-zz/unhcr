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
#import "HCRDataSource.h"

////////////////////////////////////////////////////////////////////////////////

NSString *const kCountryCellIdentifier = @"kCountryCellIdentifier";
NSString *const kCountryHeaderIdentifier = @"kCountryHeaderIdentifier";

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
    self.collectionView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.85];
    
    HCRTableFlowLayout *tableLayout = (HCRTableFlowLayout *)self.collectionView.collectionViewLayout;
    NSParameterAssert([tableLayout isKindOfClass:[HCRTableFlowLayout class]]);
    [tableLayout setDisplayHeader:YES withSize:CGSizeMake(CGRectGetWidth(self.collectionView.bounds),
                                                          [HCRTableFlowLayout preferredHeaderHeight])];
    
    [self.collectionView registerClass:[HCRCountryCollectionCell class]
            forCellWithReuseIdentifier:kCountryCellIdentifier];
    
    [self.collectionView registerClass:[UICollectionReusableView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:kCountryHeaderIdentifier];
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    NSString *imagePath = (screenBounds.size.height == 568) ? @"main-background-4in" : @"main-background";
    UIImage *launchImage = [UIImage imageNamed:imagePath];
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:launchImage];
    [self.view addSubview:backgroundImageView];
    [self.view sendSubviewToBack:backgroundImageView];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:YES];
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
    
    return cell;
    
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        UICollectionReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                              withReuseIdentifier:kCountryHeaderIdentifier
                                                                                     forIndexPath:indexPath];
        
        if (header.subviews.count > 0) {
            NSArray *subviews = [NSArray arrayWithArray:header.subviews];
            for (UIView *subview in subviews) {
                [subview removeFromSuperview];
            }
        }
        
        UILabel *headerLabel = [[UILabel alloc] initWithFrame:header.bounds];
        [header addSubview:headerLabel];
        
        headerLabel.text = [[[HCRDataSource globalDataArray] objectAtIndex:indexPath.section] objectForKey:@"Category"];
        headerLabel.font = [UIFont boldSystemFontOfSize:18];
        
        headerLabel.textColor = [UIColor whiteColor];
        headerLabel.backgroundColor = [[UIColor UNHCRBlue] colorWithAlphaComponent:0.7];
        headerLabel.textAlignment = NSTextAlignmentCenter;
        
        return header;
    }
    
    return nil;
    
}

#pragma mark - UICollectionViewController Delegate

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    HCRCountryCollectionCell *cell = (HCRCountryCollectionCell *)[collectionView cellForItemAtIndexPath:indexPath];
    NSParameterAssert([cell isKindOfClass:[HCRCountryCollectionCell class]]);
    
    cell.backgroundColor = [UIColor UNHCRBlue];
    
}

- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    HCRCountryCollectionCell *cell = (HCRCountryCollectionCell *)[collectionView cellForItemAtIndexPath:indexPath];
    NSParameterAssert([cell isKindOfClass:[HCRCountryCollectionCell class]]);
    
    cell.backgroundColor = [UIColor clearColor];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HCRCountryCollectionCell *cell = (HCRCountryCollectionCell *)[collectionView cellForItemAtIndexPath:indexPath];
    NSParameterAssert([cell isKindOfClass:[HCRCountryCollectionCell class]]);
    
    HCRTableFlowLayout *tableLayout = [[HCRTableFlowLayout alloc] init];
    HCRCampCollectionViewController *campCollection = [[HCRCampCollectionViewController alloc] initWithCollectionViewLayout:tableLayout];
    campCollection.countryDictionary = cell.countryDictionary;
    
    [self.navigationController pushViewController:campCollection animated:YES];
    
}

@end
