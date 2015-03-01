//
//  User.m
//  codepath-twitter
//
//  Created by Miles Spielberg on 2/17/15.
//  Copyright (c) 2015 OrionNet. All rights reserved.
//

#import "User.h"
#import "TwitterClient.h"

NSString *const UserDidLoginNotification = @"UserDidLoginNotification";
NSString *const UserDidLogoutNotification = @"UserDidLogoutNotification";

@interface User ()

@property (nonatomic, strong) NSDictionary *dictionary;

@end

@implementation User

- (User *)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.dictionary = dictionary;
        self.name = dictionary[@"name"];
        self.screenName = dictionary[@"screen_name"];
        self.profileImageUrl = [NSURL URLWithString:dictionary[@"profile_image_url"]];
        self.bannerImageUrl = [NSURL URLWithString:dictionary[@"profile_banner_url"]];
        self.friendCount = [dictionary[@"friends_count"] integerValue];
        self.followerCount = [dictionary[@"followers_count"] integerValue];
        self.statusCount = [dictionary[@"statuses_count"] integerValue];
        self.userDescription = dictionary[@"description"];
    }
    return self;
}

- (NSURL *)largeProfileImageUrl {
    NSString *baseImageUrl = self.dictionary[@"profile_image_url"];
    return [NSURL URLWithString:[baseImageUrl stringByReplacingOccurrencesOfString:@"_normal" withString:@"_reasonably_small"]];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p; name=%@, screenName=%@, profileImageUrl=%@, userDescription=%@>", self.class, self, self.name, self.screenName, self.profileImageUrl, self.userDescription];
}

- (NSDictionary *)prefsDictionary {
    return @{
             @"name": self.name,
             @"screen_name": self.screenName,
             @"profile_image_url": self.profileImageUrl.absoluteString,
             @"description": self.userDescription
             };
}

static User *_currentUser;

NSString *const kCurrentUserKey = @"kCurrentUserKey";

+ (User *)currentUser {
    if (!_currentUser) {
        NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:kCurrentUserKey];
        if (data) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
            _currentUser = [[User alloc] initWithDictionary:dict];
        }
    }
    return _currentUser;
}

+ (void)setCurrentUser:(User *)currentUser {
    _currentUser = currentUser;
    
    if (_currentUser) {
        NSData *data = [NSJSONSerialization dataWithJSONObject:currentUser.dictionary options:0 error:NULL];
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:kCurrentUserKey];
        [[NSNotificationCenter defaultCenter] postNotificationName:UserDidLoginNotification object:nil];
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kCurrentUserKey];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)logout {
    [User setCurrentUser:nil];
    [[TwitterClient sharedInstance].requestSerializer removeAccessToken];
    [[NSNotificationCenter defaultCenter] postNotificationName:UserDidLogoutNotification object:nil];
}

@end
