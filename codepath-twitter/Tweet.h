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

@property (nonatomic) NSInteger tweetId;
@property (nonatomic, strong) NSDate *creationTime;
@property (nonatomic, strong) User *user;
@property (nonatomic, strong) NSString *text;

- (Tweet *)initWithDictionary:(NSDictionary *)dictionary;

+ (NSArray *)tweetsWithArray:(NSArray *)array;

- (NSString *)relativeDate;

@end
