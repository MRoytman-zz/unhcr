//
//  HCRHealthTallySheetViewController.m
//  UNHCR
//
//  Created by Sean Conrad on 10/6/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRTallySheetPickerViewController.h"
#import "HCRTableFlowLayout.h"
#import "HCRButtonListCell.h"
#import "HCRTallySheetDetailViewController.h"

////////////////////////////////////////////////////////////////////////////////

NSString *const kTallySheetCellIdentifier = @"kTallySheetCellIdentifier";

////////////////////////////////////////////////////////////////////////////////

@interface HCRTallySheetPickerViewController ()

@end

////////////////////////////////////////////////////////////////////////////////

@implementation HCRTallySheetPickerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
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
    NSParameterAssert(self.selectedClusterMetaData);
    
    HCRTableFlowLayout *tableLayout = (HCRTableFlowLayout *)self.collectionView.collectionViewLayout;
    NSParameterAssert([tableLayout isKindOfClass:[HCRTableFlowLayout class]]);
    tableLayout.sectionInset = UIEdgeInsetsMake(12, 0, 12, 0);
    
    [self.collectionView registerClass:[HCRButtonListCell class]
            forCellWithReuseIdentifier:kTallySheetCellIdentifier];
    
//    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
//    [self.view addSubview:backgroundImageView];
//    [self.view sendSubviewToBack:backgroundImageView];
//    
//    UIView *background = [[UIView alloc] initWithFrame:self.view.bounds];
//    [self.view addSubview:background];
//    [self.view sendSubviewToBack:background];
//    
//    UIImage *clusterImage = [[UIImage imageNamed:[self.selectedClusterMetaData objectForKey:@"Image"]] colorImage:[UIColor lightGrayColor]
//                                                                                                    withBlendMode:kCGBlendModeNormal
//                                                                                                 withTransparency:YES];
//    background.backgroundColor = [UIColor colorWithPatternImage:clusterImage];
    
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
    
    HCRButtonListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kTallySheetCellIdentifier forIndexPath:indexPath];
    
    NSArray *tallySheets = [self.campClusterData objectForKey:@"TallySheets" ofClass:@"NSArray"];
    NSDictionary *sheet = [tallySheets objectAtIndex:indexPath.row ofClass:@"NSDictionary"];
    
    cell.listButtonTitle = [sheet objectForKey:@"Name" ofClass:@"NSString"];
    
    if (indexPath.row != [self.collectionView numberOfItemsInSection:indexPath.section] - 1) {
        cell.showCellDivider = YES;
    }
    
    return cell;
    
}

#pragma mark - UICollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HCRTallySheetDetailViewController *tallyDetail = [[HCRTallySheetDetailViewController alloc] initWithCollectionViewLayout:[HCRTallySheetDetailViewController preferredLayout]];
    
    NSArray *tallySheets = [self.campClusterData objectForKey:@"TallySheets" ofClass:@"NSArray"];
    
    tallyDetail.tallySheetData = [tallySheets objectAtIndex:indexPath.row ofClass:@"NSDictionary"];
    tallyDetail.selectedClusterMetaData = self.selectedClusterMetaData;
    tallyDetail.countryName = self.countryName;
    tallyDetail.campName = [self.campData objectForKey:@"Name" ofClass:@"NSString"];
    tallyDetail.campClusterData = self.campClusterData;
    
    UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:tallyDetail];
    
    [self presentViewController:navigation animated:YES completion:nil];
    
}

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HCRButtonListCell *cell = (HCRButtonListCell *)[collectionView cellForItemAtIndexPath:indexPath];
    NSParameterAssert([cell isKindOfClass:[HCRButtonListCell class]]);
    
    [cell.listButton setHighlighted:YES];
    
}

- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HCRButtonListCell *cell = (HCRButtonListCell *)[collectionView cellForItemAtIndexPath:indexPath];
    NSParameterAssert([cell isKindOfClass:[HCRButtonListCell class]]);
    
    [cell.listButton setHighlighted:NO];
    
}

@end
