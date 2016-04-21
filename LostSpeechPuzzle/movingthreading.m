//
//  movingthreading.m
//  LostSpeechPuzzle
//
//  Created by William Rosenbloom on 4/6/16.
//  Copyright © 2016 William Rosenbloom - Trillium Productions. All rights reserved.
//


#import "movingthreading.h"

@implementation MovingDelegateManager {
    BOOL translationActive;
    BOOL rotationActive;
}

- (id)init {
    translationActive = rotationActive = false;
    return [super init];
}

- (BOOL) isMovingActive {
    return translationActive || rotationActive;
}

- (void)registerMovementStartForTransform:(MovingDelegatedTransform)kind {
    switch (kind) {
        case MovingDelegatedTransform_Rotation:
            rotationActive = true;
            break;
        case MovingDelegatedTransform_Translation:
            translationActive = true;
            break;
    }
}

- (BOOL)getPermissionForTransformCallback:(MovingDelegatedTransform)kind {
    switch (kind) {
        case MovingDelegatedTransform_Translation:
            translationActive = false;
            break;
        case MovingDelegatedTransform_Rotation:
            rotationActive = false;
            break;
    }
    return !translationActive && !rotationActive;
}

@end