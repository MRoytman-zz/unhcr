//
//  NSDateFormatter+HCRAdditions.h
//  UNHCR
//
//  Created by Sean Conrad on 10/24/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import <Foundation/Foundation.h>

////////////////////////////////////////////////////////////////////////////////

typedef NS_ENUM(NSInteger, HCRDateFormat) {
    HCRDateFormatMMMdd,
    HCRDateFormatMMMddHHmm,
    HCRDateFormatMMMddhmma
};

////////////////////////////////////////////////////////////////////////////////

@interface NSDateFormatter (HCRAdditions)

+ (NSDateFormatter *)dateFormatterWithFormat:(HCRDateFormat)dateFormat;

@end
