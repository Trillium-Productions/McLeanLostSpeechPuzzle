//
//  AlphaGetter.h
//  LostSpeechPuzzle
//
//  Created by William Rosenbloom on 3/29/16.
//  Copyright © 2016 William Rosenbloom - Trillium Productions. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlphaGetter : NSObject

+ (BOOL)isImage:(UIImage * _Nonnull)image TransparentAtPoint:(CGPoint)point;

@end
