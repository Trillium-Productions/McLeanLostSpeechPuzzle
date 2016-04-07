//
//  movingthreading.m
//  LostSpeechPuzzle
//
//  Created by William Rosenbloom on 4/6/16.
//  Copyright © 2016 William Rosenbloom - Trillium Productions. All rights reserved.
//


#import "movingthreading.h"

@implementation MovingDelegateManager {
    BOOL transformActive;
    BOOL rotationActive;
}

- (id)init {
    transformActive = rotationActive = false;
    return [super init];
}

- (void)registerMovementStartForTransform:(MovingDelegatedTransform)kind {
    switch (kind) {
        case MovingDelegatedTransform_Rotation:
            rotationActive = true;
            break;
        case MovingDelegatedTransform_Translation:
            transformActive = true;
            break;
    }
}

- (BOOL)getPermissionForTransformCallback:(MovingDelegatedTransform)kind {
    switch (kind) {
        case MovingDelegatedTransform_Translation:
            transformActive = false;
            break;
        case MovingDelegatedTransform_Rotation:
            rotationActive = false;
            break;
    }
    return !transformActive && !rotationActive;
}

@end