//
//  TweetCell.m
//  codepath-twitter
//
//  Created by Miles Spielberg on 2/18/15.
//  Copyright (c) 2015 OrionNet. All rights reserved.
//

#import "TweetCell.h"
#import "UIImageView+AnimationUtils.h"
#import "User.h"

@interface TweetCell ()
@property (weak, nonatomic) IBOutlet UIView *retweetView;
@property (weak, nonatomic) IBOutlet UILabel *retweetLabel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *mainTweetViewLayoutConstraint;

@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *screenNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *tweetTextLabel;

@property (weak, nonatomic) IBOutlet UIButton *favoriteButton;
@property (weak, nonatomic) IBOutlet UIButton *retweetButton;

@end

@implementation TweetCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    [self.userImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onUserInfoTap:)]];
    [self.nameLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onUserInfoTap:)]];
    [self.screenNameLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onUserInfoTap:)]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc {
    [_tweet removeObserver:self forKeyPath:@"favorited"];
    [_tweet removeObserver:self forKeyPath:@"retweeted"];
}

- (void)setTweet:(Tweet *)tweet {
    [_tweet removeObserver:self forKeyPath:@"favorited"];
    [_tweet removeObserver:self forKeyPath:@"retweeted"];
    
    _tweet = tweet;
    
    Tweet *originalTweet = tweet.originalTweet ? tweet.originalTweet : tweet;
    
    User *user = originalTweet.user;
    [self.userImageView setImageWithURL:user.profileImageUrl placeholderImage:nil duration:0.3];
    self.nameLabel.text = user.name;
    self.screenNameLabel.text = [NSString stringWithFormat:@"@%@", user.screenName];
    self.timeLabel.text = [originalTweet relativeDate];
    self.tweetTextLabel.text = originalTweet.text;
    
    if (tweet.originalTweet) {
        self.retweetView.hidden = false;
        self.retweetLabel.text = [NSString stringWithFormat:@"retweeted by @%@", tweet.user.screenName];
        self.mainTweetViewLayoutConstraint.constant = 28.0;

//        [self.retweetView.superview addConstraint:self.retweetViewLayoutConstraint];
    } else {
        self.retweetView.hidden = true;
        self.mainTweetViewLayoutConstraint.constant = 8.0;

//        [self.retweetView.superview removeConstraint:self.retweetViewLayoutConstraint];
    }
    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];
//    [self setNeedsLayout];
    
    [tweet addObserver:self forKeyPath:@"favorited" options:NSKeyValueObservingOptionInitial context:nil];
    [tweet addObserver:self forKeyPath:@"retweeted" options:NSKeyValueObservingOptionInitial context:nil];
}

- (void)updateConstraints {
//    if (self.tweet.originalTweet) {
//    } else {
//        [self.retweetView.superview addConstraint:self.mainTweetViewLayoutConstraint];
//    }
    [super updateConstraints];
    self.tweetTextLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.tweetTextLabel.bounds);
}

//- (void)layoutSubviews {
////    [self.contentView layoutIfNeeded];
//    self.tweetTextLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.tweetTextLabel.frame);
//    [super layoutSubviews];
//}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"favorited"]) {
        if (self.tweet.isFavorited) {
            [self.favoriteButton setImage:[UIImage imageNamed:@"favorite_on"] forState:UIControlStateNormal];
        } else {
            [self.favoriteButton setImage:[UIImage imageNamed:@"favorite"] forState:UIControlStateNormal];
        }
    } else if ([keyPath isEqualToString:@"retweeted"]) {
        if (self.tweet.isRetweeted) {
            [self.retweetButton setImage:[UIImage imageNamed:@"retweet_on"] forState:UIControlStateNormal];
        } else {
            [self.retweetButton setImage:[UIImage imageNamed:@"retweet"] forState:UIControlStateNormal];
        }
    }
}

- (IBAction)onFavorite:(id)sender {
    [self.delegate tweetCell:self shouldSetFavorite:!self.tweet.isFavorited ofTweet:self.tweet];
}

- (IBAction)onReply:(id)sender {
    [self.delegate tweetCell:self shouldReplyToTweet:self.tweet];
}

- (IBAction)onRetweet:(id)sender {
    [self.delegate tweetCell:self shouldRetweetTweet:self.tweet];
}

#pragma mark TapGestureRecognizer

- (IBAction)onUserInfoTap:(UITapGestureRecognizer *)sender {
    [self.delegate tweetCell:self shouldShouldUserProfile:self.tweet];
}

@end
