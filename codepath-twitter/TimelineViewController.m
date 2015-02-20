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

@interface TimelineViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *tweets;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *composeView;
@property (nonatomic) BOOL isMoreTweetsAvailable;
@property (nonatomic, strong) TweetCell *sizingCell;

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDidLogin) name:UserDidLoginNotification object:nil];
    
    [self refresh];
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
    [self showComposeView];
}

- (void)showComposeView {
    [self.view addSubview:self.composeView];
//    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.topLayoutGuide attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.composeView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0L]];
    [self.view layoutSubviews];
    self.composeView.hidden = false;
}

- (void)refresh {
    if ([[TwitterClient sharedInstance] isAuthorized]) {
        self.tweets = @[];
        [self.tableView reloadData];
        [self loadMoreData];
    } else {
        LoginViewController *lvc = [[LoginViewController alloc] init];
        UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:lvc];
        [self presentViewController:nc animated:YES completion:nil];
    }
}

- (void)loadMoreData {
    Tweet *lastTweet = self.tweets.lastObject;
    NSNumber *lastTweetId = lastTweet ? @(lastTweet.tweetId) : nil;
    [[TwitterClient sharedInstance] homeTimelineFromStartId:lastTweetId completion:^(NSArray *tweets, NSError *error) {
        if (tweets && tweets.count > 0) {
            self.isMoreTweetsAvailable = YES;
            self.tweets = [self.tweets arrayByAddingObjectsFromArray:tweets];
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
        NSLog(@"entering heightForRowAtIndexPath");
    Tweet *tweet = self.tweets[indexPath.row];
    NSLog(@"tweet = %@", tweet);
    self.sizingCell.tweet = tweet;
        NSLog(@"Sizing row %ld with tweet %@", indexPath.row, self.sizingCell.tweet);
    [self.sizingCell layoutSubviews];
    CGFloat desiredHeight = [self.sizingCell systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
        NSLog(@"Calculated height %f for row %ld", desiredHeight, indexPath.row);
    return desiredHeight;
}
     
@end
