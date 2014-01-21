//
//  HCRDataEntryCell.h
//  UNHCR
//
//  Created by Sean Conrad on 1/20/14.
//  Copyright (c) 2014 Sean Conrad. All rights reserved.
//

#import "HCRCollectionCell.h"

@class HCRDataEntryCell;

////////////////////////////////////////////////////////////////////////////////

typedef NS_ENUM(NSInteger, HCRDataEntryType) {
    HCRDataEntryTypeDefault,
    HCRDataEntryTypeEmail,
    HCRDataEntryTypeNumber,
    HCRDataEntryTypePassword
};

////////////////////////////////////////////////////////////////////////////////

@protocol HCRDataEntryCellDelegate <NSObject>
@optional
- (void)dataEntryCellDidBecomeFirstResponder:(HCRDataEntryCell *)dataCell;
- (void)dataEntryCellDidResignFirstResponder:(HCRDataEntryCell *)dataCell;
- (void)dataEntryCellDidPressDone:(HCRDataEntryCell *)dataCell;
@end

////////////////////////////////////////////////////////////////////////////////

@interface HCRDataEntryCell : HCRCollectionCell

@property (nonatomic, weak) id<HCRDataEntryCellDelegate> delegate;

@property (nonatomic) HCRDataEntryType inputType;

@property (nonatomic, strong) UIView *inputView;

@property (nonatomic, readonly) UIButton *doneAccessoryView;

@end
