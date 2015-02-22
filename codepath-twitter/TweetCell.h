//
//  TweetCell.h
//  codepath-twitter
//
//  Created by Miles Spielberg on 2/18/15.
//  Copyright (c) 2015 OrionNet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tweet.h"

@class TweetCell;

@protocol TweetCellDelegate

- (void)tweetCell:(TweetCell *)tweetCell shouldReplyToTweet:(Tweet *)tweet;
- (void)tweetCell:(TweetCell *)tweetCell shouldSetFavorite:(BOOL)favorite ofTweet:(Tweet *)tweet;
- (void)tweetCell:(TweetCell *)tweetCell shouldRetweetTweet:(Tweet *)tweet;

@end

@interface TweetCell : UITableViewCell

@property (nonatomic, weak) id<TweetCellDelegate> delegate;
@property (nonatomic, strong) Tweet *tweet;

@end
