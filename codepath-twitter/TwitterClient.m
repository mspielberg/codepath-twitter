//
//  TwitterClient.m
//  codepath-twitter
//
//  Created by Miles Spielberg on 2/17/15.
//  Copyright (c) 2015 OrionNet. All rights reserved.
//

#import "TwitterClient.h"
#import "Tweet.h"

NSString *const kTwitterConsumerKey = @"FCn6NR77L2wmqnCeDkFKPFagF";
NSString *const kTwitterConsumerSecret = @"4OZZ4DoS8TUm2oS8DzgALFqmtFG1HDjSFEi8VBbry5mDiPrTGD";
NSString *const kTwitterBaseUrl = @"https://api.twitter.com";

@interface TwitterClient ()

@property (nonatomic, strong) void (^loginCompletion)(User *user, NSError *error);

@end

@implementation TwitterClient

+ (TwitterClient *)sharedInstance {
    static TwitterClient *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[TwitterClient alloc] initWithBaseURL:[NSURL URLWithString:kTwitterBaseUrl] consumerKey:kTwitterConsumerKey consumerSecret:kTwitterConsumerSecret];
    });
    
    return instance;
}

- (void)beginLoginWithCompletion:(ORNAuthURLCompletion)completion {
    [self fetchRequestTokenWithPath:@"oauth/request_token" method:@"GET" callbackURL:[NSURL URLWithString:@"cptwitterdemo://oauth"] scope:nil success:^(BDBOAuth1Credential *requestToken) {
        NSLog(@"got request token");
        NSURL *authURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.twitter.com/oauth/authorize?oauth_token=%@", requestToken.token]];
        ORNLoginCompletion loginCompletion = completion(authURL, nil);
        self.loginCompletion = loginCompletion;
    } failure:^(NSError *error) {
        NSLog(@"could not get request token");
        completion(nil, error);
    }];
}

- (void)loginWithCompletion:(void(^)(User *user, NSError *error))completion {
    self.loginCompletion = completion;
    
    [self.requestSerializer removeAccessToken];
    
    [self fetchRequestTokenWithPath:@"oauth/request_token" method:@"GET" callbackURL:[NSURL URLWithString:@"cptwitterdemo://oauth"] scope:nil success:^(BDBOAuth1Credential *requestToken) {
        NSLog(@"got request token");
        NSURL *authURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.twitter.com/oauth/authorize?oauth_token=%@", requestToken.token]];
        [[UIApplication sharedApplication] openURL:authURL];
    } failure:^(NSError *error) {
        NSLog(@"could not get request token");
        self.loginCompletion(nil, error);
    }];
}

- (void)handleOpenUrl:(NSURL *)url {
    NSURLComponents *components = [NSURLComponents componentsWithURL:url resolvingAgainstBaseURL:NO];
    if ([components.queryItems filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSURLQueryItem *queryItem, NSDictionary *bindings) {
        return [queryItem.name isEqualToString:BDBOAuth1OAuthTokenParameter];
    }]].count > 0) {
        [self fetchAccessTokenWithPath:@"oauth/access_token" method:@"POST" requestToken:[BDBOAuth1Credential credentialWithQueryString:url.query] success:^(BDBOAuth1Credential *accessToken) {
            NSLog(@"Upgraded request token to access token");
            [self.requestSerializer saveAccessToken:accessToken];
            
            [self GET:@"1.1/account/verify_credentials.json" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSLog(@"current user: %@", responseObject);
                User *user = [[User alloc] initWithDictionary:responseObject];
                NSLog(@"current user: %@", user);
                [User setCurrentUser:user];
                self.loginCompletion(user, nil);
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"could not verify credentials");
                self.loginCompletion(nil, error);
            }];
        } failure:^(NSError *error) {
            NSLog(@"Failed to acquire access token");
            self.loginCompletion(nil, error);
        }];
    } else {
        NSLog(@"Could not find token parameter");
        self.loginCompletion(nil, [NSError
                                   errorWithDomain:BDBOAuth1ErrorDomain
                                   code:NSURLErrorCancelled userInfo:@{
                                                                       NSLocalizedFailureReasonErrorKey: @"User cancelled OAuth login.",
                                                                       NSURLErrorKey: url
                                                                       }]);
    }
}

- (void)timeline:(NSString *)timeline fromStartId:(NSNumber *)startId completion:(void(^)(NSArray *tweets, NSError *error))completion {
    NSDictionary *parameters;
    if (startId) {
        parameters = [NSDictionary dictionaryWithObject:@([startId integerValue] - 1) forKey:@"max_id"];
    }
    NSString *endpoint = [NSString stringWithFormat:@"1.1/statuses/%@_timeline.json", timeline];
    NSLog(@"Sending request to %@ with parameters: %@", endpoint, parameters);
    [self GET:endpoint parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSArray *allTweets = [Tweet tweetsWithArray:responseObject];
        completion(allTweets, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"failed to fetch timeline");
        NSLog(@"error = %@", error);
        completion(nil, error);
    }];
}

- (void)homeTimelineFromStartId:(NSNumber *)startId completion:(void(^)(NSArray *tweets, NSError *error))completion {
    [self timeline:@"home" fromStartId:startId completion:completion];
}

- (void)mentionsTimelineFromStartId:(NSNumber *)startId completion:(void(^)(NSArray *tweets, NSError *error))completion {
    [self timeline:@"mentions" fromStartId:startId completion:completion];
}

- (void)updateStatus:(NSString *)status asReplyToTweetId:(NSNumber *)tweetId withCompletion:(void (^)(Tweet *tweet, NSError *error))completion {
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObject:status forKey:@"status"];
    if (tweetId) {
        [params setObject:tweetId forKey:@"in_reply_to_status_id"];
    }
    [self POST:@"1.1/statuses/update.json" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"done updating status: %@", responseObject);
        if (completion) {
            completion([[Tweet alloc]initWithDictionary:responseObject], nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"failed to update status: %@", error);
        if (completion) {
            completion(nil, error);
        }
    }];
}

- (void)deleteStatus:(NSNumber *)tweetId {
    [self POST:[NSString stringWithFormat:@"1.1/statuses/destroy/%@.json", tweetId] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"done deleting status %@", tweetId);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"failed to delete status: %@", error);
    }];
}

- (void)setAsFavorite:(BOOL)isFavorite withId:(NSNumber *)tweetId {
    NSString *endpoint = [NSString stringWithFormat:@"1.1/favorites/%@.json", isFavorite ? @"create" : @"destroy"];
    [self POST:endpoint parameters:@{@"id": tweetId} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"done setting favorite status of %ld to %d", [tweetId integerValue], isFavorite);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"failed to set favorite status of %ld to %d", [tweetId integerValue], isFavorite);
    }];
}

- (void)retweet:(NSNumber *)tweetId {
    [self POST:[NSString stringWithFormat:@"1.1/statuses/retweet/%@.json", tweetId] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"done retweeting ID %@", tweetId);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"failed to retweet ID %@", tweetId);
    }];
}

- (void)unretweet:(NSNumber *)tweetId {
    [self GET:[NSString stringWithFormat:@"1.1/statuses/show/%@.json", tweetId] parameters:@{@"trim_user": @"true", @"include_my_retweet":@"true"} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Got single tweet information: %@", responseObject);
        NSDictionary *myRetweetId = responseObject[@"current_user_retweet"];
        if (myRetweetId) {
            [self deleteStatus:myRetweetId[@"id"]];
        } else {
            NSLog(@"Could not get my retweet ID for this tweet");
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"failed to get specific tweet %@: %@", tweetId, error);
    }];
}

@end
