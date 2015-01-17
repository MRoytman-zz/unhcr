//
//  HCRDataSource.h
//  UNHCR
//
//  Created by Sean Conrad on 10/1/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HCRDataSource : NSObject

+ (NSArray *)globalCampDataArray;
+ (NSArray *)globalMessagesData;
+ (NSArray *)globalAllBulletinsData;
+ (NSArray *)globalEmergenciesData;
+ (NSArray *)globalOnlyBulletinsData;

+ (NSDictionary *)iraqDomizCampData;
+ (NSArray *)iraqDomizAgenciesData;

+ (NSArray *)clusterLayoutMetaDataArray;
+ (UIImage *)imageForClusterName:(NSString *)clusterName;

@end
