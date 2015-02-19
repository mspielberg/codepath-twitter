//
//  UIImageView+AnimationUtils.m
//  RottenTomatoes
//
//  Created by Miles Spielberg on 2/4/15.
//  Copyright (c) 2015 OrionNet. All rights reserved.
//

#import "UIImageView+AnimationUtils.h"
#import "UIImageView+AFNetworking.h"

@implementation UIImageView (AnimationUtils)

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder duration:(NSTimeInterval)duration {
    UIImageView __weak *weakSelf = self;
    
    if (!placeholder) {
        self.image = nil;
    }
    
    [self setImageWithURLRequest:[NSURLRequest requestWithURL:url] placeholderImage:placeholder success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        if (request) {
            // image was not cached, fade it into place
            [UIView transitionWithView:weakSelf
                              duration:duration
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                                weakSelf.image = image;
                            }
                            completion:NULL];
        } else {
            // image was cached, set it in place immediately
            weakSelf.image = image;
        }
    }
    failure:NULL];
}

@end
