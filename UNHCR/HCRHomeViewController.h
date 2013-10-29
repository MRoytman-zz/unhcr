//
//  HCRHomeViewController.h
//  UNHCR
//
//  Created by Sean Conrad on 10/2/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRCollectionViewController.h"
#import "HCRSignInFieldCell.h"
#import "HCRGraphCell.h"

@interface HCRHomeViewController : HCRCollectionViewController
<UICollectionViewDelegateFlowLayout, HCRSignInFieldCellDelegate, SCGraphViewDataSource, SCGraphViewDelegate>

@end
