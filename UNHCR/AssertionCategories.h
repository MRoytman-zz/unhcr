//
//  AssertionCategories.h
//  evilapples
//
//  Created by Danny on 1/8/13.
//  Copyright (c) 2013 Danny Ricciotti. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (AssertionCategories)

- (id)objectForKey:(id)aKey ofClass:(NSString *)aClassName;
- (id)objectForKey:(id)aKey ofClass:(NSString *)aClassName mustExist:(BOOL)mustExist;

@end

@interface NSArray (AssertionCategories)

- (id)objectAtIndex:(NSUInteger)index ofClass:(NSString *)aClassName;

@end