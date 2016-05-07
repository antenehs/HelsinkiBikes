//
//  FilterTableViewController.m
//  HelsinkiBikes
//
//  Created by Anteneh Sahledengel on 5/5/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "NotificationsTableViewController.h"
#import "LocalNotificationManager.h"
#import "SettingsManager.h"

@interface NotificationsTableViewController ()

@property(nonatomic, strong)LocalNotificationManager *notificationManager;

@end

@implementation NotificationsTableViewController

@synthesize notificationManager;

-(void)viewDidLoad {
    [super viewDidLoad];
    
    notificationManager = [LocalNotificationManager sharedManger];
    
    pickerDataOptions = [notificationManager customNotificationTypes];
    
    self.reloadTableViewRowAnimation = UITableViewRowAnimationAutomatic;
    self.deleteTableViewRowAnimation = UITableViewRowAnimationFade;
    self.insertTableViewRowAnimation = UITableViewRowAnimationAutomatic;
    
    [self setupInitialView];
    
    self.title = NSLocalizedString(@"NOTIFICATIONS", nil);
    enableNotificationLabel.text = NSLocalizedString(@"Enable Notifications", nil);
    defaultNotifLabel.text = NSLocalizedString(@"5 Minutes Before Free Time End", nil);
    customNotifLabel.text = NSLocalizedString(@"Custom", nil);
    self.navigationController.interactivePopGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>)self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)appWillEnterForeground:(NSNotification *)notification {
    [self setupInitialView];
}

-(void)setupInitialView {
    if ([notificationManager isLocalNotificationEnabled]) {
        enableNotifSwitch.on = [SettingsManager areNotificationsEnabled];
    } else {
        enableNotifSwitch.on = NO;
    }
    
    isCustomNotifications = [SettingsManager isCustomNotification];
    [customNotifPicker selectRow:[SettingsManager notificationTypeIndex] inComponent:0 animated:YES];
    [self updateVisibleCellsAnimated: NO];
}

-(void)setLabelTexts {
    
}

-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (!enableNotifSwitch.on) {
        return NSLocalizedString(@"Enable notifications to be updated about several things such as when free ride time is about to end and when you are charged certain amount of money.", nil);
    }
    return nil;
}

-(void)updateVisibleCellsAnimated:(BOOL)animated {
    self.hideSectionsWithHiddenRows = YES;
    if (enableNotifSwitch.on) {
        defaultNotifCell.accessoryType = isCustomNotifications ? UITableViewCellAccessoryNone : UITableViewCellAccessoryCheckmark;
        customNotifCell.accessoryType = isCustomNotifications ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        [self cells:allNotifsCells setHidden:NO];
        [self cell:customnotifPickerCell setHidden:!isCustomNotifications];
    } else {
        [self cells:allNotifsCells setHidden:YES];
        [self cell:customnotifPickerCell setHidden:YES];
    }
    
    [self reloadDataAnimated:animated];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell == defaultNotifCell) {
        isCustomNotifications = NO;
        [SettingsManager setIsCustomNotification:NO];
        [SettingsManager setNotificationTypeIndex:-1];
        [self.notificationManager updateCurrentNotification];
    } else if (cell == customNotifCell) {
        isCustomNotifications = YES;
        [SettingsManager setIsCustomNotification:YES];
        [SettingsManager setNotificationTypeIndex:[customNotifPicker selectedRowInComponent:0]];
        [self.notificationManager updateCurrentNotification];
    }
    
    [self updateVisibleCellsAnimated: YES];
}

- (IBAction)closeButtonTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)enableNotificationsTapped:(id)sender {
    if ([notificationManager isLocalNotificationEnabled]) {
        [SettingsManager saveNotificationsEnableStatus:enableNotifSwitch.on];
        [self updateVisibleCellsAnimated: YES];
    } else {
        if ([SettingsManager notificationGrantRequested]) {
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"No Access to Notifications Granted", nil)
                                                                           message:NSLocalizedString(@"Please grant access to Notifications from Settings to use this feature.", nil)
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Settings", nil) style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {
                                                                      [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                                                                  }];
            
            UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleCancel
                                                             handler:nil];
            [alert addAction:okAction];
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
            
            [SettingsManager saveNotificationsEnableStatus:enableNotifSwitch.on];
            enableNotifSwitch.on = NO;
        } else {
            [notificationManager registerNotification];
            [SettingsManager saveNotificationsEnableStatus:enableNotifSwitch.on];
        }
    }
    
    if (!enableNotifSwitch.on) {
        [[LocalNotificationManager sharedManger] cancelAllNotification];
    }
    
}

#pragma mark -Picker view
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return pickerDataOptions.count;
}

- (NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return pickerDataOptions[row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    [SettingsManager setNotificationTypeIndex:row];
    [self.notificationManager updateCurrentNotification];
}


@end
