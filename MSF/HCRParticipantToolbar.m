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

@property (nonatomic, readwrite) UIColor *defaultToolbarColor;

@property (nonatomic, readwrite) UIBarButtonItem *previousParticipant;
@property (nonatomic, readwrite) UIBarButtonItem *nextParticipant;
@property (nonatomic, readwrite) UIBarButtonItem *addParticipants;

@end

////////////////////////////////////////////////////////////////////////////////

@implementation HCRParticipantToolbar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        // Initialization code
        self.defaultToolbarColor = self.backgroundColor;
        
        self.previousParticipant = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind
                                                                                 target:nil
                                                                                 action:NULL];
        
        self.nextParticipant = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward
                                                                             target:nil
                                                                             action:NULL];
        
        self.addParticipants = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                             target:nil
                                                                             action:NULL];
        
        self.flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                       target:nil
                                                                       action:NULL];
        
        self.participantLabel = [[UILabel alloc] initWithFrame:self.bounds];
        [self addSubview:self.participantLabel];
        
        self.participantLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        self.participantLabel.textAlignment = NSTextAlignmentCenter;
        self.participantLabel.alpha = 0.0;
        
    }
    return self;
}

#pragma mark - Getters & Setters

- (void)setParticipants:(NSArray *)participants {
    
    _participants = participants;
    
    [self _updateToolbar];
    
}

- (void)setCurrentParticipant:(HCRSurveyAnswerSetParticipant *)currentParticipant {
    _currentParticipant = currentParticipant;
    
    [self _updateToolbar];
    
}

#pragma mark - Private Methods

- (void)_updateToolbar {
    
    // set buttons
    NSMutableArray *buttonArray = @[].mutableCopy;
    
    if ([self.participants containsObject:self.currentParticipant]) {
        
        if ([self.participants indexOfObject:self.currentParticipant] != 0) {
            [buttonArray addObject:self.previousParticipant];
        }
        
        [buttonArray addObject:self.flexSpace];
        
        if (self.currentParticipant == [self.participants lastObject]) {
            [buttonArray addObject:self.addParticipants];
        } else {
            [buttonArray addObject:self.nextParticipant];
        }
        
    } else {
        
        [buttonArray addObject:self.flexSpace];
        [buttonArray addObject:self.addParticipants];
    }
    
    // set label
    NSMutableString *participantString = (self.currentParticipant.participantID.integerValue == 0) ? @"Head of Household".mutableCopy : [NSString stringWithFormat:@"Participant %@",self.currentParticipant.participantID].mutableCopy;
    
    if (self.currentParticipant.age && self.currentParticipant.gender) {
        [participantString appendString:[NSString stringWithFormat:@" (%@/%@)",
                                         self.currentParticipant.age,
                                         (self.currentParticipant.gender.integerValue == 0) ? @"m" : @"f"]];
    }
    
    self.participantLabel.text = [participantString uppercaseString];
    
    [self setItems:buttonArray animated:YES];
    
    [UIView animateWithDuration:kAnimationTiming animations:^{
        
        self.participantLabel.alpha = 1.0;
        
    }];

    
}

@end
