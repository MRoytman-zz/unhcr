//
//  HCRParticipantToolbar.m
//  UNHCR
//
//  Created by Sean Conrad on 1/9/14.
//  Copyright (c) 2014 Sean Conrad. All rights reserved.
//

#import "HCRParticipantToolbar.h"

////////////////////////////////////////////////////////////////////////////////

static const NSTimeInterval kAnimationTiming = 0.3;

////////////////////////////////////////////////////////////////////////////////

@interface HCRParticipantToolbar ()

@property UILabel *participantLabel;
@property UIBarButtonItem *flexSpace;
@property UIBarButtonItem *staticSpace;

@property (nonatomic, readwrite) UIColor *defaultToolbarColor;

@property (nonatomic, readwrite) UIBarButtonItem *previousParticipant;
@property (nonatomic, readwrite) UIBarButtonItem *nextParticipant;
@property (nonatomic, readwrite) UIBarButtonItem *addParticipant;
@property (nonatomic, readwrite) UIBarButtonItem *removeParticipant;

@property (nonatomic, readwrite) UIButton *centerButton;

@end

////////////////////////////////////////////////////////////////////////////////

@implementation HCRParticipantToolbar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        // Initialization code
        self.defaultToolbarColor = [UIColor flatYellowColor];
        
        self.previousParticipant = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind
                                                                                 target:nil
                                                                                 action:NULL];
        
        self.nextParticipant = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward
                                                                             target:nil
                                                                             action:NULL];
        
        self.addParticipant = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                             target:nil
                                                                             action:NULL];
        
        self.removeParticipant = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash
                                                                               target:nil
                                                                               action:NULL];
        
        self.flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                       target:nil
                                                                       action:NULL];
        
        self.staticSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                         target:nil
                                                                         action:NULL];
        
        self.participantLabel = [[UILabel alloc] initWithFrame:self.bounds];
        [self addSubview:self.participantLabel];
        
        self.participantLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        self.participantLabel.textAlignment = NSTextAlignmentCenter;
        self.participantLabel.alpha = 0.0;
        
        self.centerButton = [[UIButton alloc] initWithFrame:CGRectZero];
        [self addSubview:self.centerButton];
        
    }
    return self;
}

- (void)layoutSubviews {
    
    NSMutableArray *buttonArray = @[].mutableCopy;
    
    BOOL showTrashIcon = (self.currentParticipant.participantID.integerValue != 0);
    
    if ([self.participants containsObject:self.currentParticipant]) {
        
        if ([self.participants indexOfObject:self.currentParticipant] != 0) {
            [buttonArray addObject:self.previousParticipant];
        }
        
        [buttonArray addObject:self.flexSpace];
        
        if (showTrashIcon) {
            [buttonArray addObject:self.removeParticipant];
            [buttonArray addObject:self.staticSpace];
        }
        
        UIBarButtonItem *lastItem = (self.currentParticipant == [self.participants lastObject]) ? self.addParticipant : self.nextParticipant;
        [buttonArray addObject:lastItem];
        
        // ensures static padding from the wall
        // http://stackoverflow.com/questions/5066847/get-the-width-of-a-uibarbuttonitem
        UIView *itemView = [lastItem valueForKey:@"view"];
        CGFloat width = CGRectGetWidth(itemView.bounds);
        self.staticSpace.width = 35 - width;
        
    } else {
        
        [buttonArray addObject:self.flexSpace];
        [buttonArray addObject:self.addParticipant];
    }
    
    [self setItems:buttonArray animated:YES];
    
    // set label
    self.participantLabel.text = [[self.currentParticipant localizedParticipantName] uppercaseString];
    
    CGFloat targetTranslation = (showTrashIcon) ? -20 : 0;
    [UIView animateWithDuration:kAnimationTiming animations:^{
        
        self.participantLabel.alpha = 1.0;
        
        // TODO: get dynamically and determine whether it's even needed dynamically
        self.participantLabel.transform = CGAffineTransformMakeTranslation(targetTranslation, 0);
        
    } completion:^(BOOL finished) {
        
        // bring button to front
        [self bringSubviewToFront:self.centerButton];
        
        CGSize targetSize = [self.participantLabel.text sizeforMultiLineStringWithBoundingSize:self.bounds.size
                                                                                      withFont:self.participantLabel.font
                                                                                       rounded:YES];
        self.centerButton.frame = CGRectMake(0.5 * (CGRectGetWidth(self.bounds) - targetSize.width) + targetTranslation,
                                             0,
                                             targetSize.width,
                                             CGRectGetHeight(self.bounds));
    }];
    
}

#pragma mark - Getters & Setters

- (void)setParticipants:(NSArray *)participants {
    
    _participants = participants;
    
    [self setNeedsLayout];
    
}

- (void)setCurrentParticipant:(HCRSurveyAnswerSetParticipant *)currentParticipant {
    _currentParticipant = currentParticipant;
    
    [self setNeedsLayout];
    
}

//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
//    return NO;
//}
//
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
//    if (gestureRecognizer == self.tapRecognizer) {
//        return YES;
//    } else {
//        return NO;
//    }
//}
//
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
//    
//    if (gestureRecognizer.view == self) {
//        return NO;
//    }
//    
//    return YES;
//    
//}

@end
