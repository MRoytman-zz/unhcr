//
//  HCRTallySheetInputViewController.m
//  UNHCR
//
//  Created by Sean Conrad on 10/6/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRTallySheetDetailInputViewController.h"
#import "HCRTableFlowLayout.h"
#import "HCRDataEntryCell.h"

////////////////////////////////////////////////////////////////////////////////

NSString *const kTallyDetailInputCellIdentifier = @"kTallyDetailInputCellIdentifier";
NSString *const kTallyDetailInputHeaderIdentifier = @"kTallyDetailInputHeaderIdentifier";

////////////////////////////////////////////////////////////////////////////////

@interface HCRTallySheetDetailInputViewController ()

@end

////////////////////////////////////////////////////////////////////////////////

@implementation HCRTallySheetDetailInputViewController

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
    
    NSParameterAssert(self.headerDictionary);
    NSParameterAssert(self.questionsArray);
    
    self.title = [self.headerDictionary objectForKey:@"Header" ofClass:@"NSString"];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.collectionView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.925];
    
    HCRTableFlowLayout *tableLayout = (HCRTableFlowLayout *)self.collectionView.collectionViewLayout;
    NSParameterAssert([tableLayout isKindOfClass:[HCRTableFlowLayout class]]);
    [tableLayout setDisplayHeader:YES withSize:[HCRTableFlowLayout preferredHeaderSizeForCollectionView:self.collectionView]];
    tableLayout.sectionInset = UIEdgeInsetsMake(12, 0, 12, 0);
    
    [self.collectionView registerClass:[HCRDataEntryCell class]
            forCellWithReuseIdentifier:kTallyDetailInputCellIdentifier];
    
    [self.collectionView registerClass:[UICollectionReusableView class]
            forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                   withReuseIdentifier:kTallyDetailInputHeaderIdentifier];
    
    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:backgroundImageView];
    [self.view sendSubviewToBack:backgroundImageView];
    
    UIView *background = [[UIView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:background];
    [self.view sendSubviewToBack:background];
    
    UIImage *clusterImage = [[UIImage imageNamed:[self.selectedClusterMetaData objectForKey:@"Image"]] colorImage:[UIColor lightGrayColor]
                                                                                                    withBlendMode:kCGBlendModeNormal
                                                                                                 withTransparency:YES];
    background.backgroundColor = [UIColor colorWithPatternImage:clusterImage];
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
    
    return self.questionsArray.count;
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HCRDataEntryCell *dataCell = [collectionView dequeueReusableCellWithReuseIdentifier:kTallyDetailInputCellIdentifier forIndexPath:indexPath];
    
    NSString *questionString = [self.questionsArray objectAtIndex:indexPath.row ofClass:@"NSString"];
    
    dataCell.cellStatus = HCRDataEntryCellStatusNotCompleted;
    dataCell.dataDictionary = @{@"Title": questionString,
                                @"Input": @"enter data"};
    
    return dataCell;
    
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        
        NSString *headerString = [self.headerDictionary objectForKey:@"Subheader" ofClass:@"NSString"];
        UICollectionReusableView *header = [UICollectionReusableView headerForUNHCRCollectionView:collectionView
                                                                                       identifier:kTallyDetailInputHeaderIdentifier
                                                                                        indexPath:indexPath
                                                                                            title:headerString];
        
        return header;
        
    }
    
    return nil;
    
}

#pragma mark - UICollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    //
    
}

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HCRDataEntryCell *cell = (HCRDataEntryCell *)[collectionView cellForItemAtIndexPath:indexPath];
    NSParameterAssert([cell isKindOfClass:[HCRDataEntryCell class]]);
    
    [cell.dataEntryButton setHighlighted:YES];
    
}

- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    
    HCRDataEntryCell *cell = (HCRDataEntryCell *)[collectionView cellForItemAtIndexPath:indexPath];
    NSParameterAssert([cell isKindOfClass:[HCRDataEntryCell class]]);
    
    [cell.dataEntryButton setHighlighted:NO];
    
}

@end
