//
//  TweetDetailViewController.h
//  codepath-twitter
//
//  Created by Miles Spielberg on 2/20/15.
//  Copyright (c) 2015 OrionNet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tweet.h"

@class TweetDetailViewController;

@protocol TweetDetailViewControllerDelegate

- (void)tweetId:(NSNumber *)tweetId didChangeStatusFavorite:(BOOL)isFavorite retweeted:(BOOL)isRetweeted;

@end

@interface TweetDetailViewController : UIViewController

@property (nonatomic, strong) Tweet *tweet;

@end
