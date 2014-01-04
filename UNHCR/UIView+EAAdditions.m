//
//  UIView+EAAdditions.m
//  evilapples
//
//  Created by Danny Ricciotti on 5/2/13.
//  Copyright (c) 2013 Danny Ricciotti. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "UIView+EAAdditions.h"

@implementation UIView (EAAdditions)

- (void)setSpinning:(BOOL)isSpinning
{
    if ( isSpinning )
    {
        [self.layer removeAnimationForKey:@"Spin"]; // safety check. needed? i dont fucking know.
        
        CABasicAnimation *rotation;
        rotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        rotation.fromValue = [NSNumber numberWithFloat:0];
        rotation.toValue = [NSNumber numberWithFloat:(2*M_PI)];
        rotation.duration = 80.0; // Speed
        rotation.repeatCount = HUGE_VALF; // Repeat forever. Can be a finite number.
        [self.layer addAnimation:rotation forKey:@"Spin"];
    }
    else
    {
        [self.layer removeAnimationForKey:@"Spin"];
    }
}

-(NSString *)superRecursiveDescription
{
#if 0

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    SEL sel = NSSelectorFromString(@"recursiveDescription");
    NSString *subDescription = [self performSelector:sel];
#pragma clang diagnostic pop

    NSMutableString *superDescription = @"".mutableCopy;
    NSMutableArray *d = @[].mutableCopy;
    
    UIView *view = self.superview;
    
    while ( view )
    {
        NSString *str = [NSString stringWithFormat:@"%@\n",view.description];
        [d insertObject:str atIndex:0];
        view = view.superview;
    }
    
    [d enumerateObjectsUsingBlock:^(NSString* obj, NSUInteger idx, BOOL *stop) {
        [superDescription appendString:obj];
    }];
    
    [superDescription appendString:@"\n--------- SUPERVIEWS ABOVE HERE -------\n\n"];
    [superDescription appendString:subDescription];
    
    return superDescription;
#else
    // the call to performSelector: above will cause compiler warnings so we disable this method unless you plan on using it in your own debugging. Don't commit with this method as implemented above.
    return @" *** superRecursiveDescription should be used in your private debugging only *** ";
#endif
}

- (void)shake {
    NSInteger defaultShakeCount = 5;
    [self _shakeViewWithCount:defaultShakeCount withInsanity:NO withCompletion:nil];
}

- (void)shakeWithCompletion:(void (^)(BOOL finished))completionBlock {
    NSInteger defaultShakeCount = 5;
    [self _shakeViewWithCount:defaultShakeCount withInsanity:NO withCompletion:completionBlock];
}

- (void)shakeForOneSecond {
    NSUInteger shakesPerSecond = 20;
    [self _shakeViewWithCount:shakesPerSecond withInsanity:NO withCompletion:nil];
}

- (void)shakeForever {
    [self _shakeViewWithCount:HUGE_VAL withInsanity:NO withCompletion:nil];
}

- (void)goCrazy {
    NSInteger defaultShakeCount = 5;
    [self _shakeViewWithCount:defaultShakeCount withInsanity:YES withCompletion:nil];
}

