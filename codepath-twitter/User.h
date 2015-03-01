//
//  User.h
//  codepath-twitter
//
//  Created by Miles Spielberg on 2/17/15.
//  Copyright (c) 2015 OrionNet. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const UserDidLoginNotification;
extern NSString *const UserDidLogoutNotification;

@interface User : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *screenName;
@property (nonatomic, strong) NSURL *profileImageUrl;
@property (nonatomic, strong, readonly) NSURL *largeProfileImageUrl;
@property (nonatomic, strong) NSURL *bannerImageUrl;
@property (nonatomic, strong) NSString *userDescription;
@property (nonatomic) NSInteger followerCount;
@property (nonatomic) NSInteger friendCount;
@property (nonatomic) NSInteger statusCount;

- (User *)initWithDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)prefsDictionary;

+ (User *)currentUser;
+ (void)setCurrentUser:(User *)currentUser;
+ (void)logout;

@end
