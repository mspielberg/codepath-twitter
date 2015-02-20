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
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"Twitter Login";
    
    LoginViewController __weak *lvc = self;
    [[TwitterClient sharedInstance] beginLoginWithCompletion:^ORNLoginCompletion(NSURL *authURL, NSError *error) {
        [self.webView loadRequest:[NSURLRequest requestWithURL:authURL]];
        ORNLoginCompletion completion = ^(User *user, NSError *error) {
            NSLog(@"Login completed for %@", user);
            [lvc dismissViewControllerAnimated:YES completion:nil];
        };
        return completion;
    }];
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

@end
