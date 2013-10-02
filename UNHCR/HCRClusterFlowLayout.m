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
        CGFloat itemSize = 70.0;
        self.itemSize = CGSizeMake(itemSize, itemSize);
    }
    
    self.minimumInteritemSpacing = (self.minimumInteritemSpacing != 0) ? self.minimumInteritemSpacing :  0;
    self.minimumLineSpacing = (self.minimumLineSpacing != 0) ? self.minimumLineSpacing :  0;
    
}

@end
