//
//  HCRCampClusterDetailViewController.m
//  UNHCR
//
//  Created by Sean Conrad on 10/2/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRCampClusterDetailViewController.h"
#import "HCRTableFlowLayout.h"
#import "HCRCampClusterGraphCell.h"
#import "HCRCampClusterResourcesCell.h"
#import "HCRCampClusterAgenciesCell.h"

////////////////////////////////////////////////////////////////////////////////

NSString *const kCampClusterHeaderIdentifier = @"kCampClusterHeaderIdentifier";

NSString *const kCampClusterGraphCellIdentifier = @"kCampClusterGraphCellIdentifier";
NSString *const kCampClusterResourcesCellIdentifier = @"kCampClusterResourcesCellIdentifier";
NSString *const kCampClusterAgenciesCellIdentifier = @"kCampClusterAgenciesCellIdentifier";

////////////////////////////////////////////////////////////////////////////////

@interface HCRCampClusterDetailViewController ()

@property NSArray *campClusterDataArray;

@end

////////////////////////////////////////////////////////////////////////////////

@implementation HCRCampClusterDetailViewController

- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        // Custom initialization
        
        NSArray *agencyArray = @[
                                 @{@"Name": @"WHO"},
                                 @{@"Name": @"UNICEF"},
                                 @{@"Name": @"WASH"},
                                 @{@"Name": @"Gates Foundation"}
                                 ];
        
        self.campClusterDataArray = @[
                                      @{@"Section": @"Refugee Requests",
                                        @"Cell": kCampClusterGraphCellIdentifier},
                                      @{@"Section": @"Resources",
                                        @"Cell": kCampClusterResourcesCellIdentifier},
                                      @{@"Section": @"Local Agencies",
                                        @"Cell": kCampClusterAgenciesCellIdentifier,
                                        @"Agencies": agencyArray}
                                      ];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    NSParameterAssert(self.clusterDictionary);
    NSParameterAssert(self.campDictionary);
    
    self.title = [self.clusterDictionary objectForKey:@"Name"];
    self.view.backgroundColor = [UIColor whiteColor];
    self.collectionView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.95];
    
    HCRFlowLayout *flowLayout = (HCRFlowLayout *)self.collectionView.collectionViewLayout;
    NSParameterAssert([flowLayout isKindOfClass:[HCRFlowLayout class]]);
    [flowLayout setDisplayHeader:YES withSize:CGSizeMake(CGRectGetWidth(self.collectionView.bounds),
                                                         [HCRFlowLayout preferredHeaderHeight])];
    
    [self.collectionView registerClass:[UICollectionReusableView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:kCampClusterHeaderIdentifier];
    [self.collectionView registerClass:[HCRCampClusterGraphCell class]
            forCellWithReuseIdentifier:kCampClusterGraphCellIdentifier];
    [self.collectionView registerClass:[HCRCampClusterResourcesCell class]
            forCellWithReuseIdentifier:kCampClusterResourcesCellIdentifier];
    [self.collectionView registerClass:[HCRCampClusterAgenciesCell class]
            forCellWithReuseIdentifier:kCampClusterAgenciesCellIdentifier];
    
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:backgroundImageView];
    [self.view sendSubviewToBack:backgroundImageView];
    
    UIView *background = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:background];
    [self.view sendSubviewToBack:background];
    
    UIImage *clusterImage = [[UIImage imageNamed:[self.clusterDictionary objectForKey:@"Image"]] colorImage:[UIColor UNHCRBlue]
                                                                                              withBlendMode:kCGBlendModeNormal
                                                                                           withTransparency:YES];
    background.backgroundColor = [UIColor colorWithPatternImage:clusterImage];
    
//    backgroundImageView.image = [clusterImage colorImage:[UIColor UNHCRBlue] withBlendMode:kCGBlendModeNormal withTransparency:YES];
//    backgroundImageView.backgroundColor = [UIColor whiteColor];
//    backgroundImageView.alpha = 0.7;
//    
//    backgroundImageView.clipsToBounds = YES;
//    backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    
}

#pragma mark - Class Methods

+ (UICollectionViewLayout *)preferredLayout {
    return [[HCRTableFlowLayout alloc] init];
}

#pragma mark - UICollectionView Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.campClusterDataArray.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    NSDictionary *sectionData = [self.campClusterDataArray objectAtIndex:section ofClass:@"NSDictionary"];
    NSArray *agencyArray = [sectionData objectForKey:@"Agencies" ofClass:@"NSArray" mustExist:NO];
    
    if (agencyArray) {
        return agencyArray.count;
    } else {
        return 1;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *sectionData = [self.campClusterDataArray objectAtIndex:indexPath.section ofClass:@"NSDictionary"];
    NSString *cellType = [sectionData objectForKey:@"Cell" ofClass:@"NSString"];
    
    if ([cellType isEqualToString:kCampClusterGraphCellIdentifier]) {
        HCRCampClusterGraphCell *graphCell = [collectionView dequeueReusableCellWithReuseIdentifier:kCampClusterGraphCellIdentifier forIndexPath:indexPath];
        
        
        
        return graphCell;
    } else if ([cellType isEqualToString:kCampClusterResourcesCellIdentifier]) {
        HCRCampClusterResourcesCell *resourcesCell = [collectionView dequeueReusableCellWithReuseIdentifier:kCampClusterResourcesCellIdentifier forIndexPath:indexPath];
        
        
        
        return resourcesCell;
    } else if ([cellType isEqualToString:kCampClusterAgenciesCellIdentifier]) {
        HCRCampClusterGraphCell *agencyCell = [collectionView dequeueReusableCellWithReuseIdentifier:kCampClusterAgenciesCellIdentifier forIndexPath:indexPath];
        
        
        
        return agencyCell;
    }
    
    return nil;
    
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        
        UICollectionReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                              withReuseIdentifier:kCampClusterHeaderIdentifier
                                                                                     forIndexPath:indexPath];
        
        if (header.subviews.count > 0) {
            NSArray *subviews = [NSArray arrayWithArray:header.subviews];
            for (UIView *subview in subviews) {
                [subview removeFromSuperview];
            }
        }
        
        NSDictionary *sectionData = [self.campClusterDataArray objectAtIndex:indexPath.section ofClass:@"NSDictionary"];
        
        UILabel *headerLabel = [[UILabel alloc] initWithFrame:header.bounds];
        [header addSubview:headerLabel];
        
        headerLabel.text = [sectionData objectForKey:@"Section" ofClass:@"NSString"];
        headerLabel.font = [UIFont boldSystemFontOfSize:18];
        
        headerLabel.textColor = [UIColor whiteColor];
        headerLabel.backgroundColor = [[UIColor UNHCRBlue] colorWithAlphaComponent:0.7];
        headerLabel.textAlignment = NSTextAlignmentCenter;
        
        return header;
        
    }
    
    return nil;
    
}

@end
