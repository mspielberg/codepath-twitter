//
//  MainViewController.m
//  codepath-twitter
//
//  Created by Miles Spielberg on 2/28/15.
//  Copyright (c) 2015 OrionNet. All rights reserved.
//

#import "MainViewController.h"
#import "LoginViewController.h"
#import "MainMenuViewController.h"
#import "TimelineViewController.h"
#import "UnderlayViewController.h"
#import "UserDetailViewController.h"
#import "TwitterClient.h"
#import "UIImage+SVG.h"

@interface MainViewController () <MainMenuViewControllerDelegate>

@property (strong, nonatomic) UnderlayViewController *underlayViewController;
@property (strong, nonatomic) TimelineViewController *timelineViewController;
@property (strong, nonatomic) UINavigationController *timelineNavigationController;
@end

@implementation MainViewController

//- (MainViewController *)init {
//    self = [super init];
//    if (self) {
//    }
//    return self;
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    MainMenuViewController *mmvc = [[MainMenuViewController alloc] init];
    mmvc.delegate = self;
    UINavigationController *leftNav = [[UINavigationController alloc] initWithRootViewController:mmvc];
    
    self.timelineViewController = [[TimelineViewController alloc] init];
    self.timelineViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageWithSVGNamed:@"menu" targetSize:CGSizeMake(32, 32) fillColor:[UIColor blackColor]] style:UIBarButtonItemStylePlain  target:self action:@selector(onShowMenu)];
    
    self.timelineNavigationController = [[UINavigationController alloc] initWithRootViewController:self.timelineViewController];
    
    UnderlayViewController *uvc = [[UnderlayViewController alloc] init];
    self.underlayViewController = uvc;
    uvc.underlayViewController = leftNav;
    uvc.overlayMinWidthShown = 140.0;
    uvc.overlayViewController = self.timelineNavigationController;
    
    [self addChildViewController:uvc];
    uvc.view.frame = self.view.frame;
    [self.view addSubview:uvc.view];
    [uvc didMoveToParentViewController:self];
    
    [self showHomeTimeline];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showHomeTimeline) name:UserDidLoginNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDidLogout) name:UserDidLogoutNotification object:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    if (![TwitterClient sharedInstance].isAuthorized) {
        [self presentLogin];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onShowMenu {
    [self.underlayViewController snapToggleAnimated:YES];
}

- (void)showHomeTimeline {
    self.timelineViewController.timelineFetchBlock = ^(NSNumber *startId, void(^completion)(NSArray *tweets, NSError *error)) {
        [[TwitterClient sharedInstance] homeTimelineFromStartId:startId completion:completion];
    };
    self.underlayViewController.overlayViewController = self.timelineNavigationController;
    [self.underlayViewController snapLeftAnimated:YES];
}

- (void)showMentionsTimeline {
    self.timelineViewController.timelineFetchBlock = ^(NSNumber *startId, void(^completion)(NSArray *tweets, NSError *error)) {
        [[TwitterClient sharedInstance] mentionsTimelineFromStartId:startId completion:completion];
    };
    self.underlayViewController.overlayViewController = self.timelineNavigationController;
    [self.underlayViewController snapLeftAnimated:YES];
}

- (void)onDidLogout {
    [self presentLogin];
}

- (void)presentLogin {
    NSLog(@"Entering presentLogin");
    LoginViewController *lvc = [[LoginViewController alloc] init];
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:lvc];
    NSLog(@"Calling presentViewController");
    [self presentViewController:nc animated:YES completion:nil];
}

#pragma mark MainMenuViewControllerDelegate

- (void)mainMenuViewControllerDidSelectMyProfile:(MainMenuViewController *)mainMenuViewController {
    NSLog(@"Selected My Profile");
    UserDetailViewController *udvc = [[UserDetailViewController alloc] init];
    udvc.user = [User currentUser];
    udvc.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageWithSVGNamed:@"menu" targetSize:CGSizeMake(32, 32) fillColor:[UIColor blackColor]] style:UIBarButtonItemStylePlain  target:self action:@selector(onShowMenu)];
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:udvc];
    self.underlayViewController.overlayViewController = nvc;
    [self.underlayViewController snapLeftAnimated:YES];
}

- (void)mainMenuViewControllerDidSelectHome:(MainMenuViewController *)mainMenuViewController {
    [self showHomeTimeline];
}

- (void)mainMenuViewControllerDidSelectMentions:(MainMenuViewController *)mainMenuViewController {
    [self showMentionsTimeline];
}

- (void)mainMenuViewControllerDidSelectLogout:(MainMenuViewController *)mainMenuViewController {
    [User logout];
}

@end
