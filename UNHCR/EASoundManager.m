//
//  EASoundManager.m
//  evilapples
//
//  Created by Danny on 1/27/13.
//  Copyright (c) 2013 Danny Ricciotti. All rights reserved.
//

#import "EASoundManager.h"
#import <AudioToolbox/AudioToolbox.h>

////////////////////////////////////////////////////////////////////////////////

NSString *const EASoundDisabledPrefKey = @"EASoundDisabledPrefKey";

NSString *const EASoundDictionaryFrameworkKey = @"EASoundDictionaryFrameworkKey";
NSString *const EASoundDictionaryAVFoundationPlayerKey = @"EASoundDictionaryAVFoundationPlayerKey";
NSString *const EASoundDictionaryAudioToolboxSoundID = @"EASoundDictionaryAudioToolboxSoundID";

///////////////////////////////////////////////////////////////

@interface EASoundManager ()
@property (nonatomic, strong) NSMutableDictionary *audioPlayers;
@end

///////////////////////////////////////////////////////////////

@implementation EASoundManager

#pragma mark -
#pragma mark Life Cycle

+ (id)sharedSoundManager
{
    // TODO: make threadsafe
    static EASoundManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[EASoundManager alloc] init];
    });
	return manager;
}

- (id)init
{
    self = [super init];
    if ( self != nil )
    {        
        // set sound to mix with background sound (i.e. AVAudioSessionCategoryAmbient)
        NSError *error = nil;
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient
                                               error:&error];
        if (error) {
            NSLog(@"error setting category for audio session: %@",error);
        }
        
        self.audioPlayers = [NSMutableDictionary new];
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"[DEALLOC] Sound Manager");
    for ( NSNumber *num in self.audioPlayers )
    {
        NSDictionary *soundDictionary = [self.audioPlayers objectForKey:num];
        EASoundFramework framework = (EASoundFramework)[soundDictionary objectForKey:EASoundDictionaryFrameworkKey];
        
        if (framework == EASoundFrameworkAudioToolbox) {
            SystemSoundID sid = [num integerValue];
            AudioServicesDisposeSystemSoundID(sid);
        }
        
    }
}

#pragma mark - Getters & Setters

- (void)setSoundEnabled:(BOOL)soundEnabled {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    // note: logic is reverse
    [defaults setBool:!soundEnabled
               forKey:EASoundDisabledPrefKey];

    [defaults synchronize];
}

- (BOOL)soundEnabled {
    return ([[NSUserDefaults standardUserDefaults] boolForKey:EASoundDisabledPrefKey] == NO);   // reverse logic
}

#pragma mark -
#pragma mark Public

