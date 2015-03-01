//
//  MainMenuViewController.h
//  codepath-twitter
//
//  Created by Miles Spielberg on 2/28/15.
//  Copyright (c) 2015 OrionNet. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MainMenuViewController;

@protocol MainMenuViewControllerDelegate

- (void)mainMenuViewControllerDidSelectHome:(MainMenuViewController *)mainMenuViewController;
- (void)mainMenuViewControllerDidSelectMyProfile:(MainMenuViewController *)mainMenuViewController;
- (void)mainMenuViewControllerDidSelectMentions:(MainMenuViewController *)mainMenuViewController;

@end

@interface MainMenuViewController : UIViewController

@property (weak, nonatomic) id<MainMenuViewControllerDelegate> delegate;

@end
