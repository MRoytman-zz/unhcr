//
//  HCRClusterFlowLayout.m
//  UNHCR
//
//  Created by Sean Conrad on 10/2/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRClusterFlowLayout.h"

////////////////////////////////////////////////////////////////////////////////

const CGFloat kClusterHeaderHeight = 44;

////////////////////////////////////////////////////////////////////////////////

@implementation HCRClusterFlowLayout

- (void)prepareLayout {
    
    // set initial values of stuff
    
    [super prepareLayout];
    
    // set vars only if not set by owner
    if ( CGSizeEqualToSize(self.itemSize, CGSizeMake(50.0, 50.0)) ) {
        CGFloat itemSize = 93.0; // for 3 items per row
//        CGFloat itemSize = 145.0; // for 2 items per row
        self.itemSize = CGSizeMake(itemSize, itemSize);
    }
    
    if ( UIEdgeInsetsEqualToEdgeInsets(self.sectionInset, UIEdgeInsetsZero)) {
        CGFloat edgeInset = 10.0;
        self.sectionInset = UIEdgeInsetsMake(edgeInset, edgeInset, edgeInset, edgeInset);
    }
    
    self.minimumInteritemSpacing = (self.minimumInteritemSpacing != 0) ? self.minimumInteritemSpacing : 10.0;
    self.minimumLineSpacing = (self.minimumLineSpacing != 0) ? self.minimumLineSpacing : 10.0;
    
}

@end
