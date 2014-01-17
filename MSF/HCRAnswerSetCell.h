//
//  HCRAnswerSetCell.h
//  UNHCR
//
//  Created by Sean Conrad on 1/8/14.
//  Copyright (c) 2014 Sean Conrad. All rights reserved.
//

#import "HCRTableCell.h"

@interface HCRAnswerSetCell : HCRTableCell

@property (nonatomic, strong) NSString *answerSetID;

@property (nonatomic) BOOL submitted;
@property (nonatomic) NSInteger percentComplete;

@end
