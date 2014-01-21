//
//  HCRDataEntryViewCell.m
//  UNHCR
//
//  Created by Sean Conrad on 1/20/14.
//  Copyright (c) 2014 Sean Conrad. All rights reserved.
//

#import "HCRDataEntryViewCell.h"

////////////////////////////////////////////////////////////////////////////////

@interface HCRDataEntryViewCell ()

@property (nonatomic, readwrite) UITextView *inputTextView;

@end

////////////////////////////////////////////////////////////////////////////////

@implementation HCRDataEntryViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.inputTextView = [[UITextView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.inputTextView];
        
        self.inputTextView.delegate = self;
        
        self.inputTextView.font = [UIFont systemFontOfSize:14.0];
        self.inputTextView.backgroundColor = self.contentView.backgroundColor;
        
        self.inputTextView.inputAccessoryView = self.doneAccessoryView;
        self.inputTextView.inputAccessoryView.hidden = YES;
        
        self.inputView = self.inputTextView;
        
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.inputTextView.text = nil;
    
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    self.inputTextView.frame = CGRectMake(self.indentForContent,
                                       0,
                                       CGRectGetWidth(self.bounds) - self.indentForContent,
                                       CGRectGetHeight(self.bounds));
    
    [self bringSubviewToFront:self.bottomLineView];
    
}

#pragma mark - UITextField Delegate

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if ([self.delegate respondsToSelector:@selector(dataEntryCellDidBecomeFirstResponder:)]) {
        [self.delegate dataEntryCellDidBecomeFirstResponder:self];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if ([self.delegate respondsToSelector:@selector(dataEntryCellDidResignFirstResponder:)]) {
        [self.delegate dataEntryCellDidResignFirstResponder:self];
    }
}

@end
