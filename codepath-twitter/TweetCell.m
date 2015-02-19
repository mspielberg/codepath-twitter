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
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *screenNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *tweetTextLabel;

@end

@implementation TweetCell

- (void)awakeFromNib {
    // Initialization code
    self.tweetTextLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.tweetTextLabel.bounds);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setTweet:(Tweet *)tweet {
    User *user = tweet.user;
    [self.userImageView setImageWithURL:user.profileImageUrl placeholderImage:nil duration:0.3];
    self.nameLabel.text = user.name;
    self.screenNameLabel.text = [NSString stringWithFormat:@"@%@", user.screenName];
    self.timeLabel.text = [tweet relativeDate];
    self.tweetTextLabel.text = tweet.text;
}

@end
