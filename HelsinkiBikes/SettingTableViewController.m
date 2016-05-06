//
//  SettingTableViewController.m
//  HelsinkiBikes
//
//  Created by Anteneh Sahledengel on 5/5/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "SettingTableViewController.h"
#import <SafariServices/SafariServices.h>

@implementation SettingTableViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"MORE", nil);
    self.navigationController.interactivePopGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>)self;
}

#pragma mark - table view methods
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 1) {
        [self openAboutBikesPage];
    }
}

#pragma mark - Actions
- (IBAction)closeButtonTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)openAboutBikesPage {
    if ([SFSafariViewController class] != nil) {
        SFSafariViewController *controller = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:NSLocalizedString(@"https://www.hsl.fi/en/citybikes", nil)]];
        [self presentViewController:controller animated:YES completion:nil];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:NSLocalizedString(@"https://www.hsl.fi/en/citybikes", nil)]];
    }
}
//
//-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer { return YES;}

@end
