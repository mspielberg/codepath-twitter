//
//  TimelineViewController.m
//  codepath-twitter
//
//  Created by Miles Spielberg on 2/18/15.
//  Copyright (c) 2015 OrionNet. All rights reserved.
//

#import "LoginViewController.h"
#import "TimelineViewController.h"
#import "TweetDetailViewController.h"
#import "UserDetailViewController.h"
#import "TwitterClient.h"
#import "TweetCell.h"
#import "Tweet.h"
#import "LimitedWidthTextField.h"
#import "NSArray+ArrayOps.h"

static NSInteger const kComposeLengthLimit = 140;
static NSString * const UserDefaultsTweetsKey = @"UserDefaultsTweetsKey";

@interface TimelineViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, TweetCellDelegate, TweetDetailViewControllerDelegate>

@property (nonatomic, strong) NSArray *tweets;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) IBOutlet UIView *composeView;
@property (nonatomic) BOOL isMoreTweetsAvailable;
@property (nonatomic, strong) TweetCell *sizingCell;

@property (nonatomic, strong) NSLayoutConstraint *composeViewOffscreenConstraint;
@property (nonatomic, strong) NSLayoutConstraint *composeViewOnscreenConstraint;
@property (weak, nonatomic) IBOutlet LimitedWidthTextField *composeTextField;
@property (weak, nonatomic) IBOutlet UILabel *charsRemainingLabel;

@property (nonatomic, strong) NSNumber *replyToTweetId;

@end

@implementation TimelineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"Home Timeline";
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:self action:@selector(onLogout)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(onCompose)];
    
    UINib *tweetCellNib =[UINib nibWithNibName:@"TweetCell" bundle:nil];
    self.sizingCell = [[tweetCellNib instantiateWithOwner:self options:nil] firstObject];
    NSLog(@"sizingCell initial size = %@", self.sizingCell);
    [self.tableView registerNib:tweetCellNib forCellReuseIdentifier:@"TweetCell"];
    
//    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
    [self.refreshControl addTarget:self action:@selector(onRefresh) forControlEvents:UIControlEventValueChanged];
    
    self.composeViewOffscreenConstraint = [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.composeView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];

    self.composeViewOnscreenConstraint = [NSLayoutConstraint constraintWithItem:self.topLayoutGuide attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.composeView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0L];
    
    [self.charsRemainingLabel removeFromSuperview];
    [self.composeTextField addSubview:self.charsRemainingLabel];
    self.composeTextField.rightInset = CGRectGetWidth(self.charsRemainingLabel.frame);
    [self.composeTextField addConstraints:@[
                                            [NSLayoutConstraint constraintWithItem:self.composeTextField attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.charsRemainingLabel attribute:NSLayoutAttributeRight multiplier:1.0 constant:28.0],
                                            [NSLayoutConstraint constraintWithItem:self.composeTextField attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.charsRemainingLabel attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]
                                            ]];
    [self.composeTextField layoutSubviews];
    
//    self.composeTextField.rightView = self.charsRemainingLabel;
//    self.composeTextField.rightViewMode = UITextFieldViewModeWhileEditing;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDidLogin) name:UserDidLoginNotification object:nil];
    
//    [self loadTweetsFromUserDefaults];
    [self refresh];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onDidLogin {
    [self refresh];
}

- (void)onLogout {
    NSLog(@"Logout button pushed");
    self.tweets = @[];
    [User logout];
    [self refresh];
}

- (void)onCompose {
    if (self.composeView.hidden) {
        [self showComposeView];
    } else {
        [self hideComposeViewWithCompletion:nil];
    }
}

- (IBAction)onTweetButton:(id)sender {
    Tweet *newTweet = [[Tweet alloc] init];
    newTweet.user = [User currentUser];
    newTweet.creationTime = [NSDate date];
    newTweet.text = self.composeTextField.text;
    [self hideComposeViewWithCompletion:^(BOOL finished) {
        self.composeTextField.text = @"";
    }];

    NSArray *oldTweets = self.tweets;
    self.tweets = [@[newTweet] arrayByAddingObjectsFromArray:oldTweets];
    [self.tableView reloadData];
    
    [[TwitterClient sharedInstance] updateStatus:newTweet.text asReplyToTweetId:self.replyToTweetId withCompletion:^(Tweet *tweet, NSError *error) {
        if (tweet) {
            newTweet.tweetId = tweet.tweetId;
        } else {
            NSLog(@"Got error from posting status: %@", error);
        }
    }];
}

- (void)onRefresh {
    [self refresh];
}

- (void)showComposeView {
    [self.view removeConstraints:@[self.composeViewOffscreenConstraint, self.composeViewOnscreenConstraint]];
    [self.view addConstraint:self.composeViewOffscreenConstraint];
    [self.view layoutIfNeeded];
    self.composeView.hidden = false;
    NSLog(@"Before show: %@", self.composeView);
    
    [self.view removeConstraint:self.composeViewOffscreenConstraint];
    [self.view addConstraint:self.composeViewOnscreenConstraint];
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
        NSLog(@"After show: %@", self.composeView);
    }];
    
    [self.composeTextField becomeFirstResponder];
}

