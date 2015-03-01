//
//  TimelineViewController.h
//  codepath-twitter
//
//  Created by Miles Spielberg on 2/18/15.
//  Copyright (c) 2015 OrionNet. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^TimelineFetchBlock)(NSNumber *startId, void (^completion)(NSArray *tweets, NSError *error));

@interface TimelineViewController : UIViewController

@property (strong, nonatomic) TimelineFetchBlock timelineFetchBlock;

@end
