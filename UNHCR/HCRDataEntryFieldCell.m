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
@property (nonatomic, readwrite) UITextField *inputField;
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
        
        self.inputField = [[UITextField alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:self.inputField];
        
        self.inputField.delegate = self;
        
        self.inputField.font = [UIFont systemFontOfSize:(self.titleLabel.font.pointSize - 1.0)];
        self.inputField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        
        self.lastFieldInSeries = NO;
        
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.inputField.text = nil;
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
    self.inputField.frame = CGRectMake(xInputOrigin + kXIndent,
                                       0,
                                       CGRectGetWidth(self.bounds) - xInputOrigin - (2 * kXIndent),
                                       CGRectGetHeight(self.bounds));
    
    self.inputField.backgroundColor = self.contentView.backgroundColor;
    
    [self bringSubviewToFront:self.bottomLineView];
    
}

#pragma mark - UITextField Delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if ([self.dataDelegate respondsToSelector:@selector(dataEntryFieldCellDidBecomeFirstResponder:)]) {
        [self.dataDelegate dataEntryFieldCellDidBecomeFirstResponder:self];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if ([self.dataDelegate respondsToSelector:@selector(dataEntryFieldCellDidResignFirstResponder:)]) {
        [self.dataDelegate dataEntryFieldCellDidResignFirstResponder:self];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if ([self.dataDelegate respondsToSelector:@selector(dataEntryFieldCellDidPressDone:)]) {
        [self.dataDelegate dataEntryFieldCellDidPressDone:self];
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

- (void)setFieldType:(HCRDataEntryFieldType)fieldType {
    
    _fieldType = fieldType;
    
    BOOL isPasswordType = (fieldType == HCRDataEntryFieldTypePassword);
    BOOL isEmailType = (fieldType == HCRDataEntryFieldTypeEmail);
    
    self.inputField.secureTextEntry = isPasswordType;
    self.inputField.autocorrectionType = (isPasswordType || isEmailType) ? UITextAutocorrectionTypeNo : UITextAutocorrectionTypeDefault;
    
    UIKeyboardType keyboardType;
    BOOL hideAccessoryView;
    
    if (fieldType == HCRDataEntryFieldTypeNumber &&
        !self.doneAccessoryView) {
        
        CGFloat buttonHeight = 40;
        self.doneAccessoryView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 0, buttonHeight)];
        self.inputField.inputAccessoryView = self.doneAccessoryView;
        
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
    
    switch (fieldType) {
        case HCRDataEntryFieldTypeDefault:
        case HCRDataEntryFieldTypePassword:
            keyboardType = UIKeyboardTypeDefault;
            hideAccessoryView = YES;
            break;
            
        case HCRDataEntryFieldTypeEmail:
            keyboardType = UIKeyboardTypeEmailAddress;
            hideAccessoryView = YES;
            break;
            
        case HCRDataEntryFieldTypeNumber:
            keyboardType = UIKeyboardTypeNumberPad;
            hideAccessoryView = NO;
            break;
    }
    
    self.inputField.keyboardType = keyboardType;
    self.inputField.inputAccessoryView.hidden = hideAccessoryView;
    
}

- (void)setLastFieldInSeries:(BOOL)lastFieldInSeries {
    
    _lastFieldInSeries = lastFieldInSeries;
    
    self.inputField.returnKeyType = (lastFieldInSeries) ? UIReturnKeyDone : UIReturnKeyNext;
    
}

#pragma mark - Private Methods

- (void)_doneButtonPressed {
    if ([self.dataDelegate respondsToSelector:@selector(dataEntryFieldCellDidPressDone:)]) {
        [self.dataDelegate dataEntryFieldCellDidPressDone:self];
    }
}

@end
