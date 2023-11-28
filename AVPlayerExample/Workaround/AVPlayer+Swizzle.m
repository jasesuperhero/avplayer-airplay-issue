//
//  AVPlayer+Swizzle.m
//  Playback
//
//  Created by Daniel Kalintsev on 29.11.23.
//

@import AVFoundation;

#import "Class+SwizzleSelector.h"
#import "AVPlayerExample-Swift.h"

NS_ASSUME_NONNULL_BEGIN

@implementation AVPlayer (Swizzle)

static id (*init)(id, SEL) = NULL;

static id swizzle_init(AVPlayer *self, SEL _cmd)
{
    // Firstly, we're calling the original saved method and after we can do out stuff
    if ((self = init(self, _cmd))) {
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc postNotificationName:AVPlayer.didInitPlayerNotificationName
                          object:nil];
    }

    return self;
}

+ (void)load {
    init = (__typeof(init))sc_class_swizzleSelector(self,
                                                    @selector(init),
                                                    (IMP)swizzle_init);
    NSLog(@"AirPlay Swizzle: did swizzle init IMP of AVPlayer");
}

@end

NS_ASSUME_NONNULL_END
