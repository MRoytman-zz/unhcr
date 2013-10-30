//
//  NSNumberFormatter+HCRAdditions.m
//  UNHCR
//
//  Created by Sean Conrad on 10/29/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "NSNumberFormatter+HCRAdditions.h"

@implementation NSNumberFormatter (HCRAdditions)

+ (NSNumberFormatter *)numberFormatterWithFormat:(HCRNumberFormat)numberFormat {
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    
    switch (numberFormat) {
        case HCRNumberFormatThousandsSeparated:
            formatter.usesGroupingSeparator = YES;
            formatter.groupingSeparator = [[NSLocale currentLocale] objectForKey:NSLocaleGroupingSeparator];
            formatter.groupingSize = 3;
            break;
    }
    
    return formatter;
    
}

@end
