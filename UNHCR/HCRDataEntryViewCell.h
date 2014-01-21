//
//  HCRDataEntryViewCell.h
//  UNHCR
//
//  Created by Sean Conrad on 1/20/14.
//  Copyright (c) 2014 Sean Conrad. All rights reserved.
//

#import "HCRDataEntryCell.h"

@interface HCRDataEntryViewCell : HCRDataEntryCell
<UITextViewDelegate>

@property (nonatomic, readonly) UITextView *inputTextView;

@end