// this class is important so we can run the prepareToPlay method, which reduces UI lag/lock when sounds play
- (void)registerSoundIDs:(NSArray *)soundIDs {
    
    // to add new sounds, add new soundIDs here, + add other data in the switch below
    NSMutableArray *newSoundIDs = [NSMutableArray new];
    
    for (NSNumber *soundID in soundIDs) {
        
        NSAssert([soundID isKindOfClass:[NSNumber class]], @"wrong class; soundIDs should be sent as NSNumbers");
        
        NSDictionary *soundDictionary = [self.audioPlayers objectForKey:soundID];
        
        if (!soundDictionary) {
            [newSoundIDs addObject:soundID]; // if new sound, add it to the newSoundIDs array
        } // else the sound dictionary already exists
        
    };
    
    // for all new sound IDs, add them to the main dictionary
    for (NSNumber *soundNumber in newSoundIDs) {
        
        // make dictionary for sound
        NSMutableDictionary *soundDictionary = [NSMutableDictionary new];
        
        NSString *filename;
        NSString *extension;
        EASoundFramework framework;
        
        EASoundID soundID = [soundNumber intValue];
        switch ( soundID )
        {
            case EASoundIDCoin:
                filename = @"coin";
                extension = @"aiff";
                framework = EASoundFrameworkAVFoundation;
                break;
            case EASoundIDCake:
                filename = @"cake-full";
                extension = @"aif";
                framework = EASoundFrameworkAVFoundation;
                break;
            case EASoundIDPowerUp:
                filename = @"laser-prep";
                extension = @"mp3";
                framework = EASoundFrameworkAVFoundation;
                break;
            case EASoundIDPowerDown:
                filename = @"laser-prep-reverse";
                extension = @"mp3";
                framework = EASoundFrameworkAVFoundation;
                break;
            case EASoundIDOdeToJoy:
                filename = @"ode-long";
                extension = @"aiff";
                framework = EASoundFrameworkAVFoundation;
                break;
            case EASoundIDSadTrombone:
                filename = @"sad-trombone";
                extension = @"aiff";
                framework = EASoundFrameworkAVFoundation;
                break;
            case EASoundIDFinalFantasy:
                filename = @"victory";
                extension = @"aiff";
                framework = EASoundFrameworkAVFoundation;
                break;
            case EASoundIDClick0:
                filename = @"click0";
                extension = @"mp3";
                framework = EASoundFrameworkAVFoundation;
                break;
            case EASoundIDClick1:
                filename = @"click1";
                extension = @"mp3";
                framework = EASoundFrameworkAVFoundation;
                break;
            case EASoundIDCredits:
                filename = @"credits-out";
                extension = @"mp3";
                framework = EASoundFrameworkAVFoundation;
                break;
            case EASoundIDChatIncoming:
                filename = @"chat_incoming";
                extension = @"mp3";
                framework = EASoundFrameworkAVFoundation;
                break;
            case EASoundIDNotice:
                filename = @"notice";
                extension = @"mp3";
                framework = EASoundFrameworkAVFoundation;
                break;
            case EASoundIDDrumroll:
                filename = @"drumroll";
                extension = @"mp3";
                framework = EASoundFrameworkAVFoundation;
                break;
            case EASoundIDElevator:
                filename = @"elevator";
                extension = @"mp3";
                framework = EASoundFrameworkAVFoundation;
                break;
        }
        
        [soundDictionary setObject:[NSNumber numberWithInt:framework]
                            forKey:EASoundDictionaryFrameworkKey];
        
        NSParameterAssert(filename);
        NSString *soundPath = [[NSBundle mainBundle] pathForResource:filename ofType:extension];
        NSParameterAssert(soundPath);
        if ( !soundPath ) {
            // some crashes due to missing sound path (https://rink.hockeyapp.net/manage/apps/25663/app_versions/6/crash_reasons/6421546)
            NSLog(@"Missing sound path: %@", filename);
            return;
        }
        
        switch (framework) {
            case EASoundFrameworkAVFoundation:
            {
                NSError *error = nil;
                AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:soundPath]
                                                                               error:&error];
                NSParameterAssert(player);
                
                [soundDictionary setObject:player
                                    forKey:EASoundDictionaryAVFoundationPlayerKey];
                
                if ( error )
                {
                    NSLog(@"Error preparing audio %@: %@",
                          soundPath,
                          [error description]);
                }
                else
                {
                    player.volume = 1.0;
                    player.currentTime = 0;
                    [player prepareToPlay];
                }
                break;
            }
                
            case EASoundFrameworkAudioToolbox:
            {
                SystemSoundID sound;
                // Note: C/C++ exception is thrown on first call to this. Avoid by changing your exception breakpoint from "All" to "Objective-C" exceptions.
                // @see http://stackoverflow.com/questions/9683547/avaudioplayer-throws-breakpoint-in-debug-mode
                AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:soundPath],
                                                 &sound);
                
                // add to dictionary/cache for later use
                [soundDictionary setObject:[NSNumber numberWithInteger:(NSInteger)sound]
                                    forKey:EASoundDictionaryAudioToolboxSoundID];
                break;
            }
        }
        
        // set dictionary in master dictionary list
        [self.audioPlayers setObject:soundDictionary
                              forKey:soundNumber];
    }
}

