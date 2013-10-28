//
//  HCRCollectionViewController.m
//  UNHCR
//
//  Created by Sean Conrad on 10/4/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRCollectionViewController.h"
#import "HCRButtonListCell.h"
#import "HCRGraphCell.h"
#import "HCRDataEntryCell.h"

////////////////////////////////////////////////////////////////////////////////

@interface HCRCollectionViewController ()

@end

////////////////////////////////////////////////////////////////////////////////

@implementation HCRCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.collectionView.backgroundColor = [UIColor tableBackgroundColor];
}

+ (UICollectionViewLayout *)preferredLayout {
    NSAssert(NO, @"Subclass must override this method. (TODO: Can this be done via protocol?)");
    return nil;
}

#pragma mark - UICollectionView Delegate

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.highlightCells) {
        UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
        
        if ([cell isKindOfClass:[HCRButtonListCell class]]) {
            HCRButtonListCell *buttonCell = (HCRButtonListCell *)[collectionView cellForItemAtIndexPath:indexPath];
            [buttonCell.listButton setHighlighted:YES];
        } else if ([cell isKindOfClass:[HCRDataEntryCell class]]) {
            HCRDataEntryCell *dataCell = (HCRDataEntryCell *)cell;
            [dataCell.dataEntryButton setHighlighted:YES];
        } else if ([cell isKindOfClass:[HCRGraphCell class]] == NO) {
            cell.backgroundColor = [UIColor UNHCRBlue];
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.highlightCells) {
        UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
        
        if ([cell isKindOfClass:[HCRButtonListCell class]]) {
            HCRButtonListCell *buttonCell = (HCRButtonListCell *)cell;
            [buttonCell.listButton setHighlighted:NO];
        } else if ([cell isKindOfClass:[HCRDataEntryCell class]]) {
            HCRDataEntryCell *dataCell = (HCRDataEntryCell *)cell;
            [dataCell.dataEntryButton setHighlighted:NO];
        } else if ([cell isKindOfClass:[HCRGraphCell class]] == NO) {
            cell.backgroundColor = [UIColor whiteColor];
        }
    }
}

@end
