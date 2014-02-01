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

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[HCRDataManager sharedManager] markAllAlertsAsRead];
    [self.collectionView reloadData];
}

#pragma mark - Class Methods

+ (UICollectionViewLayout *)preferredLayout {
    return [[HCRTableFlowLayout alloc] init];
}

#pragma mark - UICollectionView Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.alertsArray.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HCRAlertCell *alertCell = (HCRAlertCell *)[self.collectionView dequeueReusableCellWithReuseIdentifier:kAlertListAlertCellIdentifier forIndexPath:indexPath];
    
    // mark viewed alerts as read
    HCRAlert *alert = [self.alertsArray objectAtIndex:indexPath.section];
    
    alertCell.alert = alert;
    alertCell.read = alert.read;
    
    return alertCell;
    
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        HCRHeaderView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                   withReuseIdentifier:kAlertListHeaderIdentifier
                                                                          forIndexPath:indexPath];
        
        return header;
    } else if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        HCRFooterView *footer = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                                                   withReuseIdentifier:kAlertListFooterIdentifier
                                                                          forIndexPath:indexPath];
        
        return footer;
    }
    
    return nil;
    
}

#pragma mark - UICollectionView Delegate Flow Layout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    
    return [HCRHeaderView preferredHeaderSizeWithLineOnlyForCollectionView:collectionView];
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    
    return [HCRFooterView preferredFooterSizeForCollectionView:collectionView];
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return [HCRAlertCell sizeForCellInCollectionView:collectionView withAlert:[self.alertsArray objectAtIndex:indexPath.section]];
    
}

#pragma mark - Getters & Setters

- (NSArray *)alertsArray {
    return [[HCRDataManager sharedManager] localAlertsArray];
}

#pragma mark - Private Methods

- (void)_refreshControlValueChanged:(UIRefreshControl *)refreshControl {
    
    if (refreshControl.refreshing) {
        [self _refreshAlertsWithDataReload:YES withCompletion:^(NSError *error) {
            if (error) {
                [[SCErrorManager sharedManager] showAlertForError:error withErrorSource:SCErrorSourceParse withCompletion:nil];
            }
        }];
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
        
        NSArray *oldAlerts = [NSArray arrayWithArray:[[HCRDataManager sharedManager] localAlertsArray]];
        
        [[HCRDataManager sharedManager] refreshAlertsWithCompletion:^(NSError *error) {
            
            self.downloadingAlerts = NO;
            [self.refreshControl endRefreshing];
            
            if (reloadData) {
                [self _reloadDataAnimatedWithOldAlerts:oldAlerts];
            }
            
            if (completionBlock) {
                completionBlock(error);
            }
            
        }];
        
    }
    
}

- (void)_reloadDataAnimatedWithOldAlerts:(NSArray *)oldAlerts {
    
    // compare current alerts to old alerts and delete/insert as needed
    NSArray *currentAlerts = [[HCRDataManager sharedManager] localAlertsArray];

    NSMutableIndexSet *indexSetsToAdd = [NSMutableIndexSet new];
    NSMutableIndexSet *indexSetsToDelete = [NSMutableIndexSet new];
    
    // if the old set does NOT contain an object in the new set, add it
    for (HCRAlert *currentAlert in currentAlerts) {
        if (![oldAlerts containsObject:currentAlert]) {
            [indexSetsToAdd addIndex:[currentAlerts indexOfObject:currentAlert]];
        }
    }
    
    // if the new set does NOT contain an object in the old set, delete it
    for (HCRAlert *oldAlert in oldAlerts) {
        if (![currentAlerts containsObject:oldAlert]) {
            [indexSetsToDelete addIndex:[oldAlerts indexOfObject:oldAlert]];
        }
    }
    
    [self.collectionView performBatchUpdates:^{
        
        [self.collectionView insertSections:indexSetsToAdd];
        [self.collectionView deleteSections:indexSetsToDelete];
        [self.collectionView reloadData];
        
    } completion:nil];
    
}

@end
