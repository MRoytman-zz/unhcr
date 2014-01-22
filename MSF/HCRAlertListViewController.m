//
//  HCRAlertListViewController.m
//  UNHCR
//
//  Created by Sean Conrad on 1/20/14.
//  Copyright (c) 2014 Sean Conrad. All rights reserved.
//

#import "HCRAlertListViewController.h"
#import "HCRTableFlowLayout.h"
#import "HCRAlertComposeViewController.h"

#import "HCRAlertCell.h"
#import "HCRTableButtonCell.h"

////////////////////////////////////////////////////////////////////////////////

NSString *const kAlertListAlertCellIdentifier = @"kAlertListAlertCellIdentifier";

NSString *const kAlertListHeaderIdentifier = @"kAlertListHeaderIdentifier";
NSString *const kAlertListFooterIdentifier = @"kAlertListFooterIdentifier";

////////////////////////////////////////////////////////////////////////////////

@interface HCRAlertListViewController ()

@property BOOL downloadingAlerts;

@property (nonatomic, readonly) NSArray *alertsArray;

@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

////////////////////////////////////////////////////////////////////////////////

@implementation HCRAlertListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.title = @"Alerts";
    self.highlightCells = YES;
    self.collectionView.alwaysBounceVertical = YES;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.collectionView addSubview:self.refreshControl];
    
    [self.refreshControl addTarget:self
                       action:@selector(_refreshControlValueChanged:)
             forControlEvents:UIControlEventValueChanged];
    
    // BAR BUTTONS
    if ([HCRUser currentUser].canSendAlerts) {
        
        UIBarButtonItem *composeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                                                                       target:self
                                                                                       action:@selector(_composeButtonPressed)];
        [self.navigationItem setRightBarButtonItem:composeButton];
        
    }
    
    // LAYOUT & REUSABLES
    [self.collectionView registerClass:[HCRAlertCell class]
            forCellWithReuseIdentifier:kAlertListAlertCellIdentifier];
    
    [self.collectionView registerClass:[HCRHeaderView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:kAlertListHeaderIdentifier];
    
    [self.collectionView registerClass:[HCRFooterView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                   withReuseIdentifier:kAlertListFooterIdentifier];

    
    // NOTIFICATIONS
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_alertNotificationReceived:)
                                                 name:HCRNotificationAlertNotificationReceived
                                               object:nil];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // refresh
    [self _refreshAlertsWithDataReload:YES withCompletion:nil];
    
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
    return self.alertsArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HCRAlertCell *alertCell = (HCRAlertCell *)[self.collectionView dequeueReusableCellWithReuseIdentifier:kAlertListAlertCellIdentifier forIndexPath:indexPath];
    
    // mark viewed alerts as read
    HCRAlert *alert = [self.alertsArray objectAtIndex:indexPath.row];
    alert.read = YES;
    
    alertCell.alert = alert;
    
    [alertCell setBottomLineStatusForCollectionView:collectionView atIndexPath:indexPath];
    
    return alertCell;
    
}

#pragma mark - UICollectionView Delegate Flow Layout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return [HCRAlertCell sizeForCellInCollectionView:collectionView withAlert:[self.alertsArray objectAtIndex:indexPath.row]];
    
}

#pragma mark - Getters & Setters

- (NSArray *)alertsArray {
    return [[HCRDataManager sharedManager] localAlertsArray];
}

#pragma mark - Private Methods

- (void)_refreshControlValueChanged:(UIRefreshControl *)refreshControl {
    
    if (refreshControl.refreshing) {
        [self _refreshAlertsWithDataReload:YES withCompletion:nil];
    }
    
}

- (void)_composeButtonPressed {
    
    HCRAlertComposeViewController *alertCompose = [[HCRAlertComposeViewController alloc] initWithCollectionViewLayout:[HCRAlertComposeViewController preferredLayout]];
    
    [self.navigationController presentViewController:alertCompose animated:YES completion:nil];
    
}

- (void)_alertNotificationReceived:(NSNotification *)notification {
    
    [self _refreshAlertsWithDataReload:YES withCompletion:nil];
    
}

- (void)_refreshAlertsWithDataReload:(BOOL)reloadData withCompletion:(void (^)(NSError *error))completionBlock {
    
    if (!self.downloadingAlerts) {
        
        self.downloadingAlerts = YES;
        [self.refreshControl beginRefreshing];
        
        [[HCRDataManager sharedManager] refreshAlertsWithCompletion:^(NSError *error) {
            
            self.downloadingAlerts = NO;
            [self.refreshControl endRefreshing];
            
            if (reloadData) {
                [self.collectionView reloadData];
            }
            
            if (completionBlock) {
                completionBlock(error);
            }
            
        }];
        
    }
    
}

@end
