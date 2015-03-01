//
//  LoginViewController.m
//  codepath-twitter
//
//  Created by Miles Spielberg on 2/17/15.
//  Copyright (c) 2015 OrionNet. All rights reserved.
//

#import "LoginViewController.h"
#import "TwitterClient.h"
#import "TimelineViewController.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    NSLog(@"Entering LoginViewController -viewDidLoad");
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"Twitter Login";
    [self startLogin];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)startLogin {
    LoginViewController __weak *lvc = self;
    [[TwitterClient sharedInstance] beginLoginWithCompletion:^ORNLoginCompletion(NSURL *authURL, NSError *error) {
        [self.webView loadRequest:[NSURLRequest requestWithURL:authURL]];
        ORNLoginCompletion completion = ^(User *user, NSError *error) {
            if (user) {
                NSLog(@"Login completed for %@", user);
                [lvc dismissViewControllerAnimated:YES completion:nil];
            } else {
                [self startLogin];
            }
        };
        return completion;
    }];
}

@end
