//
//  HCRLoginMenuScrollView.m
//  UNHCR
//
//  Created by Sean Conrad on 10/5/13.
//  Copyright (c) 2013 Sean Conrad. All rights reserved.
//

#import "HCRHomeLoginMenuScrollView.h"

////////////////////////////////////////////////////////////////////////////////

@interface HCRHomeLoginMenuScrollView ()

@property UILabel *signingInLabel;
@property UIActivityIndicatorView *signingInSpinner;

@property (nonatomic, readwrite) UIButton *loginButton;
@property (nonatomic, readwrite) UIButton *countriesButton;
@property (nonatomic, readwrite) UIButton *campsButton;

@property (nonatomic, readwrite) UIButton *signOutButton;
@property (nonatomic, readwrite) UIButton *settingsButton;

@end

////////////////////////////////////////////////////////////////////////////////

@implementation HCRHomeLoginMenuScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.pagingEnabled = YES;
        self.showsHorizontalScrollIndicator = NO;
        
        self.contentSize = CGSizeMake(CGRectGetWidth(self.frame) * 2.0,
                                      CGRectGetHeight(self.frame));
        
        // country button
        CGFloat buttonPadding = ([UIDevice isFourInch]) ? 10 : 6;
        CGFloat buttonHeight = 50;
        
        CGFloat yButtonOffset = (CGRectGetHeight(self.frame) - (buttonHeight * 2 + buttonPadding)) * 0.5 - 5.0;
        
        self.countriesButton = [UIButton buttonWithUNHCRTextStyleWithString:@"Countries"
                                                        horizontalAlignment:UIControlContentHorizontalAlignmentCenter
                                                                 buttonSize:CGSizeMake(200, buttonHeight)
                                                                   fontSize:nil];
        [self addSubview:self.countriesButton];
        
        self.countriesButton.center = CGPointMake(CGRectGetWidth(self.frame) + CGRectGetMidX(self.bounds),
                                                  MIN(yButtonOffset,25) + CGRectGetMidY(self.countriesButton.bounds));
        
        // camps button
        self.campsButton = [UIButton buttonWithUNHCRTextStyleWithString:@"Camps"
                                                    horizontalAlignment:UIControlContentHorizontalAlignmentCenter
                                                             buttonSize:CGSizeMake(170, buttonHeight)
                                                               fontSize:nil];
        [self addSubview:self.campsButton];
        
        self.campsButton.center = CGPointMake(CGRectGetWidth(self.frame) + CGRectGetMidX(self.bounds),
                                              CGRectGetMaxY(self.countriesButton.frame) + buttonPadding + CGRectGetMidY(self.campsButton.bounds));
        
        // signing in
        self.signingInLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self addSubview:self.signingInLabel];
        
        self.signingInLabel.text = @"Signing in..";
        
        self.signingInLabel.textColor = [UIColor UNHCRBlue];
        self.signingInLabel.font = [UIFont fontWithName:[UIButton preferredFontNameForUNHCRButton] size:30.0];
        
        [self.signingInLabel sizeToFit];
        
        // spinner
        self.signingInSpinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [self addSubview:self.signingInSpinner];
        
        self.signingInSpinner.color = [UIColor UNHCRBlue];
        
        [self.signingInSpinner startAnimating];
        
        // position
        CGFloat padding = 10;
        
        self.signingInSpinner.center = CGPointMake(CGRectGetMidX(self.frame) - (CGRectGetMidX(self.signingInLabel.bounds) + CGRectGetMidX(self.signingInSpinner.bounds) + padding) + CGRectGetMidX(self.signingInSpinner.bounds),
                                                   CGRectGetMidY(self.countriesButton.frame));
        
        self.signingInLabel.center = CGPointMake(CGRectGetMaxX(self.signingInSpinner.frame) + CGRectGetMidX(self.signingInLabel.bounds) + padding,
                                                 CGRectGetMidY(self.countriesButton.frame));
        
        // login button
        self.loginButton = [UIButton buttonWithUNHCRTextStyleWithString:@"Log in"
                                                    horizontalAlignment:UIControlContentHorizontalAlignmentCenter
                                                             buttonSize:CGSizeMake(150, 40)
                                                               fontSize:@30.0];
        [self addSubview:self.loginButton];
        
        self.loginButton.center = CGPointMake(CGRectGetMidX(self.frame),
                                              CGRectGetMidY(self.countriesButton.frame));
        
        // signout button
        CGFloat xSmallButtonOffset = 15;
        CGSize smallButtonSize = CGSizeMake(100, 30);
        self.signOutButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [self addSubview:self.signOutButton];
        
        self.signOutButton.frame = CGRectMake(xSmallButtonOffset,
                                              CGRectGetMidY(self.campsButton.frame),
                                              smallButtonSize.width,
                                              smallButtonSize.height);
        
        [self.signOutButton setTitle:@"Logout" forState:UIControlStateNormal];
        self.signOutButton.titleLabel.font = [UIFont systemFontOfSize:17];
        
        self.signOutButton.tintColor = [UIColor UNHCRBlue];
        
        // settings button
        self.settingsButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [self addSubview:self.settingsButton];
        
        self.settingsButton.frame = CGRectMake(CGRectGetWidth(self.frame) - smallButtonSize.width - xSmallButtonOffset,
                                               CGRectGetMidY(self.campsButton.frame),
                                               smallButtonSize.width,
                                               smallButtonSize.height);
        
        [self.settingsButton setTitle:@"Options" forState:UIControlStateNormal];
        self.settingsButton.titleLabel.font = [UIFont systemFontOfSize:17];
        
        self.settingsButton.tintColor = [UIColor UNHCRBlue];
        
        // NOTE: must be last
        self.loginState = HCRHomeLoginMenuStateNotSignedIn;
        
    }
    return self;
}

