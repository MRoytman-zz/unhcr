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
#import "HCRCampClusterResourcesButtonListCell.h"
#import "HCRCampClusterAgenciesButtonListCell.h"

#import "EAEmailUtilities.h"

////////////////////////////////////////////////////////////////////////////////

NSString *const kCampClusterHeaderIdentifier = @"kCampClusterHeaderIdentifier";

NSString *const kCampClusterGraphCellIdentifier = @"kCampClusterGraphCellIdentifier";
NSString *const kCampClusterResourcesCellIdentifier = @"kCampClusterResourcesCellIdentifier";
NSString *const kCampClusterAgenciesCellIdentifier = @"kCampClusterAgenciesCellIdentifier";

////////////////////////////////////////////////////////////////////////////////

@interface HCRCampClusterDetailViewController ()

@property NSDictionary *campClusterData;
@property NSArray *campClusterCollectionLayoutData;

@property (nonatomic, readonly) BOOL clusterContainsTallySheets;

@end

////////////////////////////////////////////////////////////////////////////////

@implementation HCRCampClusterDetailViewController

- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        // Custom initialization
        
        self.campClusterCollectionLayoutData = @[
                                      @{@"Section": @"Refugee Requests",
                                        @"Cell": kCampClusterGraphCellIdentifier},
                                      @{@"Section": @"Local Agencies",
                                        @"Cell": kCampClusterAgenciesCellIdentifier},
                                      @{@"Section": @"Resources",
                                        @"Cell": kCampClusterResourcesCellIdentifier}
                                      ];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    NSParameterAssert(self.selectedClusterMetaData);
    NSParameterAssert(self.campDictionary);
    
    NSString *selectedCluster = [self.selectedClusterMetaData objectForKey:@"Name"];
    self.campClusterData = [[self.campDictionary objectForKey:@"Clusters" ofClass:@"NSDictionary"] objectForKey:selectedCluster ofClass:@"NSDictionary"];
    
    self.title = selectedCluster;
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
    [self.collectionView registerClass:[HCRCampClusterResourcesButtonListCell class]
            forCellWithReuseIdentifier:kCampClusterResourcesCellIdentifier];
    [self.collectionView registerClass:[HCRCampClusterAgenciesButtonListCell class]
            forCellWithReuseIdentifier:kCampClusterAgenciesCellIdentifier];
    
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:backgroundImageView];
    [self.view sendSubviewToBack:backgroundImageView];
    
    UIView *background = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:background];
    [self.view sendSubviewToBack:background];
    
    UIImage *clusterImage = [[UIImage imageNamed:[self.selectedClusterMetaData objectForKey:@"Image"]] colorImage:[UIColor UNHCRBlue]
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
    return self.campClusterCollectionLayoutData.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    NSDictionary *sectionData = [self.campClusterCollectionLayoutData objectAtIndex:section ofClass:@"NSDictionary"];
    NSArray *agencyArray = [sectionData objectForKey:@"Agencies" ofClass:@"NSArray" mustExist:NO];
    
    if (agencyArray) {
        return agencyArray.count;
    } else {
        return 1;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSDictionary *sectionData = [self.campClusterCollectionLayoutData objectAtIndex:indexPath.section ofClass:@"NSDictionary"];
    NSString *cellType = [sectionData objectForKey:@"Cell" ofClass:@"NSString"];
    
    if ([cellType isEqualToString:kCampClusterGraphCellIdentifier]) {
        HCRCampClusterGraphCell *graphCell = [collectionView dequeueReusableCellWithReuseIdentifier:kCampClusterGraphCellIdentifier forIndexPath:indexPath];
        
        // TODO: make this real
        
        return graphCell;
    } else if ([cellType isEqualToString:kCampClusterResourcesCellIdentifier]) {
        HCRCampClusterResourcesButtonListCell *resourcesCell = [collectionView dequeueReusableCellWithReuseIdentifier:kCampClusterResourcesCellIdentifier forIndexPath:indexPath];
        
        resourcesCell.showTallySheetsButton = self.clusterContainsTallySheets;
        
        [resourcesCell.requestSuppliesButton addTarget:self
                                                action:@selector(_requestSuppliesButtonPressed)
                                      forControlEvents:UIControlEventTouchUpInside];
        
        [resourcesCell.sitRepsButton addTarget:self
                                        action:@selector(_sitRepsButtonPressed)
                              forControlEvents:UIControlEventTouchUpInside];
        
        if (self.clusterContainsTallySheets) {
            [resourcesCell.tallySheetsButton addTarget:self
                                                action:@selector(_tallySheetsButtonPressed)
                                      forControlEvents:UIControlEventTouchUpInside];
        }
        
        return resourcesCell;
    } else if ([cellType isEqualToString:kCampClusterAgenciesCellIdentifier]) {
        HCRCampClusterGraphCell *agencyCell = [collectionView dequeueReusableCellWithReuseIdentifier:kCampClusterAgenciesCellIdentifier forIndexPath:indexPath];
        
        // TODO: agencies!! :D
        
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
        
        NSDictionary *sectionData = [self.campClusterCollectionLayoutData objectAtIndex:indexPath.section ofClass:@"NSDictionary"];
        
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

#pragma mark - UICollectionView Delegate Flow Layout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)collectionViewLayout;
    
    NSDictionary *sectionData = [self.campClusterCollectionLayoutData objectAtIndex:indexPath.section ofClass:@"NSDictionary"];
    NSString *cellType = [sectionData objectForKey:@"Cell" ofClass:@"NSString"];
    
    if ([cellType isEqualToString:kCampClusterGraphCellIdentifier]) {
        return CGSizeMake(CGRectGetWidth(collectionView.bounds),
                          200);
    } else if ([cellType isEqualToString:kCampClusterResourcesCellIdentifier]) {
        
        NSInteger numberOfButtons = (self.clusterContainsTallySheets) ? 3 : 2;
        
        return CGSizeMake(CGRectGetWidth(collectionView.bounds),
                          [HCRCampClusterResourcesButtonListCell preferredCellHeightForNumberOfButtons:numberOfButtons]);
        
    } else {
        return flowLayout.itemSize;
    }
    
}

#pragma mark - Getters & Setters

- (BOOL)clusterContainsTallySheets {
    return ([self.campClusterData objectForKey:@"TallySheets" ofClass:@"NSNumber" mustExist:NO] != nil);
}

#pragma mark - Private Methods

- (void)_requestSuppliesButtonPressed {
    
    NSString *clusterName = [self.selectedClusterMetaData objectForKey:@"Name"];
    NSString *toString = [NSString stringWithFormat:@"%@@unhcr.org", [[clusterName stringByReplacingOccurrencesOfString:@" " withString:@"."] lowercaseString]];
    NSString *subjectString = [NSString stringWithFormat:@"%@ Supply Request", clusterName];
    
    [[EAEmailUtilities sharedUtilities] emailFromViewController:self
                                               withToRecipients:@[toString]
                                                withSubjectText:subjectString
                                                   withBodyText:nil
                                                 withCompletion:nil];
    
}

- (void)_sitRepsButtonPressed {
    
    NSString *sitRepString = [self.campClusterData objectForKey:@"SitReps" ofClass:@"NSString" mustExist:NO];
    
    NSURL *targetURL = [NSURL URLWithString:(sitRepString) ? sitRepString : [self.campDictionary objectForKey:@"SitReps" ofClass:@"NSString"]];
    
    [[UIApplication sharedApplication] openURL:targetURL];
    
}

- (void)_tallySheetsButtonPressed {
    
    // TODO: push tally sheet controller
    
}

@end
