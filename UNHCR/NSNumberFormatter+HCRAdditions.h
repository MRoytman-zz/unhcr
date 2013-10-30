//
//  NSNumberFormatter+HCRAdditions.h
//  UNHCR
//
//  Created by Sean Conrad on 10/29/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import <Foundation/Foundation.h>

////////////////////////////////////////////////////////////////////////////////

typedef NS_ENUM(NSInteger, HCRNumberFormat) {
    HCRNumberFormatThousandsSeparated
};

////////////////////////////////////////////////////////////////////////////////

@interface NSNumberFormatter (HCRAdditions)

+ (NSNumberFormatter *)numberFormatterWithFormat:(HCRNumberFormat)numberFormat;

@end
