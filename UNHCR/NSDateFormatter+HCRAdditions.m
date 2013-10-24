//
//  NSDateFormatter+HCRAdditions.m
//  UNHCR
//
//  Created by Sean Conrad on 10/24/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "NSDateFormatter+HCRAdditions.h"

@implementation NSDateFormatter (HCRAdditions)

+ (NSDateFormatter *)dateFormatterWithFormat:(HCRDateFormat)dateFormat {
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    
    switch (dateFormat) {
        case HCRDateFormatMMddd:
            dateFormatter.dateFormat = @"MMM dd";
            break;
    }
    
    return dateFormatter;
    
}

@end
