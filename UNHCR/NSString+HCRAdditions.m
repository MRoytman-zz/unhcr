//
//  NSString+HCRAdditions.m
//  UNHCR
//
//  Created by Sean Conrad on 10/31/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "NSString+HCRAdditions.h"

@implementation NSString (HCRAdditions)

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
