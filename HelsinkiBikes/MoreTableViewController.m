//
//  SettingTableViewController.m
//  HelsinkiBikes
//
//  Created by Anteneh Sahledengel on 5/5/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "MoreTableViewController.h"
#import <SafariServices/SafariServices.h>
#import "AppManager.h"
#import <Social/Social.h>

@implementation MoreTableViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"MORE", nil);
    self.navigationController.interactivePopGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>)self;
    
    aboutBikesLabel.text = NSLocalizedString(@"About Helsinki City Bikes", nil);
    notificationsLabel.text = NSLocalizedString(@"Notifications", nil);
    contactMeLabel.text = NSLocalizedString(@"Contact Me", nil);
    tellAFriendLabel.text = NSLocalizedString(@"Tell A Friend", nil);
    rateLabel.text = NSLocalizedString(@"Rate", nil);
}

#pragma mark - table view methods
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 1) {
        [self openAboutBikesPage];
    } else if (indexPath.section == 2 && indexPath.row == 0) {
        [self contactUsButtonPressed:self];
    } else if (indexPath.section == 2 && indexPath.row == 1) {
        [self shareButtonPressed:self];
    } else if (indexPath.section == 2 && indexPath.row == 2) {
        [self rateInAppStoreButtonPressed:self];
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 2) {
        return NSLocalizedString(@"© 2016 Ewket Apps. This app is made to help people use HSL's City Bike service and it is not affiliated with HSL in anyway. ", nil);
    }
    
    return nil;
}

#pragma mark - Actions
- (IBAction)closeButtonTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)openAboutBikesPage {
    /* Do not open in safariviewcontroll because it causes app review to be rejected.
    if ([SFSafariViewController class] != nil) {
        SFSafariViewController *controller = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:NSLocalizedString(@"https://www.hsl.fi/en/citybikes", nil)]];
        [self presentViewController:controller animated:YES completion:nil];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:NSLocalizedString(@"https://www.hsl.fi/en/citybikes", nil)]];
    }
     */
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:NSLocalizedString(@"https://www.hsl.fi/en/citybikes", nil)]];
}

- (IBAction)contactUsButtonPressed:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Feel free to contact me for anything, even just to say hi!", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel") destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Request A Feature", nil), NSLocalizedString(@"Report A Bug", nil), NSLocalizedString(@"Say Hi!", nil), nil];
    
    actionSheet.tag = 1002;
    [actionSheet showInView:self.view];
}

- (IBAction)shareButtonPressed:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"They say sharing is caring, right?.", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Share on Facebook", nil),
                                                                                                                                                                                                                                                                NSLocalizedString(@"Share on Twitter", nil), nil];
    //actionSheet.tintColor = SYSTEM_GRAY_COLOR;
    actionSheet.tag = 1001;
    [actionSheet showInView:self.view];
}

- (IBAction)rateInAppStoreButtonPressed:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[AppManager appAppStoreRateLink]]];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 1001){
        switch (buttonIndex) {
            case 0:
                [self postToFacebook];
                break;
            case 1:
                [self postToTwitter];
                break;
            default:
                break;
        }
    }else if (actionSheet.tag == 1002){
        switch (buttonIndex) {
            case 0:
                [self sendEmailWithSubject:NSLocalizedString(@"[Helsinki Bikes Feature Request] - ", nil)];
                break;
            case 1:
                [self sendEmailWithSubject:NSLocalizedString(@"[Helsinki Bikes Bug Report] - ", nil)];
                break;
            case 2:
                [self sendEmailWithSubject:NSLocalizedString(@"Hi Helsinki Bikes Guys - ", nil)];
                break;
            default:
                break;
        }
    }
}

- (void)sendEmailWithSubject:(NSString *)subject{
    // Email Subject
    NSString *emailTitle = subject;
    // Email Content
    NSString *messageBody = @"";
    // To address
    NSArray *toRecipents = [NSArray arrayWithObject:@"ewketapps@gmail.com"];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:NO];
    [mc setToRecipients:toRecipents];
    
    // Present mail view controller on screen
    [self presentViewController:mc animated:YES completion:NULL];
    
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            //            [self.reittiDataManager setAppOpenCountValue:-100];
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)postToFacebook {
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        [controller setInitialText:NSLocalizedString(@"Check out Helsinki bikes for using HSL City Bikes.", nil)];
        [controller addURL:[NSURL URLWithString:[AppManager appAppStoreLink]]];
        
        [self presentViewController:controller animated:YES completion:Nil];
        
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Sorry", nil)
                                                            message:NSLocalizedString(@"You can't post to Facebook right now. Make sure your device has an internet connection and you have at least one Facebook account setup", nil)
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

- (void)postToTwitter {
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *tweetSheet = [SLComposeViewController
                                               composeViewControllerForServiceType:SLServiceTypeTwitter];
        [tweetSheet setInitialText:NSLocalizedString(@"Check out Helsinki bikes for using HSL City Bikes.", nil)];
        [tweetSheet addURL:[NSURL URLWithString:[AppManager appAppStoreLink]]];;

        [self presentViewController:tweetSheet animated:YES completion:nil];
    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Sorry", nil)
                                                            message:NSLocalizedString(@"You can't send a tweet right now. Make sure your device has an internet connection and you have at least one Twitter account setup", nil)
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}


@end
