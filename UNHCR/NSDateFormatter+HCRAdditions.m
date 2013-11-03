//
//  NSDateFormatter+HCRAdditions.m
//  UNHCR
//
//  Created by Sean Conrad on 10/24/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "NSDateFormatter+HCRAdditions.h"

@implementation NSDateFormatter (HCRAdditions)

+ (NSDateFormatter *)dateFormatterWithFormat:(HCRDateFormat)dateFormat forceEuropeanFormat:(BOOL)forceFormat {
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    
    switch (dateFormat) {
        case HCRDateFormatHHmm:
            dateFormatter.dateFormat = @"HH:mm";
            break;
            
        case HCRDateFormatddMMM:
            dateFormatter.dateFormat = @"dd MMM";
            break;
            
        case HCRDateFormatMMMdd:
            dateFormatter.dateFormat = @"MMM dd";
            break;
            
        case HCRDateFormatMMMddHHmm:
            dateFormatter.dateFormat = @"MMM dd, HH:mm";
            break;
            
        case HCRDateFormatMMMddhmma:
            dateFormatter.dateFormat = @"MMM dd, h:mm a";
            break;
            
        case HCRDateFormatSMSDates:
        case HCRDateFormatSMSDatesWithTime:
            dateFormatter.timeStyle = (dateFormat == HCRDateFormatSMSDatesWithTime) ? NSDateFormatterShortStyle : NSDateFormatterNoStyle;
            dateFormatter.dateStyle = NSDateFormatterShortStyle;
            dateFormatter.locale = (forceFormat) ? [NSLocale localeWithLocaleIdentifier:@"en_GB"] : [NSLocale currentLocale];
            dateFormatter.doesRelativeDateFormatting = YES;
            break;
    }
    
    return dateFormatter;
    
}

@end
