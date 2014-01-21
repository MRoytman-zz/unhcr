//
//  HCRSignInFieldCell.m
//  UNHCR
//
//  Created by Sean Conrad on 10/28/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRDataEntryFieldCell.h"

////////////////////////////////////////////////////////////////////////////////

@interface HCRDataEntryFieldCell ()

@property (nonatomic, readwrite) UILabel *titleLabel;
@property (nonatomic, readwrite) UITextField *inputTextField;
@property (nonatomic, strong) UIButton *doneAccessoryView;

@end

////////////////////////////////////////////////////////////////////////////////

@implementation HCRDataEntryFieldCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.titleLabel];
        
        self.inputTextField = [[UITextField alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.inputTextField];
        
        self.inputTextField.delegate = self;
        
        self.inputTextField.font = [UIFont systemFontOfSize:(self.titleLabel.font.pointSize - 1.0)];
        self.inputTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        
        self.inputTextField.inputAccessoryView = self.doneAccessoryView;
        self.inputTextField.inputAccessoryView.hidden = YES;
        
        self.inputView = self.inputTextField;
        
        self.lastFieldInSeries = NO;
        
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.inputTextField.text = nil;
    self.labelTitle = nil;
    self.inputPlaceholder = nil;
    self.lastFieldInSeries = NO;
    
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    static const CGFloat kTitleWidth = 82.0;
    self.titleLabel.frame = CGRectMake([HCRCollectionCell preferredIndentForContent],
                                       0,
                                       kTitleWidth,
                                       CGRectGetHeight(self.bounds));
    
    self.titleLabel.backgroundColor = self.contentView.backgroundColor;
    
    static const CGFloat kXIndent = 8.0;
    CGFloat xInputOrigin = CGRectGetMaxX(self.titleLabel.frame);
    self.inputTextField.frame = CGRectMake(xInputOrigin + kXIndent,
                                       0,
                                       CGRectGetWidth(self.bounds) - xInputOrigin - (2 * kXIndent),
                                       CGRectGetHeight(self.bounds));
    
    self.inputTextField.backgroundColor = self.contentView.backgroundColor;
    
    [self bringSubviewToFront:self.bottomLineView];
    
}

#pragma mark - UITextField Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(dataEntryCellDidBecomeFirstResponder:)]) {
        [self.delegate dataEntryCellDidBecomeFirstResponder:self];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(dataEntryCellDidResignFirstResponder:)]) {
        [self.delegate dataEntryCellDidResignFirstResponder:self];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([self.delegate respondsToSelector:@selector(dataEntryCellDidPressDone:)]) {
        [self.delegate dataEntryCellDidPressDone:self];
    }
    return NO;
}

#pragma mark - Getters & Setters

- (void)setLabelTitle:(NSString *)labelTitle {
    
    _labelTitle = labelTitle;
    
    self.titleLabel.text = labelTitle;
    
}

- (void)setInputPlaceholder:(NSString *)inputPlaceholder {
    
    _inputPlaceholder = inputPlaceholder;
    
    self.inputTextField.placeholder = inputPlaceholder;
    
}

- (void)setLastFieldInSeries:(BOOL)lastFieldInSeries {
    
    _lastFieldInSeries = lastFieldInSeries;
    
    self.inputTextField.returnKeyType = (lastFieldInSeries) ? UIReturnKeyDone : UIReturnKeyNext;
    
}

- (void)setInputType:(HCRDataEntryType)inputType {
    
    [super setInputType:inputType];
    
    BOOL isPasswordType = (inputType == HCRDataEntryTypePassword);
    BOOL isEmailType = (inputType == HCRDataEntryTypeEmail);
    
    self.inputTextField.secureTextEntry = isPasswordType;
    self.inputTextField.autocorrectionType = (isPasswordType || isEmailType) ? UITextAutocorrectionTypeNo : UITextAutocorrectionTypeDefault;
    
    UIKeyboardType keyboardType;
    BOOL hideAccessoryView;
    
    switch (inputType) {
        case HCRDataEntryTypeDefault:
        case HCRDataEntryTypePassword:
            keyboardType = UIKeyboardTypeDefault;
            hideAccessoryView = YES;
            break;
            
        case HCRDataEntryTypeEmail:
            keyboardType = UIKeyboardTypeEmailAddress;
            hideAccessoryView = YES;
            break;
            
        case HCRDataEntryTypeNumber:
            keyboardType = UIKeyboardTypeNumberPad;
            hideAccessoryView = NO;
            break;
    }
    
    self.inputTextField.keyboardType = keyboardType;
    self.inputTextField.inputAccessoryView.hidden = hideAccessoryView;
}

@end
