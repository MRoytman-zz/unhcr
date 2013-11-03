//
//  NSString+HCRAdditions.h
//  UNHCR
//
//  Created by Sean Conrad on 10/31/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (HCRAdditions)

- (CGSize)sizeWithBoundingSize:(CGSize)boundingSize withFont:(UIFont *)font rounded:(BOOL)rounded;

@end