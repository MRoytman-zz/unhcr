//
//  HCRTallySheetInputViewController.h
//  UNHCR
//
//  Created by Sean Conrad on 10/6/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRCollectionViewController.h"

@interface HCRTallySheetDetailInputViewController : HCRCollectionViewController

@property (nonatomic, strong) NSDictionary *headerDictionary;
@property (nonatomic, strong) NSArray *questionsArray;

@end
