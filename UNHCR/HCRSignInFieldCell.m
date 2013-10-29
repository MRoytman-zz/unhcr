//
//  HCRSignInFieldCell.m
//  UNHCR
//
//  Created by Sean Conrad on 10/28/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRSignInFieldCell.h"

////////////////////////////////////////////////////////////////////////////////

@interface HCRSignInFieldCell ()

@property UILabel *titleLabel;
@property (nonatomic, strong) UITextField *inputField;

@end

////////////////////////////////////////////////////////////////////////////////

@implementation HCRSignInFieldCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.titleLabel];
        
        self.inputField = [[UITextField alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.inputField];
        
        self.inputField.delegate = self;
        
        self.inputField.font = [UIFont systemFontOfSize:(self.titleLabel.font.pointSize - 1.0)];
        self.inputField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.labelTitle = nil;
    self.inputPlaceholder = nil;
    
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
    self.inputField.frame = CGRectMake(xInputOrigin + kXIndent,
                                       0,
                                       CGRectGetWidth(self.bounds) - xInputOrigin - (2 * kXIndent),
                                       CGRectGetHeight(self.bounds));
    
    self.inputField.backgroundColor = self.contentView.backgroundColor;
    
    [self bringSubviewToFront:self.bottomLineView];
    
}

#pragma mark - UITextField Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if ([self.signInDelegate respondsToSelector:@selector(signInFieldCellDidBecomeFirstResponder:)]) {
        [self.signInDelegate signInFieldCellDidBecomeFirstResponder:self];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if ([self.signInDelegate respondsToSelector:@selector(signInFieldCellDidResignFirstResponder:)]) {
        [self.signInDelegate signInFieldCellDidResignFirstResponder:self];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([self.signInDelegate respondsToSelector:@selector(signInFieldCellDidPressDone:)]) {
        [self.signInDelegate signInFieldCellDidPressDone:self];
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
    
    self.inputField.placeholder = inputPlaceholder;
    
}

- (void)setFieldType:(HCRSignInFieldType)fieldType {
    
    _fieldType = fieldType;
    
    BOOL isPasswordType = (fieldType == HCRSignInFieldTypePassword);
    
    self.inputField.secureTextEntry = isPasswordType;
    
    self.inputField.returnKeyType = (isPasswordType) ? UIReturnKeyDone : UIReturnKeyNext;
    self.inputField.autocorrectionType = (isPasswordType) ? UITextAutocorrectionTypeNo : UITextAutocorrectionTypeDefault;
    
    self.inputField.keyboardType = (fieldType == HCRSignInFieldTypeEmail) ? UIKeyboardTypeEmailAddress : UIKeyboardTypeDefault;
    
}

@end
