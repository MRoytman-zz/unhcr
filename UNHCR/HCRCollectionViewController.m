//
//  HCRCollectionViewController.m
//  UNHCR
//
//  Created by Sean Conrad on 10/4/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRCollectionViewController.h"
#import "HCRTableButtonCell.h"
#import "HCRGraphCell.h"
#import "HCRDataEntryCell.h"
#import "HCRCollectionCell.h"
#import "HCRSignInFieldCell.h"

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
        HCRCollectionCell *cell = (HCRCollectionCell *)[collectionView cellForItemAtIndexPath:indexPath];
        NSParameterAssert([cell isKindOfClass:[HCRCollectionCell class]]);
        
        if ([cell isKindOfClass:[HCRGraphCell class]] ||
            [cell isKindOfClass:[HCRSignInFieldCell class]]) {
            return;
        }
        
        if ([cell isKindOfClass:[HCRTableButtonCell class]]) {
            HCRTableButtonCell *buttonCell = (HCRTableButtonCell *)[collectionView cellForItemAtIndexPath:indexPath];
            [buttonCell.tableButton setHighlighted:YES];
        } else if ([cell isKindOfClass:[HCRDataEntryCell class]]) {
            HCRDataEntryCell *dataCell = (HCRDataEntryCell *)cell;
            [dataCell.dataEntryButton setHighlighted:YES];
        } else {
            cell.contentView.backgroundColor = cell.highlightedColor;
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.highlightCells) {
        HCRCollectionCell *cell = (HCRCollectionCell *)[collectionView cellForItemAtIndexPath:indexPath];
        NSParameterAssert([cell isKindOfClass:[HCRCollectionCell class]]);
        
        if ([cell isKindOfClass:[HCRGraphCell class]] ||
            [cell isKindOfClass:[HCRSignInFieldCell class]]) {
            return;
        }
        
        if ([cell isKindOfClass:[HCRTableButtonCell class]]) {
            HCRTableButtonCell *buttonCell = (HCRTableButtonCell *)cell;
            [buttonCell.tableButton setHighlighted:NO];
        } else if ([cell isKindOfClass:[HCRDataEntryCell class]]) {
            HCRDataEntryCell *dataCell = (HCRDataEntryCell *)cell;
            [dataCell.dataEntryButton setHighlighted:NO];
        } else {
            cell.contentView.backgroundColor = [UIColor whiteColor];
        }
    }
}

@end
