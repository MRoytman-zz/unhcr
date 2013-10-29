//
//  HCRSignInFieldCell.h
//  UNHCR
//
//  Created by Sean Conrad on 10/28/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRCollectionCell.h"

@class HCRSignInFieldCell;

////////////////////////////////////////////////////////////////////////////////

typedef NS_ENUM(NSInteger, HCRSignInFieldType) {
    HCRSignInFieldTypeEmail,
    HCRSignInFieldTypePassword
};

////////////////////////////////////////////////////////////////////////////////

@protocol HCRSignInFieldCellDelegate <NSObject>
@optional
- (void)signInFieldCellDidBecomeFirstResponder:(HCRSignInFieldCell *)signInCell;
- (void)signInFieldCellDidResignFirstResponder:(HCRSignInFieldCell *)signInCell;
- (void)signInFieldCellDidPressDone:(HCRSignInFieldCell *)signInCell;
@end

////////////////////////////////////////////////////////////////////////////////

@interface HCRSignInFieldCell : HCRCollectionCell
<UITextFieldDelegate>

@property (nonatomic, weak) id<HCRSignInFieldCellDelegate> signInDelegate;

@property (nonatomic) HCRSignInFieldType fieldType;

@property (nonatomic, strong) NSString *labelTitle;
@property (nonatomic, strong) NSString *inputPlaceholder;

@property (nonatomic, readonly) UITextField *inputField;

@end