- (void)hideComposeViewWithCompletion:(void(^)(BOOL finished))completion {
    [self.composeTextField endEditing:NO];
    
    [self.view removeConstraints:@[self.composeViewOffscreenConstraint, self.composeViewOnscreenConstraint]];
    [self.view addConstraint:self.composeViewOnscreenConstraint];
    [self.view layoutIfNeeded];
    NSLog(@"Before hide: %@", self.composeView);
    [self.view removeConstraint:self.composeViewOnscreenConstraint];
    [self.view addConstraint:self.composeViewOffscreenConstraint];
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
        NSLog(@"After hide: %@", self.composeView);
    } completion:^(BOOL finished) {
        self.composeView.hidden = true;
        if (completion) {
            completion(finished);
        }
    }];
}

- (void)refresh {
    if ([[TwitterClient sharedInstance] isAuthorized]) {
        self.tweets = @[];
        [self.tableView reloadData];
        [self loadMoreData];
        [self.refreshControl endRefreshing];
    } else {
        LoginViewController *lvc = [[LoginViewController alloc] init];
        UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:lvc];
        [self presentViewController:nc animated:YES completion:nil];
    }
}

- (void)loadMoreData {
    Tweet *lastTweet = self.tweets.lastObject;
    NSNumber *lastTweetId = lastTweet.tweetId;
    
    if (self.timelineFetchBlock) {
        void(^completion)(NSArray *tweets, NSError *error) = ^(NSArray *tweets, NSError *error) {
            if (tweets && tweets.count > 0) {
                self.isMoreTweetsAvailable = YES;
                self.tweets = [self.tweets arrayByAddingObjectsFromArray:tweets];
                [self saveTweetsToUserDefaults];
                [self.tableView reloadData];
            } else {
                self.isMoreTweetsAvailable = NO;
            }
        };
    
        self.timelineFetchBlock(lastTweetId, completion);
    }
}

- (void)setTweet:(Tweet *)tweet asFavorite:(BOOL)favorite {
    tweet.favorited = favorite;
    if (tweet.isFavorited) {
        tweet.favoriteCount += 1;
    } else {
        tweet.favoriteCount -= 1;
    }
    
    [[TwitterClient sharedInstance] setAsFavorite:tweet.isFavorited withId:tweet.tweetId];
}

- (void)replyToTweet:(Tweet *)tweet {
    NSString *atMention;
    if (tweet.originalTweet) {
        atMention = [NSString stringWithFormat:@"@%@ @%@", tweet.user.screenName, tweet.originalTweet.user.screenName];
    } else {
        atMention = [NSString stringWithFormat:@"@%@", tweet.user.screenName];
    }
    self.replyToTweetId = tweet.tweetId;
    if ([self.composeTextField.text rangeOfString:atMention].length == 0) {
        self.composeTextField.text = [NSString stringWithFormat:@"%@ %@", atMention, self.composeTextField.text];
        self.charsRemainingLabel.text = [NSString stringWithFormat:@"%ld", kComposeLengthLimit - self.composeTextField.text.length];
    }
    [self showComposeView];
}

- (void) setTweet:(Tweet *)tweet asRetweeted:(BOOL)retweeted {
    if (![[User currentUser].screenName isEqualToString:tweet.user.screenName]) {
        tweet.retweeted = retweeted;
        if (tweet.retweeted) {
            tweet.retweetCount += 1;
            [[TwitterClient sharedInstance] retweet:tweet.tweetId];
        } else {
            tweet.retweetCount -= 1;
            [[TwitterClient sharedInstance] unretweet:tweet.tweetId];
        }
    }
}

#pragma mark timelineFetchBlock

- (void)setTimelineFetchBlock:(TimelineFetchBlock)timelineFetchBlock {
    _timelineFetchBlock = timelineFetchBlock;
    [self refresh];
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tweets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"entering cellForRowAtIndexPath row=%ld", indexPath.row);
    CGFloat expectedHeight = [self tableView:self.tableView heightForRowAtIndexPath:indexPath];
    NSLog(@"expected cell for row %ld to have height %f", indexPath.row, expectedHeight);
    Tweet *tweet = self.tweets[indexPath.row];
    TweetCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TweetCell" forIndexPath:indexPath];
    NSLog(@"Dequeued cell %@ for row %ld with height %f", cell, indexPath.row, cell.frame.size.height);
    cell.delegate = self;
    cell.tweet = tweet;
    [self.sizingCell setNeedsLayout];
    [self.sizingCell layoutIfNeeded];
    NSLog(@"After layout, cell for row %ld has height %f", indexPath.row, cell.frame.size.height);

//    NSLog(@"Rechecked size for row %ld = %f", indexPath.row, [self tableView:self.tableView heightForRowAtIndexPath:indexPath]);
    if (indexPath.row == self.tweets.count - 1 && self.isMoreTweetsAvailable) {
        [self loadMoreData];
    }
    
    return cell;
}

