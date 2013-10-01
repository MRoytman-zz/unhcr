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

////////////////////////////////////////////////////////////////////////////////

NSString *const kCountryCellIdentifier = @"kCountryCellIdentifier";

////////////////////////////////////////////////////////////////////////////////

@interface HCRCountryCollectionViewController ()

@property NSArray *countriesArray;

@end

////////////////////////////////////////////////////////////////////////////////

@implementation HCRCountryCollectionViewController

- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        // Custom initialization
        self.countriesArray = @[
                                @"Iraq",
                                @"Uganda",
                                @"Thailand",
                                @"Iraq",
                                @"Uganda",
                                @"Thailand",
                                @"Iraq",
                                @"Uganda",
                                @"Thailand",
                                @"Iraq",
                                @"Uganda",
                                @"Thailand",
                                @"Iraq",
                                @"Uganda",
                                @"Thailand",
                                @"Iraq",
                                @"Uganda",
                                @"Thailand"
                                ];
        
        
        
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.title = @"Countries";
    self.collectionView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.9];
    
    [self.collectionView registerClass:[HCRCountryCollectionCell class]
            forCellWithReuseIdentifier:kCountryCellIdentifier];
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    NSString *imagePath = (screenBounds.size.height == 568) ? @"main-background-4in" : @"main-background";
    UIImage *launchImage = [UIImage imageNamed:imagePath];
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithImage:launchImage];
    [self.view addSubview:backgroundImageView];
    [self.view sendSubviewToBack:backgroundImageView];
    
}

#pragma mark - UICollectionViewController Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.countriesArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HCRCountryCollectionCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:kCountryCellIdentifier forIndexPath:indexPath];
    
    cell.countryName = [self.countriesArray objectAtIndex:indexPath.row];
    
    return cell;
    
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
    campCollection.country = cell.countryName;
    
    [self.navigationController pushViewController:campCollection animated:YES];
    
}

@end
