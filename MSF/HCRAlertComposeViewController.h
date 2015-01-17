//
//  HCRAlertComposeViewController.h
//  UNHCR
//
//  Created by Sean Conrad on 1/20/14.
//  Copyright (c) 2014 Sean Conrad. All rights reserved.
//

#import "HCRCollectionViewController.h"
#import "HCRDataEntryCell.h"

@interface HCRAlertComposeViewController : HCRCollectionViewController
<HCRDataEntryCellDelegate, UICollectionViewDelegateFlowLayout>

@end
