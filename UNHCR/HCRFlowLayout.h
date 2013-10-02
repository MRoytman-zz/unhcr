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

+ (CGFloat)preferredHeaderHeight;

- (void)setDisplayHeader:(BOOL)displayHeader withSize:(CGSize)size;

@end
