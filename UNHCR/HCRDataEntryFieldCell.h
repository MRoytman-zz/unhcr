//
//  HCRSignInFieldCell.h
//  UNHCR
//
//  Created by Sean Conrad on 10/28/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRCollectionCell.h"

@class HCRDataEntryFieldCell;

////////////////////////////////////////////////////////////////////////////////

typedef NS_ENUM(NSInteger, HCRDataEntryFieldType) {
    HCRDataEntryFieldTypeDefault,
    HCRDataEntryFieldTypeEmail,
    HCRDataEntryFieldTypeNumber,
    HCRDataEntryFieldTypePassword
};

////////////////////////////////////////////////////////////////////////////////

@protocol HCRDataEntryFieldCellDelegate <NSObject>
@optional
- (void)dataEntryFieldCellDidBecomeFirstResponder:(HCRDataEntryFieldCell *)signInCell;
- (void)dataEntryFieldCellDidResignFirstResponder:(HCRDataEntryFieldCell *)signInCell;
- (void)dataEntryFieldCellDidPressDone:(HCRDataEntryFieldCell *)signInCell;
@end

////////////////////////////////////////////////////////////////////////////////

@interface HCRDataEntryFieldCell : HCRCollectionCell
<UITextFieldDelegate>

@property (nonatomic, weak) id<HCRDataEntryFieldCellDelegate> dataDelegate;

@property (nonatomic) HCRDataEntryFieldType fieldType;

@property (nonatomic) BOOL lastFieldInSeries;

@property (nonatomic, strong) NSString *labelTitle;
@property (nonatomic, strong) NSString *inputPlaceholder;

@property (nonatomic, readonly) UILabel *titleLabel;
@property (nonatomic, readonly) UITextField *inputField;

@end
