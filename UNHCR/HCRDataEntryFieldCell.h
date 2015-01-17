//
//  HCRSignInFieldCell.h
//  UNHCR
//
//  Created by Sean Conrad on 10/28/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRDataEntryCell.h"

@interface HCRDataEntryFieldCell : HCRDataEntryCell
<UITextFieldDelegate>

@property (nonatomic) BOOL lastFieldInSeries;

@property (nonatomic, strong) NSString *labelTitle;
@property (nonatomic, strong) NSString *inputPlaceholder;

@property (nonatomic, readonly) UILabel *titleLabel;
@property (nonatomic, readonly) UITextField *inputTextField;

@end
