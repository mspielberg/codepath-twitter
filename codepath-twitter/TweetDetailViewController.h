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

- (void)tweetDetailViewController:(TweetDetailViewController *)tweetDetailViewController tweet:(Tweet *)tweet shouldBecomeFavorite:(BOOL)favorite;
- (void)tweetDetailViewController:(TweetDetailViewController *)tweetDetailViewController shouldRetweetTweet:(Tweet *)tweet;
- (void)tweetDetailViewControllerShouldComposeTweet:(TweetDetailViewController *)tweetDetailViewController;
- (void)tweetDetailViewControllerShouldComposeReply:(TweetDetailViewController *)tweetDetailViewController toTweet:(Tweet *)tweet;

@end

@interface TweetDetailViewController : UIViewController

@property (nonatomic, weak) id<TweetDetailViewControllerDelegate> delegate;
@property (nonatomic, strong) Tweet *tweet;

@end
