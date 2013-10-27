//
//  HCRCollectionViewController.m
//  UNHCR
//
//  Created by Sean Conrad on 10/4/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRCollectionViewController.h"

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

@end
