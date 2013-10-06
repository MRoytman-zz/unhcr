//
//  HCRDataSource.h
//  UNHCR
//
//  Created by Sean Conrad on 10/1/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HCRDataSource : NSObject

+ (NSArray *)globalDataArray;
+ (NSArray *)clusterLayoutMetaDataArray;

@end
