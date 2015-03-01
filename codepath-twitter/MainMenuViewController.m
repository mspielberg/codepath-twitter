//
//  MainMenuViewController.m
//  codepath-twitter
//
//  Created by Miles Spielberg on 2/28/15.
//  Copyright (c) 2015 OrionNet. All rights reserved.
//

#import "MainMenuViewController.h"
#import "UIImage+Crop.h"
#import "UIImage+SVG.h"

@interface MainMenuViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation MainMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITableViewDataSource

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor colorWithRed:.4 green:.5 blue:.9 alpha:1];
    cell.textLabel.textColor = [UIColor colorWithWhite:.9 alpha:1];
//    cell.imageView.backgroundColor = [UIColor colorWithWhite:.8 alpha:1];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
    switch (indexPath.row) {
        case 0:
            cell.imageView.image = [[UIImage imageWithSVGNamed:@"person" targetSize:CGSizeMake(32,32) fillColor:cell.textLabel.textColor] crop:CGRectMake(4,4,24,24)];
            cell.textLabel.text = @"My Profile";
            break;
        case 1:
            cell.imageView.image = [UIImage imageWithSVGNamed:@"home" targetSize:CGSizeMake(24,24) fillColor:cell.textLabel.textColor];
            cell.textLabel.text = @"Home";
            break;
        case 2:
            cell.imageView.image = [UIImage imageWithSVGNamed:@"mentions" targetSize:CGSizeMake(24,24) fillColor:cell.textLabel.textColor];
            cell.textLabel.text = @"Mentions";
            break;
        case 5:
            cell.imageView.image = [UIImage imageWithSVGNamed:@"door" targetSize:CGSizeMake(24,24) fillColor:cell.textLabel.textColor];
            cell.textLabel.text = @"Logout";
            break;
        default:
            break;

    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 6;
}

#pragma maxk UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
            [self.delegate mainMenuViewControllerDidSelectMyProfile:self];
            break;
        case 1:
            [self.delegate mainMenuViewControllerDidSelectHome:self];
            break;
        case 2:
            [self.delegate mainMenuViewControllerDidSelectMentions:self];
            break;
    }
}

@end
