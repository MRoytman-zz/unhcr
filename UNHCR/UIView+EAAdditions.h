//
//  UIView+EAAdditions.h
//  evilapples
//
//  Created by Danny Ricciotti on 5/2/13.
//  Copyright (c) 2013 Danny Ricciotti. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (EAAdditions)

- (void)setSpinning:(BOOL)isSpinning;

- (void)shake;
- (void)shakeWithCompletion:(void (^)(BOOL finished))completionBlock;
- (void)shakeForOneSecond;
- (void)shakeForever;

- (void)goCrazy;

- (NSString *)superRecursiveDescription;

+ (UIImage *)imageWithView:(UIView *)view;

- (void)setFaded:(BOOL)fadeOut;

- (void)addParallaxMotionGroupWithRelativeValue:(NSInteger)value;
+ (UIMotionEffectGroup *)parallaxMotionGroupWithRelativeValue:(NSInteger)value;

- (void)addMotionEffectOSSafe:(UIMotionEffect *)effect;

- (void)removeAllMotionEffects;

@end