#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"entering heightForRowAtIndexPath row=%ld", indexPath.row);
    Tweet *tweet = self.tweets[indexPath.row];
//    NSLog(@"tweet = %@", tweet);
//    CGRect frame = self.sizingCell.frame;
//    frame.size.width = self.tableView.frame.size.width;
//    self.sizingCell.frame = CGRectMake(0, 0, 250, 1024);
    CGFloat tableWidth = CGRectGetWidth(self.tableView.frame);
    self.sizingCell.frame = self.tableView.frame;
//    self.sizingCell.frame = CGRectMake(0, 0, tableWidth, 1024);
    self.sizingCell.tweet = tweet;
    
//    NSLog(@"Sizing row %ld with tweet %@", indexPath.row, self.sizingCell.tweet);
    [self.sizingCell setNeedsLayout];
    [self.sizingCell layoutIfNeeded];
//    [self.sizingCell layoutSubviews];
//    NSLog(@"sizingCell layout size = %@", self.sizingCell);
    CGFloat desiredHeight = [self.sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    NSLog(@"Calculated height %f for row %ld", desiredHeight, indexPath.row);
    return desiredHeight + 5;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TweetDetailViewController *dvc = [[TweetDetailViewController alloc] init];
    dvc.delegate = self;
    dvc.tweet = self.tweets[indexPath.row];
    [self.navigationController pushViewController:dvc animated:YES];
    return nil;
}

#pragma mark Persistance

- (void)saveTweetsToUserDefaults {
    [[NSUserDefaults standardUserDefaults] setObject:[self.tweets mapWithBlock:^id(Tweet *tweet) {
        return tweet.prefsDictionary;
    }] forKey:UserDefaultsTweetsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSLog(@"Saved %ld tweets to user defaults", self.tweets.count);
}

- (void)loadTweetsFromUserDefaults {
    NSArray *dictionaries = [[NSUserDefaults standardUserDefaults] objectForKey:UserDefaultsTweetsKey];
    if (dictionaries) {
        NSLog(@"Loaded %ld tweets from user defaults", dictionaries.count);
        self.tweets = [Tweet tweetsWithArray:dictionaries];
        self.isMoreTweetsAvailable = YES;
    } else {
        [self refresh];
    }
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    self.charsRemainingLabel.text = [NSString stringWithFormat:@"%ld", kComposeLengthLimit];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSInteger delta = string.length - range.length;
    NSInteger lengthAfterEdit = textField.text.length + delta;
    NSInteger remainingAfterEdit = kComposeLengthLimit - lengthAfterEdit;
    if (remainingAfterEdit >= 0 && [string rangeOfString:@"\n"].length == 0) {
        self.charsRemainingLabel.text = [NSString stringWithFormat:@"%ld", remainingAfterEdit];
        return YES;
    } else {
        return NO;
    }
}

#pragma mark TweetCellDelegate

- (void)tweetCell:(TweetCell *)tweetCell shouldReplyToTweet:(Tweet *)tweet {
    [self replyToTweet:tweet];
}

- (void)tweetCell:(TweetCell *)tweetCell shouldRetweetTweet:(Tweet *)tweet {
    NSLog(@"shouldRetweet %@", tweet);
    [self setTweet:tweet asRetweeted:!tweet.isRetweeted];
}

- (void)tweetCell:(TweetCell *)tweetCell shouldSetFavorite:(BOOL)favorite ofTweet:(Tweet *)tweet {
    [self setTweet:tweet asFavorite:favorite];
}

- (void)tweetCell:(TweetCell *)tweetCell shouldShouldUserProfile:(Tweet *)tweet {
    UserDetailViewController *udvc = [[UserDetailViewController alloc] init];
    Tweet *originalTweet = tweet.originalTweet ? tweet.originalTweet : tweet;
    udvc.user = originalTweet.user;
    [self.navigationController pushViewController:udvc animated:YES];
}

#pragma mark TweetDetailViewControllerDelegate

- (void)tweetDetailViewController:(TweetDetailViewController *)tweetDetailViewController tweet:(Tweet *)tweet shouldBecomeFavorite:(BOOL)favorite {
    [self setTweet:tweet asFavorite:favorite];
}

- (void)tweetDetailViewController:(TweetDetailViewController *)tweetDetailViewController shouldRetweetTweet:(Tweet *)tweet {
    NSLog(@"shouldRetweet %@", tweet);
    [self setTweet:tweet asRetweeted:!tweet.isRetweeted];
}

- (void)tweetDetailViewControllerShouldComposeTweet:(TweetDetailViewController *)tweetDetailViewController {
    [self showComposeView];
}

- (void)tweetDetailViewControllerShouldComposeReply:(TweetDetailViewController *)tweetDetailViewController toTweet:(Tweet *)tweet {
    [self replyToTweet:tweet];
}

@end
