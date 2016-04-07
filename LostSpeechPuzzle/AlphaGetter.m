//
//  AlphaGetter.m
//  LostSpeechPuzzle
//
//  Created by William Rosenbloom on 3/29/16.
//  Copyright © 2016 William Rosenbloom - Trillium Productions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AlphaGetter.h"

@implementation AlphaGetter

+ (BOOL)isImage:(UIImage *)image TransparentAtPoint:(CGPoint)point {
    unsigned char pixel[1] = {0};
    CGContextRef context = CGBitmapContextCreate(pixel,
                                                 1, 1, 8, 1, NULL,
                                                 kCGImageAlphaOnly);
    UIGraphicsPushContext(context);
    [image drawAtPoint:CGPointMake(-point.x, -point.y)];
    UIGraphicsPopContext();
    CGContextRelease(context);
    CGFloat alpha = pixel[0]/255.0f;
    return alpha < 0.01f;
}

@end