- (void)_shakeViewWithCount:(NSInteger)shakeCount withInsanity:(BOOL)insanity withCompletion:(void (^)(BOOL finished))completionBlock {
    
    NSTimeInterval animationDuration = 0.075;
    CGFloat scale = 1.3;
    CGFloat rotationAngle = M_PI / 180 * 6;
    
    void (^translateView)(UIView *) = ^ (UIView *view){
        int maxTranslation = 4;
        
        int xSign = arc4random() % 2 ? 1 : -1;
        int xSlide = arc4random_uniform(maxTranslation) * xSign;
        
        int ySign = arc4random() % 2 ? 1 : -1;
        int ySlide = arc4random_uniform(maxTranslation) * ySign;
        
        CGAffineTransform translation = (insanity) ? CGAffineTransformTranslate(self.transform,xSlide,ySlide) : CGAffineTransformMakeTranslation(xSlide,ySlide);
        
        [view setTransform:translation];
        
    };
    
    __block NSInteger internalShakeCount = shakeCount;
    
    void (^shakeUntilCountZero)(BOOL);
    __block void (^repeatingShakes)(BOOL);
    __block void (^stopShaking)(void);
    
    shakeUntilCountZero = ^(BOOL finished) {
        
        if (finished && internalShakeCount > 0) {
            
            NSInteger sign = (shakeCount % 2 == 1) ? -1 : 1;
            [UIView animateWithDuration:animationDuration
                             animations:^{
                                 [self setTransform:(insanity) ? CGAffineTransformRotate(self.transform,sign * rotationAngle) : CGAffineTransformMakeRotation(sign * rotationAngle)];
                                 translateView(self);
                             } completion:^(BOOL finished) {
                                 internalShakeCount--;
                                 repeatingShakes(finished);
                             }];
            
        } else {
            stopShaking();
        }
    };
    
    repeatingShakes = [shakeUntilCountZero copy];
    
    stopShaking = ^{
        [UIView animateWithDuration:animationDuration animations:^{
            
            [self setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
            [self setTransform:CGAffineTransformMakeRotation(0)];
            [self setTransform:CGAffineTransformMakeTranslation(0, 0)];
            
        } completion:^(BOOL finished) {
            if (completionBlock) {
                completionBlock(finished);
            }
        }];
    };
    
    // start shaking animation
    [UIView animateWithDuration:animationDuration
                     animations:^{
                         
                         [self setTransform:(insanity) ? CGAffineTransformScale(self.transform,scale, scale) : CGAffineTransformMakeScale(scale, scale)];
                         [self setTransform:(insanity) ? CGAffineTransformRotate(self.transform,rotationAngle) : CGAffineTransformMakeRotation(rotationAngle)];
                         translateView(self);
                         
                     } completion:shakeUntilCountZero];
    
}

+ (UIImage *)imageWithView:(UIView *)view

{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return img;
}

- (void)setFaded:(BOOL)fadeOut
{
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = (fadeOut) ? 0.0 : 1.0;
    }];
}

- (void)addParallaxMotionGroupWithRelativeValue:(NSInteger)value
{
    if ( ! [UIDevice isIOS7] )
    {
        return;
    }
    
    UIMotionEffectGroup *group = [UIView parallaxMotionGroupWithRelativeValue:value];
    [self addMotionEffect:group];
}

+ (UIMotionEffectGroup *)parallaxMotionGroupWithRelativeValue:(NSInteger)value
{
    if ( ! [UIDevice isIOS7] )
    {
        return nil;
    }
    UIInterpolatingMotionEffect *verticalMotionEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    
    verticalMotionEffect.minimumRelativeValue = @(-value);
    verticalMotionEffect.maximumRelativeValue = @(value);
    UIInterpolatingMotionEffect *horizontalMotionEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    horizontalMotionEffect.minimumRelativeValue = @(-1 * value);
    horizontalMotionEffect.maximumRelativeValue = @(value);
    
    UIMotionEffectGroup *group = [UIMotionEffectGroup new];
    group.motionEffects = @[horizontalMotionEffect, verticalMotionEffect];
    
    return group;
}

- (void)addMotionEffectOSSafe:(UIMotionEffect *)effect
{
    // only call if device supports it
    if ([self respondsToSelector:@selector(addMotionEffect:)]) {
        [self addMotionEffect:effect];
    }
}

- (void)removeAllMotionEffects
{
    if ( [self respondsToSelector:@selector(removeMotionEffect:)])
    {
        // disable parallax on this gamepopup only
        [[self motionEffects] enumerateObjectsUsingBlock:^(UIMotionEffect *obj, NSUInteger idx, BOOL *stop) {
            [self removeMotionEffect:obj];
        }];
    }
}


@end
