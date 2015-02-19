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

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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

- (IBAction)onLogin:(id)sender {
    [[TwitterClient sharedInstance] loginWithCompletion:^(User *user, NSError *error) {
        if (user) {
            // Modally present tweets view
            NSLog(@"Thank you for logging in, %@", user.name);
            TimelineViewController *tvc = [[TimelineViewController alloc] init];
            UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:tvc];
            [self presentViewController:nc animated:YES completion:nil];
        } else {
            // Present error view
        }
    }];}

@end
