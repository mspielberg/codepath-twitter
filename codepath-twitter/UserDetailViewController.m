//
//  UserDetailViewController.m
//  codepath-twitter
//
//  Created by Miles Spielberg on 2/28/15.
//  Copyright (c) 2015 OrionNet. All rights reserved.
//

#import "UserDetailViewController.h"
#import "UIImageView+AnimationUtils.h"

@interface UserDetailViewController ()

@property (strong, nonatomic) NSArray *propsToObserve;

@property (weak, nonatomic) IBOutlet UIView *myLayoutGuide;

@property (weak, nonatomic) IBOutlet UIImageView *headerImage;
@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *screenNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *tweetCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *followingCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *followersCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@end

@implementation UserDetailViewController

- (UserDetailViewController *)init {
    self = [super init];
    if (self) {
        self.propsToObserve = @[@"name",
                                @"screenName",
                                @"profileImageUrl",
                                @"bannerImageUrl",
                                @"userDescription",
                                @"followerCount",
                                @"friendCount",
                                @"statusCount"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.myLayoutGuide attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.topLayoutGuide attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0]];
    self.user = self.user;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark user

- (void) setUser:(User *)user {
    User *oldUser = _user;
    _user = user;
    for (NSString *keyPath in self.propsToObserve) {
        [oldUser removeObserver:self forKeyPath:keyPath];
        [user addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionInitial context:nil];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"name"]) {
        self.title = self.user.name;
        self.nameLabel.text = self.user.name;
    } else if ([keyPath isEqualToString:@"screenName"]) {
        self.screenNameLabel.text = [NSString stringWithFormat:@"@%@", self.user.screenName];
    } else if ([keyPath isEqualToString:@"profileImageUrl"]) {
        [self.profileImage setImageWithURL:self.user.profileImageUrl placeholderImage:nil duration:0.0];
        [self.profileImage setImageWithURL:self.user.largeProfileImageUrl placeholderImage:nil duration:0.3];
    } else if ([keyPath isEqualToString:@"bannerImageUrl"]) {
        [self.headerImage setImageWithURL:self.user.bannerImageUrl placeholderImage:nil duration:0.3];
    } else if ([keyPath isEqualToString:@"userDescription"]) {
        self.descriptionLabel.text = self.user.userDescription;
    } else if ([keyPath isEqualToString:@"followerCount"]) {
        self.followersCountLabel.text = [NSString stringWithFormat:@"%ld", self.user.followerCount];
    } else if ([keyPath isEqualToString:@"friendCount"]) {
        self.followingCountLabel.text = [NSString stringWithFormat:@"%ld", self.user.friendCount];
    } else if ([keyPath isEqualToString:@"statusCount"]) {
        self.tweetCountLabel.text = [NSString stringWithFormat:@"%ld", self.user.statusCount];
    }
}

@end
