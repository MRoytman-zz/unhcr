//
//  UIViewController+EAAdditions.m
//  evilapples
//
//  Created by Danny Ricciotti on 6/15/13.
//  Copyright (c) 2013 Danny Ricciotti. All rights reserved.
//

#import "UIViewController+EAAdditions.h"

@implementation UIViewController (EAAdditions)

- (BOOL)isOnScreen {
    if (self.isViewLoaded && self.view.window) {
        return YES;
    }
    return NO;
}

@end
