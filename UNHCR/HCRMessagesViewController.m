//
//  HCRMessagesViewController.m
//  UNHCR
//
//  Created by Sean Conrad on 10/29/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRMessagesViewController.h"
#import "HCRTableFlowLayout.h"
#import "HCRDirectMessageCell.h"
#import "EASoundManager.h"

////////////////////////////////////////////////////////////////////////////////

NSString *const kMessagesCellIdentifier = @"kMessagesCellIdentifier";
NSString *const kMessagesHeaderIdentifier = @"kMessagesHeaderIdentifier";
NSString *const kMessagesFooterIdentifier = @"kMessagesFooterIdentifier";

////////////////////////////////////////////////////////////////////////////////

@interface HCRMessagesViewController ()

@property NSArray *messagesArray;

@end

////////////////////////////////////////////////////////////////////////////////

@implementation HCRMessagesViewController

- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithCollectionViewLayout:layout];
    if (self) {
        // Custom initialization
        self.messagesArray = [HCRDataSource globalMessagesData];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.title = @"Direct Messages";
    
    // LAYOUT AND REUSABLES
    HCRTableFlowLayout *tableLayout = (HCRTableFlowLayout *)self.collectionView.collectionViewLayout;
    NSParameterAssert([tableLayout isKindOfClass:[HCRTableFlowLayout class]]);
    
    [tableLayout setDisplayHeader:YES withSize:[HCRHeaderView preferredHeaderSizeWithLineOnlyForCollectionView:self.collectionView]];
    [tableLayout setDisplayFooter:YES withSize:[HCRFooterView preferredFooterSizeWithBottomLineOnlyForCollectionView:self.collectionView]];
    
    tableLayout.itemSize = [HCRDirectMessageCell preferredSizeForCollectionView:self.collectionView];
    
    [self.collectionView registerClass:[HCRDirectMessageCell class]
            forCellWithReuseIdentifier:kMessagesCellIdentifier];
    
    [self.collectionView registerClass:[HCRHeaderView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:kMessagesHeaderIdentifier];
    
    [self.collectionView registerClass:[HCRFooterView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                   withReuseIdentifier:kMessagesFooterIdentifier];
    
    // BAR BUTTONS
    UIBarButtonItem *composeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose
                                                                                   target:self
                                                                                   action:@selector(_composeButtonPressed)];
    [self.navigationItem setRightBarButtonItem:composeButton];
    
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
    return self.messagesArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HCRDirectMessageCell *messageCell = (HCRDirectMessageCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kMessagesCellIdentifier forIndexPath:indexPath];
    
    messageCell.messageDictionary = [self.messagesArray objectAtIndex:indexPath.row ofClass:@"NSDictionary"];
    
    [messageCell setBottomLineStatusForCollectionView:collectionView atIndexPath:indexPath];
    
    return messageCell;
    
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        
        HCRHeaderView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                   withReuseIdentifier:kMessagesHeaderIdentifier
                                                                          forIndexPath:indexPath];
        
        return header;
        
    } else if ([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        
        HCRFooterView *footer = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                                                                   withReuseIdentifier:kMessagesFooterIdentifier
                                                                          forIndexPath:indexPath];
        
        return footer;
        
    }
    
    return nil;
    
}

#pragma mark - UICollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [[EASoundManager sharedSoundManager] playSoundOnce:EASoundIDNotice];
}

#pragma mark - Private Methods

- (void)_composeButtonPressed {
    [[EASoundManager sharedSoundManager] playSoundOnce:EASoundIDNotice];
}

@end
