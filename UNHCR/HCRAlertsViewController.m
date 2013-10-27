//
//  HCRAlertsViewController.m
//  UNHCR
//
//  Created by Sean Conrad on 10/7/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRAlertsViewController.h"
#import "HCRAlertCell.h"
#import "HCRTableFlowLayout.h"

////////////////////////////////////////////////////////////////////////////////

NSString *const kAlertsCellIdentifier = @"kAlertsCellIdentifier";

////////////////////////////////////////////////////////////////////////////////

@interface HCRAlertsViewController ()

@property (nonatomic, strong) NSArray *alertsList;

@end

////////////////////////////////////////////////////////////////////////////////

@implementation HCRAlertsViewController

- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        // Custom initialization
        self.alertsList = [HCRDataSource globalAlertsData];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.title = @"Alerts";
    
    HCRTableFlowLayout *tableLayout = (HCRTableFlowLayout *)self.collectionView.collectionViewLayout;
    NSParameterAssert([tableLayout isKindOfClass:[HCRTableFlowLayout class]]);
    tableLayout.sectionInset = UIEdgeInsetsMake(12, 0, 0, 0);
    tableLayout.itemSize = CGSizeMake(CGRectGetWidth(self.collectionView.bounds),
                                      [HCRAlertCell preferredCellHeight]);
    
    [self.collectionView registerClass:[HCRAlertCell class] forCellWithReuseIdentifier:kAlertsCellIdentifier];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:YES];
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
    
    HCRAlertCell *alertCell = [collectionView dequeueReusableCellWithReuseIdentifier:kAlertsCellIdentifier forIndexPath:indexPath];
    
    alertCell.showLocation = YES;
    alertCell.alertDictionary = [self.alertsList objectAtIndex:indexPath.row ofClass:@"NSDictionary"];
    
    return alertCell;
    
}

@end
