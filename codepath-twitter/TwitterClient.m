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

- (void)homeTimelineFromStartId:(NSNumber *)startId completion:(void(^)(NSArray *tweets, NSError *error))completion {
    NSDictionary *parameters;
    if (startId) {
        parameters = [NSDictionary dictionaryWithObject:@([startId integerValue] - 1) forKey:@"max_id"];
    }
    NSLog(@"Sending home_timeline request with parameters: %@", parameters);
    [self GET:@"1.1/statuses/home_timeline.json" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"home timeline: %@", responseObject);
        Tweet *lastTweet = [[Tweet alloc] initWithDictionary:responseObject[0]];
        NSLog(@"last tweet = %@", lastTweet);
        NSArray *allTweets = [Tweet tweetsWithArray:responseObject];
        NSLog(@"all tweets = %@", allTweets);
        completion(allTweets, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"failed to fetch home timeline");
        NSLog(@"error = %@", error);
        completion(nil, error);
    }];
}

- (void)updateStatus:(NSString *)status asReplyToTweetId:(NSNumber *)tweetId {
    [self POST:@"1.1/statuses/update.json" parameters:@{@"status":status, @"in_reply_to_status_id":tweetId} success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"done updating status: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"failed to update status: %@", error);
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

@end
