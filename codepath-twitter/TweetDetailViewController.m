//
//  TweetDetailViewController.m
//  codepath-twitter
//
//  Created by Miles Spielberg on 2/20/15.
//  Copyright (c) 2015 OrionNet. All rights reserved.
//

#import "TweetDetailViewController.h"
#import "UIImageView+AnimationUtils.h"
#import "TwitterClient.h"

@interface TweetDetailViewController ()

@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *screenNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *tweetTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;
@property (weak, nonatomic) IBOutlet UIButton *replyButton;
@property (weak, nonatomic) IBOutlet UIButton *retweetButton;
@property (weak, nonatomic) IBOutlet UILabel *favoriteCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *retweetCountLabel;

@end

@implementation TweetDetailViewController

+ (NSDateFormatter *)dateFormatter {
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.dateStyle = NSDateFormatterMediumStyle;
        formatter.timeStyle = NSDateFormatterShortStyle;
    });
    return formatter;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.userImageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.topLayoutGuide attribute:NSLayoutAttributeBottom multiplier:1.0 constant:8.0]];
    [self.view layoutIfNeeded];
    [self updateSubviews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)setTweet:(Tweet *)tweet {
    _tweet = tweet;
    [self updateSubviews];
}

- (void)updateSubviews {
    self.userNameLabel.text = self.tweet.user.name;
    self.screenNameLabel.text = [NSString stringWithFormat:@"@%@", self.tweet.user.screenName];
    [self.userImageView setImageWithURL:self.tweet.user.profileImageUrl placeholderImage:nil duration:0.0];
    self.tweetTextLabel.text = self.tweet.text;
    self.dateLabel.text = [[self.class dateFormatter] stringFromDate:self.tweet.creationTime];
    
    if (self.tweet.isFavorited) {
        [self.favoriteButton setImage:[UIImage imageNamed:@"favorite_on"] forState:UIControlStateNormal];
    } else {
        [self.favoriteButton setImage:[UIImage imageNamed:@"favorite"] forState:UIControlStateNormal];
    }
    
    if (self.tweet.isRetweeted) {
        [self.retweetButton setImage:[UIImage imageNamed:@"retweet_on"] forState:UIControlStateNormal];
    } else {
        [self.retweetButton setImage:[UIImage imageNamed:@"retweet"] forState:UIControlStateNormal];
    }
    
    self.favoriteCountLabel.text = [NSString stringWithFormat:@"%ld", self.tweet.favoriteCount];
    self.retweetCountLabel.text = [NSString stringWithFormat:@"%ld", self.tweet.retweetCount];
}

- (IBAction)onFavorite:(id)sender {
    self.tweet.favorited = !self.tweet.isFavorited;
    if (self.tweet.isFavorited) {
        self.tweet.favoriteCount += 1;
    } else {
        self.tweet.favoriteCount -= 1;
    }
    
    [[TwitterClient sharedInstance] setAsFavorite:self.tweet.isFavorited withId:self.tweet.tweetId];
    
    [self updateSubviews];
}

- (IBAction)onRetweet:(id)sender {
    self.tweet.retweeted = !self.tweet.isRetweeted;
    if (self.tweet.isRetweeted) {
        self.tweet.retweetCount += 1;
    } else {
        self.tweet.retweetCount -= 1;
    }
    
    [[TwitterClient sharedInstance] setAsFavorite:self.tweet.isFavorited withId:self.tweet.tweetId];
    
    [self updateSubviews];
}

@end
