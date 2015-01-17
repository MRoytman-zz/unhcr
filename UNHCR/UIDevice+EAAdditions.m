//
//  UIDevice+EAAdditions.m
//  evilapples
//
//  Created by Danny Ricciotti on 5/20/13.
//  Copyright (c) 2013 Danny Ricciotti. All rights reserved.
//

#import "UIDevice+EAAdditions.h"

#ifdef __APPLE__
#include "TargetConditionals.h"
#endif

@implementation UIDevice (EAAdditions)

+ (BOOL)isFourInch
{
    static dispatch_once_t onceToken;
    static BOOL itIs = NO;
    dispatch_once(&onceToken, ^{
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        if (screenBounds.size.height == 568) {
            itIs = YES;
        }
        
    });
    return itIs;
}

+ (BOOL)isSimulator {
    
#if (TARGET_IPHONE_SIMULATOR)
    return YES;
#else
    return NO;
#endif
    
}

+ (BOOL)isIOS7 {
    
    return ( [[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0 );
    
}

+ (BOOL)isRetina
{
    return ([UIScreen mainScreen].scale >= 2.0);
}

@end
