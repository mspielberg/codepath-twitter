//
//  UnderlayViewController.h
//  codepath-twitter
//
//  Created by Miles Spielberg on 2/27/15.
//  Copyright (c) 2015 OrionNet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UnderlayViewController : UIViewController

@property (strong, nonatomic) UIViewController *underlayViewController;
@property (strong, nonatomic) UIViewController *overlayViewController;

@property (nonatomic) CGFloat overlayMinWidthShown;

- (void)snapToggleAnimated:(BOOL)animated;
- (void)snapLeftAnimated:(BOOL)animated;
- (void)snapRightAnimated:(BOOL)animated;

@end
