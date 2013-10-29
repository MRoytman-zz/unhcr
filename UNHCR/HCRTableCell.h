//
//  HCRTableCell.h
//  UNHCR
//
//  Created by Sean Conrad on 10/28/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRCollectionCell.h"

@interface HCRTableCell : HCRCollectionCell

@property (nonatomic, strong) UIImage *badgeImage;
@property (nonatomic, readonly) UIImageView *badgeImageView;

@property (nonatomic, strong) NSString *labelTitle;

@end
