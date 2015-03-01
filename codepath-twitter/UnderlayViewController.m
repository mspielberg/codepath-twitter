//
//  UnderlayViewController.m
//  codepath-twitter
//
//  Created by Miles Spielberg on 2/27/15.
//  Copyright (c) 2015 OrionNet. All rights reserved.
//

#import "UnderlayViewController.h"
#import "TimelineViewController.h"

@interface UnderlayViewController ()

@property (strong, nonatomic) IBOutlet UIView *underlayView;
@property (strong, nonatomic) IBOutlet UIView *overlayView;
@property (strong, nonatomic) NSLayoutConstraint *overlayLeftConstraint;
@property (strong, nonatomic) NSLayoutConstraint *overlayRightPositionConstraint;
@property (nonatomic) CGFloat panStartX;

@end

@implementation UnderlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.overlayLeftConstraint = [NSLayoutConstraint constraintWithItem:self.overlayView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:0.0 constant:0.0];
    
    self.overlayRightPositionConstraint = [NSLayoutConstraint constraintWithItem:self.overlayView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0 constant:-self.overlayMinWidthShown];

    [self.view addConstraint:self.overlayLeftConstraint];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.overlayView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0.0]];
    
    // make sure properties set before the subviews were loaded are actually reflected in the view hierarchy
    if (self.underlayViewController) {
        self.underlayViewController = self.underlayViewController;
    }
    if (self.overlayViewController) {
        self.overlayViewController = self.overlayViewController;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onPanGesture:(UIPanGestureRecognizer *)sender {
    switch ([sender state]) {
        case UIGestureRecognizerStateBegan:
            [self.view removeConstraint:self.overlayRightPositionConstraint];
            [self.view addConstraint:self.overlayLeftConstraint];
            self.panStartX = CGRectGetMinX(self.overlayView.frame);
            [self setSplitX:self.panStartX];
            break;
        case UIGestureRecognizerStateChanged:
            [self setSplitX:self.panStartX + [sender translationInView:self.view].x];
            break;
        case UIGestureRecognizerStateEnded:
            if ([sender velocityInView:self.view].x > 0) {
                [self snapRightAnimated:YES];
            } else {
                [self snapLeftAnimated:YES];
            }
            break;
        default:
            NSLog(@"Unexpected state %ld for UIPanGestureRecognizer", sender.state);
    }
}

- (void)setSplitX:(CGFloat)x {
    CGFloat maxX = CGRectGetMaxX(self.view.bounds) - self.overlayMinWidthShown;
    self.overlayLeftConstraint.constant = MIN(maxX, MAX(0.0, x));
}

- (void)snapToggleAnimated:(BOOL)animated {
    if ([self.view.constraints containsObject:self.overlayRightPositionConstraint]) {
        [self snapLeftAnimated:animated];
    } else {
        [self snapRightAnimated:animated];
    }
}

- (void)snapLeftAnimated:(BOOL)animated {
    [self setSplitX:0.0];
    [self.view removeConstraint:self.overlayRightPositionConstraint];
    [self.view addConstraint:self.overlayLeftConstraint];

    if (animated) {
        [UIView animateWithDuration:0.3 animations:^{
            [self.view layoutIfNeeded];
        }];
    }
}

- (void)snapRightAnimated:(BOOL)animated {
    [self.view removeConstraint:self.overlayLeftConstraint];
    [self.view addConstraint:self.overlayRightPositionConstraint];

    if (animated) {
        [UIView animateWithDuration:0.3 animations:^{
            [self.view layoutIfNeeded];
        }];
    }
}

#pragma mark overlayMinWidthShown

- (void)setOverlayMinWidthShown:(CGFloat)overlayMinWidthShown {
    _overlayMinWidthShown = overlayMinWidthShown;
    self.overlayRightPositionConstraint.constant = -overlayMinWidthShown;
}

#pragma mark Child View Controller Properties

- (void)setUnderlayViewController:(UIViewController *)underlayViewController {
    _underlayViewController = underlayViewController;
    if (self.underlayView) {
        [self removeChildViewController:_underlayViewController fromView:self.underlayView];
        [self addChildViewController:underlayViewController asSubviewOfView:self.underlayView];
    }
}

- (void)setOverlayViewController:(UIViewController *)overlayViewController {
    _overlayViewController = overlayViewController;
    if (self.overlayView) {
        [self removeChildViewController:_overlayViewController fromView:self.overlayView];
        [self addChildViewController:overlayViewController asSubviewOfView:self.overlayView];
    }
}

- (void)addChildViewController:(UIViewController *)childController asSubviewOfView:(UIView *)view {
    [self addChildViewController:childController];
    UIView *childView = childController.view;
    [view addSubview:childView];
    childView.frame = view.bounds;
    [childView layoutIfNeeded];
    [view addConstraints:@[
//                           [NSLayoutConstraint constraintWithItem:childView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0.0],
//                           [NSLayoutConstraint constraintWithItem:childView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0.0],
//                           [NSLayoutConstraint constraintWithItem:childView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0.0],
//                           [NSLayoutConstraint constraintWithItem:childView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:view attribute:NSLayoutAttributeRight multiplier:1.0 constant:0.0]
                           ]];
    [childController didMoveToParentViewController:self];
}

- (void)removeChildViewController:(UIViewController *)childController fromView:(UIView *)view {
    [childController willMoveToParentViewController:nil];
    [childController.view removeFromSuperview];
    [childController removeFromParentViewController];
}

@end
