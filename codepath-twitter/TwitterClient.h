//
//  TwitterClient.h
//  codepath-twitter
//
//  Created by Miles Spielberg on 2/17/15.
//  Copyright (c) 2015 OrionNet. All rights reserved.
//

#import "BDBOAuth1RequestOperationManager.h"
#import "Tweet.h"
#import "User.h"

typedef void(^ORNLoginCompletion)(User *user, NSError *error);
typedef ORNLoginCompletion(^ORNAuthURLCompletion)(NSURL *authURL, NSError *error);

@interface TwitterClient : BDBOAuth1RequestOperationManager

+ (TwitterClient *)sharedInstance;

- (void)beginLoginWithCompletion:(ORNAuthURLCompletion)completion;
- (void)handleOpenUrl:(NSURL *)url;
- (void)homeTimelineFromStartId:(NSNumber *)startId completion:(void(^)(NSArray *tweets, NSError *error))completion;
- (void)mentionsTimelineFromStartId:(NSNumber *)startId completion:(void(^)(NSArray *tweets, NSError *error))completion;
- (void)updateStatus:(NSString *)status asReplyToTweetId:(NSNumber *)tweetId withCompletion:(void (^)(Tweet *tweet, NSError *error))completion;
- (void)setAsFavorite:(BOOL)isFavorite withId:(NSNumber *)tweetId;
- (void)retweet:(NSNumber *)tweetId;
- (void)unretweet:(NSNumber *)tweetId;

@end
