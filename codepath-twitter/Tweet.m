//
//  Tweet.m
//  codepath-twitter
//
//  Created by Miles Spielberg on 2/17/15.
//  Copyright (c) 2015 OrionNet. All rights reserved.
//

#import "Tweet.h"
#import "NSArray+ArrayOps.h"

NSInteger const kOneMinute = 60;
NSInteger const kOneHour = kOneMinute * 60;
NSInteger const kOneDay = kOneHour * 24;

@implementation Tweet

+ (NSDateFormatter *)longDateFormatter {
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"EEE MMM d HH:mm:ss Z y";
    });
    return formatter;
}

+ (NSDateFormatter *)shortDateFormatter {
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateStyle = NSDateFormatterShortStyle;
        formatter.timeStyle = NSDateFormatterNoStyle;
    });
    return formatter;
}

+ (NSArray *)tweetsWithArray:(NSArray *)array {
    return [array mapWithBlock:^id(id dict) {
        return [[Tweet alloc] initWithDictionary:dict];
    }];
}

- (Tweet *)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        _dictionary = dictionary;
        self.tweetId = dictionary[@"id"];
        self.creationTime = [[Tweet longDateFormatter] dateFromString:dictionary[@"created_at"]];
        self.user = [[User alloc] initWithDictionary:dictionary[@"user"]];
        self.text = dictionary[@"text"];
        self.favorited = [dictionary[@"favorited"] boolValue];
        self.favoriteCount = [dictionary[@"favorite_count"] integerValue];
        self.retweeted = [dictionary[@"retweeted"] boolValue];
        self.retweetCount = [dictionary[@"retweet_count"] integerValue];
    }
    return self;
}

- (NSString *)relativeDate {
    NSTimeInterval sinceNow = -self.creationTime.timeIntervalSinceNow;
    if (sinceNow <= kOneHour) {
        return [NSString stringWithFormat:@"%.0fm ago", sinceNow / kOneMinute];
    } else if (sinceNow <= kOneDay) {
        return [NSString stringWithFormat:@"%.0fh ago", sinceNow / kOneHour];
    } else {
        return [[Tweet shortDateFormatter] stringFromDate:self.creationTime];
    }
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p; tweetId=%@, creationTime=%@, user=%@, text=%@>", self.class, self, self.tweetId, self.creationTime, self.user, self.text];
}

- (NSDictionary *)prefsDictionary {
    return @{
             @"id": self.tweetId,
             @"created_at": [[Tweet longDateFormatter] stringFromDate:self.creationTime],
             @"user": self.user.prefsDictionary,
             @"text": self.text,
             @"favorited": self.favorited ? @"true" : @"false",
             @"favorite_count": @(self.favoriteCount),
             @"retweeted": self.retweeted ? @"true" : @"false",
             @"retweet_count": @(self.retweetCount)
             };
}
@end
