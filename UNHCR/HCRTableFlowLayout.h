//
//  HCRTableFlowLayout.h
//  UNHCR
//
//  Created by Sean Conrad on 9/30/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HCRTableFlowLayout : UICollectionViewFlowLayout

@property (nonatomic, readonly) BOOL displayHeader;

+ (CGFloat)preferredCellHeight;

- (void)setDisplayHeader:(BOOL)displayHeader withSize:(CGSize)size;

@end
