//
//  HCRArchivalObject.m
//  UNHCR
//
//  Created by Sean Conrad on 1/8/14.
//  Copyright (c) 2014 Sean Conrad. All rights reserved.
//

#import "HCRArchivalObject.h"

@implementation HCRArchivalObject

- (NSString *)description {
    
    if (self.propertyList.count == 0) {
        return [super description];
    }
    
    NSMutableString *niceDescription = [NSMutableString new];
    for (NSString *property in self.propertyList) {
        SEL selector = NSSelectorFromString(property);
        [niceDescription appendFormat:@"%@ = %@,%@",
         NSStringFromSelector(selector),
         [self performSelector:selector],
         @"\n"];
    }
    return niceDescription;
    
}

@end
