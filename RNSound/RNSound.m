//
//  RNSound.m
//  RNSound
//
//  Created by Claudia Cortes on 19/9/22.
//  Copyright © 2022 zmxv. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "React/RCTBridgeModule.h"

@interface RCT_EXTERN_MODULE(RNSound,NSObject)
RCT_EXTERN_METHOD(prepare : (NSString *)fileName)
RCT_EXTERN_METHOD(reset : (NSString *)fileName)
RCT_EXTERN_METHOD(play)
RCT_EXTERN_METHOD(pause)
RCT_EXTERN_METHOD(stop)
RCT_EXTERN_METHOD(setVolume : (nonnull NSNumber *)value)
RCT_EXTERN_METHOD(setPan : (nonnull NSNumber *)value)
RCT_EXTERN_METHOD(setPitch : (nonnull NSNumber *)value)
RCT_EXTERN_METHOD(setSpeed : (nonnull NSNumber *)value)
@end
