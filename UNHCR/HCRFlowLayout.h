//
//  HCRFlowLayout.h
//  UNHCR
//
//  Created by Sean Conrad on 10/2/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HCRFlowLayout : UICollectionViewFlowLayout

@property (nonatomic, readonly) BOOL displayHeader;
@property (nonatomic, readonly) BOOL displayFooter;

- (void)setDisplayHeader:(BOOL)displayHeader withSize:(CGSize)size;
- (void)setDisplayFooter:(BOOL)displayFooter withSize:(CGSize)size;

@end
