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
    
    self.title = @"Tweet";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(onCompose)];
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.userImageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.topLayoutGuide attribute:NSLayoutAttributeBottom multiplier:1.0 constant:8.0]];
    [self.view layoutIfNeeded];

    // ensure subviews are updated
    self.tweet = self.tweet;
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
    [_tweet removeObserver:self forKeyPath:@"favorited"];
    [_tweet removeObserver:self forKeyPath:@"favoriteCount"];
    [_tweet removeObserver:self forKeyPath:@"retweeted"];
    [_tweet removeObserver:self forKeyPath:@"retweetCount"];
    [tweet addObserver:self forKeyPath:@"favorited" options:NSKeyValueObservingOptionInitial context:nil];
    [tweet addObserver:self forKeyPath:@"favoriteCount" options:NSKeyValueObservingOptionInitial context:nil];
    [tweet addObserver:self forKeyPath:@"retweeted" options:NSKeyValueObservingOptionInitial context:nil];
    [tweet addObserver:self forKeyPath:@"retweetCount" options:NSKeyValueObservingOptionInitial context:nil];
    _tweet = tweet;
    
    self.userNameLabel.text = self.tweet.user.name;
    self.screenNameLabel.text = [NSString stringWithFormat:@"@%@", self.tweet.user.screenName];
    [self.userImageView setImageWithURL:self.tweet.user.profileImageUrl placeholderImage:nil duration:0.0];
    self.tweetTextLabel.text = self.tweet.text;
    self.dateLabel.text = [[self.class dateFormatter] stringFromDate:self.tweet.creationTime];
}

- (void)dealloc {
    [_tweet removeObserver:self forKeyPath:@"favorited"];
    [_tweet removeObserver:self forKeyPath:@"favoriteCount"];
    [_tweet removeObserver:self forKeyPath:@"retweeted"];
    [_tweet removeObserver:self forKeyPath:@"retweetCount"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"favorited"]) {
        if (self.tweet.isFavorited) {
            [self.favoriteButton setImage:[UIImage imageNamed:@"favorite_on"] forState:UIControlStateNormal];
        } else {
            [self.favoriteButton setImage:[UIImage imageNamed:@"favorite"] forState:UIControlStateNormal];
        }
    } else if ([keyPath isEqualToString:@"favoriteCount"]) {
        self.favoriteCountLabel.text = [NSString stringWithFormat:@"%ld", self.tweet.favoriteCount];
    } else if ([keyPath isEqualToString:@"retweeted"]) {
        if (self.tweet.isRetweeted) {
            [self.retweetButton setImage:[UIImage imageNamed:@"retweet_on"] forState:UIControlStateNormal];
        } else {
            [self.retweetButton setImage:[UIImage imageNamed:@"retweet"] forState:UIControlStateNormal];
        }
    } else if ([keyPath isEqualToString:@"retweetCount"]) {
        self.retweetCountLabel.text = [NSString stringWithFormat:@"%ld", self.tweet.retweetCount];
    }
}

- (void)onCompose {
    [self.navigationController popViewControllerAnimated:YES];
    [self.delegate tweetDetailViewControllerShouldComposeTweet:self];
}

- (IBAction)onFavorite:(id)sender {
    self.tweet.favorited = !self.tweet.isFavorited;
    if (self.tweet.isFavorited) {
        self.tweet.favoriteCount += 1;
    } else {
        self.tweet.favoriteCount -= 1;
    }
    
    [[TwitterClient sharedInstance] setAsFavorite:self.tweet.isFavorited withId:self.tweet.tweetId];
}

- (IBAction)onReply:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    [self.delegate tweetDetailViewControllerShouldComposeReply:self toTweet:self.tweet];
}

- (IBAction)onRetweet:(id)sender {
    NSLog(@"onRetweet");
    [self.delegate tweetDetailViewController:self shouldRetweetTweet:self.tweet];
}

@end
