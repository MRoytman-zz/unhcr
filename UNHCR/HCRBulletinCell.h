//
//  HCRBulletinCell.h
//  UNHCR
//
//  Created by Sean Conrad on 10/30/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRCollectionCell.h"

@interface HCRBulletinCell : HCRCollectionCell

@property (nonatomic, strong) NSDictionary *bulletinDictionary;

@property (nonatomic, readonly) UIButton *replyButton;
@property (nonatomic, readonly) UIButton *forwardButton;

+ (CGSize)sizeForCellInCollectionView:(UICollectionView *)collectionView withBulletinDictionary:(NSDictionary *)bulletinDictionary;

- (NSString *)emailSenderString;
- (NSString *)emailSubjectStringWithPrefix:(NSString *)prefix;
- (NSString *)emailBodyString;

@end
