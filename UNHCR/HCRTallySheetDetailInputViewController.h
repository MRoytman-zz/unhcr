//
//  HCRTallySheetInputViewController.h
//  UNHCR
//
//  Created by Sean Conrad on 10/6/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRCollectionViewController.h"
#import "HCRTallyEntryFieldCell.h"

@interface HCRTallySheetDetailInputViewController : HCRCollectionViewController
<UICollectionViewDelegateFlowLayout,
HCRDataEntryCellDelegate>

@property (nonatomic, strong) NSString *resourceName;
@property (nonatomic, strong) NSArray *questionsArray;

@end
