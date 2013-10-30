//
//  HCRAlertsViewController.m
//  UNHCR
//
//  Created by Sean Conrad on 10/7/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCREmergenciesViewController.h"
#import "HCREmergencyCell.h"
#import "HCRTableFlowLayout.h"

////////////////////////////////////////////////////////////////////////////////

NSString *const kEmergencyCellIdentifier = @"kEmergencyCellIdentifier";
NSString *const kEmergencyHeaderIdentifier = @"kEmergencyHeaderIdentifier";
NSString *const kEmergencyFooterIdentifier = @"kEmergencyFooterIdentifier";

////////////////////////////////////////////////////////////////////////////////

@interface HCREmergenciesViewController ()

@property (nonatomic, strong) NSArray *alertsList;

@end

////////////////////////////////////////////////////////////////////////////////

@implementation HCREmergenciesViewController

- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        // Custom initialization
        self.alertsList = [HCRDataSource globalEmergenciesData];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.title = @"Emergencies";
    
    HCRTableFlowLayout *tableLayout = (HCRTableFlowLayout *)self.collectionView.collectionViewLayout;
    NSParameterAssert([tableLayout isKindOfClass:[HCRTableFlowLayout class]]);
    
    [tableLayout setDisplayHeader:YES withSize:[HCRHeaderView preferredHeaderSizeWithLineOnlyForCollectionView:self.collectionView]];
    [tableLayout setDisplayFooter:YES withSize:[HCRFooterView preferredFooterSizeWithTopLineForCollectionView:self.collectionView]];
    
    tableLayout.itemSize = CGSizeMake(CGRectGetWidth(self.collectionView.bounds),
                                      [HCREmergencyCell preferredCellHeight]);
    
    [self.collectionView registerClass:[HCREmergencyCell class]
            forCellWithReuseIdentifier:kEmergencyCellIdentifier];
    
    [self.collectionView registerClass:[HCRHeaderView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:kEmergencyHeaderIdentifier];
    
    [self.collectionView registerClass:[HCRFooterView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                   withReuseIdentifier:kEmergencyFooterIdentifier];
    
}

#pragma mark - Class Methods

+ (UICollectionViewLayout *)preferredLayout {
    return [[HCRTableFlowLayout alloc] init];
}

#pragma mark - UICollectionView

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.alertsList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HCREmergencyCell *alertCell = [collectionView dequeueReusableCellWithReuseIdentifier:kEmergencyCellIdentifier
                                                                        forIndexPath:indexPath];
    
    alertCell.showLocation = YES;
    alertCell.emergencyDictionary = [self.alertsList objectAtIndex:indexPath.row ofClass:@"NSDictionary"];
    
    [alertCell setBottomLineStatusForCollectionView:collectionView atIndexPath:indexPath];
    
    return alertCell;
    
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        
        HCRHeaderView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                   withReuseIdentifier:kEmergencyHeaderIdentifier
                                                                          forIndexPath:indexPath];
        
        return header;
        
    } else if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        
        HCRFooterView *footer = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                                                   withReuseIdentifier:kEmergencyFooterIdentifier
                                                                          forIndexPath:indexPath];
        
        return footer;
        
    }
    
    return nil;
    
}

@end
