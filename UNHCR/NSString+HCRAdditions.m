//
//  NSString+HCRAdditions.m
//  UNHCR
//
//  Created by Sean Conrad on 10/31/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "NSString+HCRAdditions.h"

@implementation NSString (HCRAdditions)

- (CGSize)sizeWithBoundingSize:(CGSize)boundingSize withFont:(UIFont *)font rounded:(BOOL)rounded {
    
    NSAssert(font, @"Font must not be nil!");
    
    CGRect stringRect = [self boundingRectWithSize:boundingSize
                                           options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading
                                        attributes:@{NSFontAttributeName: font}
                                           context:nil];
    
    CGSize finalSize = (rounded) ? CGSizeMake(ceilf(stringRect.size.width), ceilf(stringRect.size.height)) : stringRect.size;
    
    return finalSize;
}

@end
