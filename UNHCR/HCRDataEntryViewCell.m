//
//  HCRDataEntryViewCell.m
//  UNHCR
//
//  Created by Sean Conrad on 1/20/14.
//  Copyright (c) 2014 Sean Conrad. All rights reserved.
//

#import "HCRDataEntryViewCell.h"

////////////////////////////////////////////////////////////////////////////////

const CGFloat kYPadding = 10;

const CGFloat kFontSize = 16.0;

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
        
        self.inputTextView.font = [UIFont systemFontOfSize:kFontSize];
        self.inputTextView.backgroundColor = self.contentView.backgroundColor;
        
        self.inputTextView.inputAccessoryView = self.doneAccessoryView;
        
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
                                          kYPadding,
                                          CGRectGetWidth(self.bounds) - self.indentForContent - self.trailingSpaceForContent,
                                          CGRectGetHeight(self.bounds) - 2 * kYPadding);
    
    [self bringSubviewToFront:self.bottomLineView];
    
}

#pragma mark - Class Methods

+ (CGSize)preferredSizeForCollectionView:(UICollectionView *)collectionView {
    
    return CGSizeMake(CGRectGetWidth(collectionView.bounds),
                      0.35 * CGRectGetHeight(collectionView.bounds));
    
}

#pragma mark - UITextField Delegate

- (void)textViewDidChange:(UITextView *)textView {
    if ([self.delegate respondsToSelector:@selector(dataEntryCellDidEnterText:)]) {
        [self.delegate dataEntryCellDidEnterText:self];
    }
}

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
