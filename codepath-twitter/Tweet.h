//
//  Tweet.h
//  codepath-twitter
//
//  Created by Miles Spielberg on 2/17/15.
//  Copyright (c) 2015 OrionNet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface Tweet : NSObject

@property (nonatomic, readonly, strong) NSDictionary *dictionary;
@property (nonatomic, readonly, strong) NSDictionary *prefsDictionary;
@property (nonatomic) NSNumber *tweetId;
@property (nonatomic, strong) NSDate *creationTime;
@property (nonatomic, strong) User *user;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, getter=isFavorited) BOOL favorited;
@property (nonatomic) NSInteger favoriteCount;
@property (nonatomic, getter=isRetweeted) BOOL retweeted;
@property (nonatomic) NSInteger retweetCount;

- (Tweet *)initWithDictionary:(NSDictionary *)dictionary;

+ (NSArray *)tweetsWithArray:(NSArray *)array;

- (NSString *)relativeDate;

@end
