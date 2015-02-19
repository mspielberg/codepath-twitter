//
//  UIImageView+AnimationUtils.h
//  RottenTomatoes
//
//  Created by Miles Spielberg on 2/4/15.
//  Copyright (c) 2015 OrionNet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (AnimationUtils)

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder duration:(NSTimeInterval)duration;

@end
