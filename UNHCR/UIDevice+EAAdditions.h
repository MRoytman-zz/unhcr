//
//  UIDevice+EAAdditions.h
//  evilapples
//
//  Created by Danny Ricciotti on 5/20/13.
//  Copyright (c) 2013 Danny Ricciotti. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIDevice (EAAdditions)

+ (BOOL)isFourInch;
+ (BOOL)isSimulator;
+ (BOOL)isIOS7;
+ (BOOL)isRetina;

@end
