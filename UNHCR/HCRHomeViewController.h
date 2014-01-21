//
//  HCRHomeViewController.h
//  UNHCR
//
//  Created by Sean Conrad on 10/2/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRCollectionViewController.h"
#import "HCRDataEntryFieldCell.h"
#import "HCRGraphCell.h"

@interface HCRHomeViewController : HCRCollectionViewController
<UICollectionViewDelegateFlowLayout, HCRDataEntryCellDelegate, SCGraphViewDataSource, SCGraphViewDelegate>

@end
