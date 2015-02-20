//
//  TwitterClient.h
//  codepath-twitter
//
//  Created by Miles Spielberg on 2/17/15.
//  Copyright (c) 2015 OrionNet. All rights reserved.
//

#import "BDBOAuth1RequestOperationManager.h"
#import "User.h"

typedef void(^ORNLoginCompletion)(User *user, NSError *error);
typedef ORNLoginCompletion(^ORNAuthURLCompletion)(NSURL *authURL, NSError *error);

@interface TwitterClient : BDBOAuth1RequestOperationManager

+ (TwitterClient *)sharedInstance;

- (void)beginLoginWithCompletion:(ORNAuthURLCompletion)completion;
- (void)loginWithCompletion:(void(^)(User *user, NSError *error))completion;
- (void)handleOpenUrl:(NSURL *)url;
- (void)homeTimelineFromStartId:(NSNumber *)startId completion:(void(^)(NSArray *tweets, NSError *error))completion;
@end
