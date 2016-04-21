//
//  movingthreading.h
//  LostSpeechPuzzle
//
//  Created by William Rosenbloom on 4/6/16.
//  Copyright © 2016 William Rosenbloom - Trillium Productions. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(char, MovingDelegatedTransform) {
    MovingDelegatedTransform_Translation = 0,
    MovingDelegatedTransform_Rotation = 1
};

@interface MovingDelegateManager : NSObject

@property (readonly) BOOL isMovingActive;

- (id)init;

- (void)registerMovementStartForTransform:(MovingDelegatedTransform)kind;
- (BOOL)getPermissionForTransformCallback:(MovingDelegatedTransform)kind;

@end
