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
        self.participantLabel.transform = CGAffineTransformMakeTranslation(-1 * CGRectGetWidth(self.participantLabel.bounds), 0); // looks good
        
    }
    return self;
}

#pragma mark - Getters & Setters

- (void)setParticipants:(NSArray *)participants {
    
    _participants = participants;
    
    [UIView animateWithDuration:kAnimationTiming animations:^{
        
        self.items = (participants.count > 1) ? @[self.previousParticipant,self.flexSpace,self.nextParticipant] : @[self.flexSpace,self.addParticipants];
        
    }];
    
}

- (void)setCurrentParticipant:(HCRSurveyAnswerSetParticipant *)currentParticipant {
    _currentParticipant = currentParticipant;
    
    NSMutableString *participantString = [NSString stringWithFormat:@"Participant %@",currentParticipant.participantID].mutableCopy;
    
    if (currentParticipant.age && currentParticipant.gender) {
        [participantString appendString:[NSString stringWithFormat:@" (%@/%@)",
                                         currentParticipant.age,
                                         (currentParticipant.gender.integerValue == 0) ? @"m" : @"f"]];
    }
    
    self.participantLabel.text = [participantString uppercaseString];
    
    [UIView animateWithDuration:kAnimationTiming animations:^{
        self.participantLabel.transform = CGAffineTransformIdentity;
    }];
    
}

@end
