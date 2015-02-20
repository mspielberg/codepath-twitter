//
//  TimelineViewController.m
//  codepath-twitter
//
//  Created by Miles Spielberg on 2/18/15.
//  Copyright (c) 2015 OrionNet. All rights reserved.
//

#import "LoginViewController.h"
#import "TimelineViewController.h"
#import "TwitterClient.h"
#import "TweetCell.h"
#import "Tweet.h"
#import "LimitedWidthTextField.h"
#import "NSArray+ArrayOps.h"

static NSInteger const kComposeLengthLimit = 140;
static NSString * const UserDefaultsTweetsKey = @"UserDefaultsTweetsKey";

@interface TimelineViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>

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

@end

@implementation TimelineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Logout" style:UIBarButtonItemStylePlain target:self action:@selector(onLogout)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(onCompose)];
    
    UINib *tweetCellNib =[UINib nibWithNibName:@"TweetCell" bundle:nil];
    self.sizingCell = [[tweetCellNib instantiateWithOwner:self options:nil] firstObject];
    [self.tableView registerNib:tweetCellNib forCellReuseIdentifier:@"TweetCell"];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
    [self.refreshControl addTarget:self action:@selector(onRefresh) forControlEvents:UIControlEventValueChanged];
    
    self.composeViewOffscreenConstraint = [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.composeView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0];

    self.composeViewOnscreenConstraint = [NSLayoutConstraint constraintWithItem:self.topLayoutGuide attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.composeView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0L];
    
    [self.charsRemainingLabel removeFromSuperview];
    [self.composeTextField addSubview:self.charsRemainingLabel];
    self.composeTextField.rightInset = CGRectGetWidth(self.charsRemainingLabel.frame);
    [self.composeTextField addConstraints:@[
                                            [NSLayoutConstraint constraintWithItem:self.composeTextField attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.charsRemainingLabel attribute:NSLayoutAttributeRight multiplier:1.0 constant:8.0],
                                            [NSLayoutConstraint constraintWithItem:self.composeTextField attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.charsRemainingLabel attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]
                                            ]];
    [self.composeTextField layoutSubviews];
    
//    self.composeTextField.rightView = self.charsRemainingLabel;
//    self.composeTextField.rightViewMode = UITextFieldViewModeWhileEditing;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDidLogin) name:UserDidLoginNotification object:nil];
    
    [self loadTweetsFromUserDefaults];
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

- (void)onDidLogin {
    [self refresh];
}

- (void)onLogout {
    NSLog(@"Logout button pushed");
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
    
    [[TwitterClient sharedInstance] updateStatus:newTweet.text];
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
    [[TwitterClient sharedInstance] homeTimelineFromStartId:lastTweetId completion:^(NSArray *tweets, NSError *error) {
        if (tweets && tweets.count > 0) {
            self.isMoreTweetsAvailable = YES;
            self.tweets = [self.tweets arrayByAddingObjectsFromArray:tweets];
            [self saveTweetsToUserDefaults];
            [self.tableView reloadData];
        } else {
            self.isMoreTweetsAvailable = NO;
        }
    }];
}

#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tweets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Tweet *tweet = self.tweets[indexPath.row];
    TweetCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TweetCell"];
    cell.tweet = tweet;
    
    if (indexPath.row == self.tweets.count - 1 && self.isMoreTweetsAvailable) {
        [self loadMoreData];
    }
    
    return cell;
}

#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//        NSLog(@"entering heightForRowAtIndexPath");
    Tweet *tweet = self.tweets[indexPath.row];
//    NSLog(@"tweet = %@", tweet);
    self.sizingCell.tweet = tweet;
//        NSLog(@"Sizing row %ld with tweet %@", indexPath.row, self.sizingCell.tweet);
    [self.sizingCell layoutSubviews];
    CGFloat desiredHeight = [self.sizingCell systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
//        NSLog(@"Calculated height %f for row %ld", desiredHeight, indexPath.row);
    return desiredHeight;
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

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSInteger delta = string.length - range.length;
    NSInteger lengthAfterEdit = textField.text.length + delta;
    NSInteger remainingAfterEdit = kComposeLengthLimit - lengthAfterEdit;
    if (remainingAfterEdit >= 0) {
        self.charsRemainingLabel.text = [NSString stringWithFormat:@"%ld  ", remainingAfterEdit];
        return YES;
    } else {
        return NO;
    }
}
     
@end
