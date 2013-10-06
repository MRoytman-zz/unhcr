//
//  HCRDataEntryCell.h
//  UNHCR
//
//  Created by Sean Conrad on 10/6/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import <UIKit/UIKit.h>

////////////////////////////////////////////////////////////////////////////////

typedef NS_ENUM(NSInteger, HCRDataEntryCellType) {
    HCRDataEntryCellTypeNotCompleted,
    HCRDataEntryCellTypeCompleted,
    HCRDataEntryCellTypeStatic
};

////////////////////////////////////////////////////////////////////////////////

@interface HCRDataEntryCell : UICollectionViewCell

@property (nonatomic) HCRDataEntryCellType cellType;

// dataDictionary fields
// Header - BOOL - if present, line is header object and deserves more weight
// Title - NSString - left aligned bolded string
// Subtitle - NSString - left aligned non-bolded string below title
// Input - NSString - right aligned string representing input (blue button if notCompleted, green checkmark if completed, black if static)
@property (nonatomic, strong) NSDictionary *dataDictionary;

@property (nonatomic, readonly) UIButton *dataEntryButton;

@end
