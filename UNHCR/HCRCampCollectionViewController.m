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

////////////////////////////////////////////////////////////////////////////////

NSString *const kCampCellIdentifier = @"kCampCellIdentifier";
NSString *const kCampHeaderReuseIdentifier = @"kCampHeaderReuseIdentifier";

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
    self.collectionView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.85];
    
    HCRTableFlowLayout *tableLayout = (HCRTableFlowLayout *)self.collectionView.collectionViewLayout;
    NSParameterAssert([tableLayout isKindOfClass:[HCRTableFlowLayout class]]);
    [tableLayout setDisplayHeader:YES withSize:[HCRTableFlowLayout preferredHeaderSizeForCollectionView:self.collectionView]];
    
    [self.collectionView registerClass:[HCRCampCollectionCell class]
            forCellWithReuseIdentifier:kCampCellIdentifier];
    
    [self.collectionView registerClass:[UICollectionReusableView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:kCampHeaderReuseIdentifier];

    // TODO: weird; not sure why self.view.frame is necessary instead of self.view.bounds..?
    MKMapView *mapView = [MKMapView mapViewWithFrame:self.view.frame
                                            latitude:[[self.countryDictionary objectForKey:@"Latitude"] floatValue]
                                           longitude:[[self.countryDictionary objectForKey:@"Longitude"] floatValue]
                                                span:[[self.countryDictionary objectForKey:@"Span"] floatValue]];
    
    [self.view insertSubview:mapView atIndex:0];
    
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
    
    return cell;
    
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        
        UICollectionReusableView *header = [UICollectionReusableView headerForUNHCRCollectionView:collectionView
                                                                                       identifier:kCampHeaderReuseIdentifier
                                                                                        indexPath:indexPath
                                                                                            title:@"Refugee Camps"];
        
        return header;
        
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