- (void)playSoundLoop:(EASoundID)soundID
{
    // make sure sound is enabled
    BOOL soundDisabled = [[NSUserDefaults standardUserDefaults] boolForKey:EASoundDisabledPrefKey];
    if (soundDisabled == NO) {
        
        // if we already know the sound, play it
        NSNumber *soundNumber = [NSNumber numberWithInteger:soundID];
        NSDictionary *soundDictionary = [self.audioPlayers objectForKey:soundNumber];
        if (soundDictionary) { // known sound; play it!
            
            EASoundFramework framework = [[soundDictionary objectForKey:EASoundDictionaryFrameworkKey] intValue];
            
            switch (framework) {
                case EASoundFrameworkAudioToolbox:
                {
                    SystemSoundID sid = soundID;
                    AudioServicesPlaySystemSound(sid);
                    break;
                }
                    
                case EASoundFrameworkAVFoundation:
                {
                    AVAudioPlayer *player = [soundDictionary objectForKey:EASoundDictionaryAVFoundationPlayerKey];
                    player.numberOfLoops = -1;  // forever. must be stopped by calling stop.
                    [player play];
                }
                    
            }
        } else { // else add to dictionary and play it
            NSLog(@"__unknown sound: %d - MAKE SURE YOU REGISTER YOUR SOUNDS",soundID);
            [self registerSoundIDs:@[[NSNumber numberWithInt:soundID]]];
            [self playSoundLoop:soundID];
        }
    }
}

- (void)playSoundOnce:(EASoundID)soundID
{
    // make sure sound is enabled
    BOOL soundDisabled = [[NSUserDefaults standardUserDefaults] boolForKey:EASoundDisabledPrefKey];
    if (soundDisabled == NO) {
        
        // if we already know the sound, play it
        NSNumber *soundNumber = [NSNumber numberWithInteger:soundID];
        NSDictionary *soundDictionary = [self.audioPlayers objectForKey:soundNumber];
        if (soundDictionary) { // known sound; play it!
            
            EASoundFramework framework = [[soundDictionary objectForKey:EASoundDictionaryFrameworkKey] intValue];
            
            switch (framework) {
                case EASoundFrameworkAudioToolbox:
                {
                    SystemSoundID sid = soundID;
                    AudioServicesPlaySystemSound(sid);
                    break;
                }
                    
                case EASoundFrameworkAVFoundation:
                {
                    AVAudioPlayer *player = [soundDictionary objectForKey:EASoundDictionaryAVFoundationPlayerKey];
                    [player play];
                }
                    
            }
        } else { // else add to dictionary and play it
            NSLog(@"__unknown sound: %d - MAKE SURE YOU REGISTER YOUR SOUNDS",soundID);
            [self registerSoundIDs:@[[NSNumber numberWithInt:soundID]]];
            [self playSoundOnce:soundID];
        }
        
    }
}

- (void)stopSounds {
    
    // todo consolidate code between stop methods
    
    [self.audioPlayers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
        NSDictionary *soundDictionary = obj;
        NSParameterAssert([soundDictionary isKindOfClass:[NSDictionary class]]);
        
        EASoundFramework framework = [[soundDictionary objectForKey:EASoundDictionaryFrameworkKey
                                                            ofClass:@"NSNumber"] intValue];
        
        switch (framework) {
            case EASoundFrameworkAudioToolbox:
                NSLog(@"I don't believe sounds played AudioToolbox can be stopped. Citation needed.");
                break;
                
            case EASoundFrameworkAVFoundation:
            {
                AVAudioPlayer *player = [soundDictionary objectForKey:EASoundDictionaryAVFoundationPlayerKey];
                [player stop];
                [player setCurrentTime:0.0];
                break;
            }
                
        }
        
    }];
}


- (void)stopSound:(EASoundID)soundID
{
    // todo consolidate code between stop methods
    
    [self.audioPlayers enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, id obj, BOOL *stop) {
        
        NSCAssert([key isKindOfClass:[NSNumber class]], @"Invalid class.");
        if ([key integerValue] == soundID )
        {
            *stop = YES;
            
            NSDictionary *soundDictionary = obj;
            NSParameterAssert([soundDictionary isKindOfClass:[NSDictionary class]]);
            
            EASoundFramework framework = [[soundDictionary objectForKey:EASoundDictionaryFrameworkKey
                                                                ofClass:@"NSNumber"] intValue];
            
            switch (framework) {
                case EASoundFrameworkAudioToolbox:
                    NSLog(@"I don't believe sounds played AudioToolbox can be stopped. Citation needed.");
                    break;
                    
                case EASoundFrameworkAVFoundation:
                {
                    AVAudioPlayer *player = [soundDictionary objectForKey:EASoundDictionaryAVFoundationPlayerKey];
                    [player stop];
                    [player setCurrentTime:0.0];
                    break;
                }
                    
            }
        }
        
    }];
}

@end
