//
//  EASoundManager.h
//  evilapples
//
//  Created by Danny on 1/27/13.
//  Copyright (c) 2013 Danny Ricciotti. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

///////////////////////////////////////////////////////////////

typedef enum {
    EASoundFrameworkAVFoundation    = 1,
    EASoundFrameworkAudioToolbox,
} EASoundFramework;

typedef enum
{
    EASoundIDPowerUp        = 1,
    EASoundIDPowerDown,
    EASoundIDOdeToJoy,
    EASoundIDSadTrombone,
    EASoundIDCoin,
    EASoundIDCake,
    EASoundIDFinalFantasy,
    EASoundIDClick0,
    EASoundIDClick1,
    EASoundIDCredits,
    EASoundIDChatIncoming,
    EASoundIDNotice,
    EASoundIDDrumroll,
    EASoundIDElevator
} EASoundID;

///////////////////////////////////////////////////////////////

@interface EASoundManager : NSObject

@property (nonatomic, readwrite) BOOL soundEnabled;

+ (id)sharedSoundManager;

- (void)playSoundOnce:(EASoundID)soundID;

- (void)registerSoundIDs:(NSArray *)soundIDs;

- (void)stopSounds; // currently stops ALL sounds

- (void)playSoundLoop:(EASoundID)soundID;
- (void)stopSound:(EASoundID)soundID;

@end