#pragma mark - Getters & Setters

- (void)setLoginState:(HCRHomeLoginMenuState)loginState {
    
    _loginState = loginState;
    
    CGPoint contentOffset;
    NSArray *buttonsToEnable;
    NSArray *buttonsToDisable;
    NSArray *viewsToHide;
    NSArray *viewsToShow;
    
    switch (loginState) {
        case HCRHomeLoginMenuStateNotSignedIn:
        {
            
            self.scrollEnabled = NO;
            
            buttonsToDisable = @[self.signOutButton,self.settingsButton];
            viewsToHide = @[self.loginButton];
            viewsToShow = @[self.signingInLabel,self.signingInSpinner];
            contentOffset = CGPointMake(0, 0);
            
            
        }
            break;
            
        case HCRHomeLoginMenuStateSignedIn:
        {
            
            self.scrollEnabled = YES;
            
            buttonsToEnable = @[self.signOutButton,self.settingsButton];
            viewsToHide = @[self.signingInLabel,self.signingInSpinner];
            viewsToShow = @[self.loginButton];
            contentOffset = CGPointMake(CGRectGetWidth(self.frame), 0);
        }
            break;
            
        default:
            break;
    }
    
    static const NSTimeInterval kAnimationTimeInteval = 0.33;
    [UIView animateWithDuration:kAnimationTimeInteval
                     animations:^{
                         
                         [self setContentOffset:contentOffset];
                         
                     } completion:^(BOOL finished) {
                         
                         [UIView animateWithDuration:kAnimationTimeInteval
                                          animations:^{
                                              
                                              for (UIButton *button in buttonsToEnable) {
                                                  button.enabled = YES;
                                              }
                                              
                                              for (UIButton *button in buttonsToDisable) {
                                                  button.enabled = NO;
                                              }
                                              
                                              for (UIView *view in viewsToHide) {
                                                  view.alpha = 0.0;
                                              }
                                              
                                              for (UIView *view in viewsToShow) {
                                                  view.alpha = 1.0;
                                              }
                                              
                                          }];
                         
                     }];
    
}

@end
