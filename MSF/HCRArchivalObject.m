//
//  HCRArchivalObject.m
//  UNHCR
//
//  Created by Sean Conrad on 1/8/14.
//  Copyright (c) 2014 Sean Conrad. All rights reserved.
//

#import "HCRArchivalObject.h"

@implementation HCRArchivalObject

//- (NSString *)description {
//    
//    if (self.propertyList.count == 0) {
//        return [super description];
//    }
//    
//    NSMutableDictionary *dictionary = @{}.mutableCopy;
//    
//    for (NSString *property in self.propertyList) {
//        SEL selector = NSSelectorFromString(property);
//        id object = [self performSelector:selector];
//        if (object) {
//            dictionary[property] = object;
//        }
//    }
//    
////    NSString *rawString = [dictionary description];
////    NSData *stringData = [rawString dataUsingEncoding:NSStringEncodingConversionAllowLossy];
//    
//    NSData *dictionaryData = [NSKeyedArchiver archivedDataWithRootObject:dictionary];
//    
//    NSError *error;
//    NSString *jsonString =[NSJSONSerialization JSONObjectWithData:dictionaryData options:NSJSONReadingMutableLeaves error:&error];
//    
//    return jsonString;
//    
////    NSMutableString *niceDescription = [NSMutableString new];
////    
////    for (NSString *property in self.propertyList) {
////        SEL selector = NSSelectorFromString(property);
////        [niceDescription appendFormat:@"%@ = %@,%@",
////         NSStringFromSelector(selector),
////         [self performSelector:selector],
////         @"\n"];
////    }
////    
////    return niceDescription;
//    
//}

@end
