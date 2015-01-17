//
//  HCRDataEntryCell.m
//  UNHCR
//
//  Created by Sean Conrad on 1/20/14.
//  Copyright (c) 2014 Sean Conrad. All rights reserved.
//

#import "HCRDataEntryCell.h"

////////////////////////////////////////////////////////////////////////////////

@interface HCRDataEntryCell ()

@property (nonatomic, readwrite) UIButton *doneAccessoryView;

@end

////////////////////////////////////////////////////////////////////////////////

@implementation HCRDataEntryCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        CGFloat buttonHeight = 40;
        self.doneAccessoryView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 0, buttonHeight)];
        
        CGFloat lineHeight = 1;
        UIView *topLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, lineHeight)];
        [self.doneAccessoryView addSubview:topLineView];
        topLineView.backgroundColor = [UIColor darkGrayColor];
        UIView *bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(0, buttonHeight - lineHeight, 320, lineHeight)];
        [self.doneAccessoryView addSubview:bottomLineView];
        bottomLineView.backgroundColor = [UIColor darkGrayColor];
        
        self.doneAccessoryView.backgroundColor = [UIColor flatOrangeColor];
        
        [self.doneAccessoryView setTitle:@"Done" forState:UIControlStateNormal];
        
        self.doneAccessoryView.titleLabel.font = [UIFont boldSystemFontOfSize:20];
        
        [self.doneAccessoryView addTarget:self action:@selector(_doneButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

#pragma mark - Private Methods

- (void)_doneButtonPressed {
    if ([self.delegate respondsToSelector:@selector(dataEntryCellDidPressDone:)]) {
        [self.delegate dataEntryCellDidPressDone:self];
    }
}

@end
