//
//  movingthreading.h
//  LostSpeechPuzzle
//
//  Created by William Rosenbloom on 4/6/16.
//  Copyright © 2016 William Rosenbloom - Trillium Productions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <pthread.h>

typedef NS_ENUM(char, MovingDelegatedTransform) {
    MovingDelegatedTransform_Translation = 0,
    MovingDelegatedTransform_Rotation = 1
};

@interface MovingDelegateManager : NSObject

- (id)init;

- (void)registerMovementStartForTransform:(MovingDelegatedTransform)kind;
- (BOOL)getPermissionForTransformCallback:(MovingDelegatedTransform)kind;

@end
