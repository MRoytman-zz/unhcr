//
//  HCRTallySheetDetailViewController.h
//  UNHCR
//
//  Created by Sean Conrad on 10/6/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRCollectionViewController.h"

@interface HCRTallySheetDetailViewController : HCRCollectionViewController
<UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, strong) NSString *countryName;
@property (nonatomic, strong) NSString *campName;

@property (nonatomic, strong) NSDictionary *campClusterData;
@property (nonatomic, strong) NSDictionary *tallySheetData;
@property (nonatomic, strong) NSDictionary *selectedClusterMetaData;

@end
