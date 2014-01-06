//
//  NSString+HCRAdditions.m
//  UNHCR
//
//  Created by Sean Conrad on 10/31/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "NSString+HCRAdditions.h"

@implementation NSString (HCRAdditions)

- (BOOL)isValidEmailAddress {
    
    NSString *emailRegex =
    @"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
    @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
    @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
    @"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
    @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
    @"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
    @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES[c] %@", emailRegex];
    
    return [emailTest evaluateWithObject:self];
    
}

- (CGSize)sizeforMultiLineStringWithBoundingSize:(CGSize)boundingSize withFont:(UIFont *)font rounded:(BOOL)rounded {
    
    NSAssert(font, @"Font must not be nil!");
    
    return [self sizeforMultiLineStringWithBoundingSize:boundingSize withAttributes:@{NSFontAttributeName: font} rounded:rounded];
    
}

- (CGSize)sizeforMultiLineStringWithBoundingSize:(CGSize)boundingSize withAttributes:(NSDictionary *)attributes rounded:(BOOL)rounded {
    
    CGRect stringRect = [self boundingRectWithSize:boundingSize
                                           options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                        attributes:attributes
                                           context:nil];
    
    CGSize finalSize = (rounded) ? CGSizeMake(ceilf(stringRect.size.width), ceilf(stringRect.size.height)) : stringRect.size;
    
    return finalSize;
    
}

@end
