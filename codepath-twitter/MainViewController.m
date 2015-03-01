//
//  MainViewController.m
//  codepath-twitter
//
//  Created by Miles Spielberg on 2/28/15.
//  Copyright (c) 2015 OrionNet. All rights reserved.
//

#import "MainViewController.h"
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

- (MainViewController *)init {
    self = [super init];
    if (self) {
        MainMenuViewController *mmvc = [[MainMenuViewController alloc] init];
        mmvc.delegate = self;
        UINavigationController *leftNav = [[UINavigationController alloc] initWithRootViewController:mmvc];
        
        self.timelineViewController = [[TimelineViewController alloc] init];

        self.timelineNavigationController = [[UINavigationController alloc] initWithRootViewController:self.timelineViewController];
        
        UnderlayViewController *uvc = [[UnderlayViewController alloc] init];
        self.underlayViewController = uvc;
        uvc.underlayViewController = leftNav;
        uvc.overlayMinWidthShown = 140.0;
        uvc.overlayViewController = self.timelineNavigationController;
        
        [self addChildViewController:uvc];
        self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        uvc.view.frame = self.view.frame;
        [self.view addSubview:uvc.view];
        [uvc didMoveToParentViewController:self];
        
        [self showHomeTimeline];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
}

- (void)showMentionsTimeline {
    self.timelineViewController.timelineFetchBlock = ^(NSNumber *startId, void(^completion)(NSArray *tweets, NSError *error)) {
        [[TwitterClient sharedInstance] mentionsTimelineFromStartId:startId completion:completion];
    };

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
    NSLog(@"Selected Home");
    [self showHomeTimeline];
    self.underlayViewController.overlayViewController = self.timelineNavigationController;
    [self.underlayViewController snapLeftAnimated:YES];

}

- (void)mainMenuViewControllerDidSelectMentions:(MainMenuViewController *)mainMenuViewController {
    NSLog(@"Selected Mentions");
    [self showMentionsTimeline];
    self.underlayViewController.overlayViewController = self.timelineNavigationController;
    [self.underlayViewController snapLeftAnimated:YES];
}

@end
