//
//  ReittiRemindersManager.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 4/4/15.
//  Copyright (c) 2015 Anteneh Sahledengel. All rights reserved.
//

#import "LocalNotificationManager.h"
#import "StringFormatter.h"
#import "SettingsManager.h"

@interface LocalNotificationManager ()

@property(nonatomic, strong)NSArray *customNotificationTimes;
@property(nonatomic, strong)NSArray *customNotificationMessages;
@property(nonatomic, strong)NSDate *currentNotifStartTime;
@end

@implementation LocalNotificationManager

+(id)sharedManger{
    static LocalNotificationManager *remindersManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        remindersManager = [[self alloc] init];
    });
    
    return remindersManager;
}

-(id)init{
    self = [super init];
    if (self) {
        self.customNotificationTypes = @[NSLocalizedString(@"10 mins before free time ends", nil),
                                    NSLocalizedString(@"5 mins before free time ends", nil),
                                    NSLocalizedString(@"When free time ends", nil),
                                    NSLocalizedString(@"1,5 Euro extra charge", nil),
                                    NSLocalizedString(@"4,5 Euro extra charge", nil),
                                    NSLocalizedString(@"30 mins before max time", nil)];
        
        self.customNotificationTimes = @[@20,
                                         @25,
                                         @30,
                                         @90,
                                         @210,
                                         @270];
        
        self.customNotificationMessages = @[NSLocalizedString(@"Your free usage period will end in 10 minutes", nil),
                                            NSLocalizedString(@"Your free usage period will end in 5 minutes", nil),
                                            NSLocalizedString(@"Your free usage period just end. You will be charged extra from now on.", nil),
                                            NSLocalizedString(@"1,5 Euro extra charge", nil),
                                            NSLocalizedString(@"4,5 Euro extra charge", nil),
                                            NSLocalizedString(@"30 minutes remaining for the max allowed time.", nil)];
        
    }
    
    return self;
}

-(void)setNotificationForTypeIndex:(NSInteger)typeIndex fromTime:(NSDate *)date{
    [self cancelAllNotification];
    
    NSNumber *notifTime = self.customNotificationTimes[typeIndex];
    NSDate *notifDate = [date dateByAddingTimeInterval:notifTime.integerValue * 60];
//    NSDate *notifDate = [date dateByAddingTimeInterval:notifTime.integerValue]; //For testing
    if ([notifDate timeIntervalSinceNow] < 0) {
        return;
    }
    
    [self setNotificationForTime:notifDate andMessage:self.customNotificationMessages[typeIndex]];
    self.currentNotifStartTime = date;
}

-(void)setNotificationForDefaultTypeFromTime:(NSDate *)fromDate {
    NSInteger notifTypeIndex = [SettingsManager notificationTypeIndex];
    notifTypeIndex = notifTypeIndex == -1 ? 1 : notifTypeIndex;
    
    [self setNotificationForTypeIndex:notifTypeIndex fromTime:fromDate];
}

-(void)updateCurrentNotification {
    if (![self areThereActiveNotifications] || !self.currentNotifStartTime) {
        return;
    }
    
    [self setNotificationForDefaultTypeFromTime:self.currentNotifStartTime];
}

-(void)setNotificationForTime:(NSDate *)date andMessage:(NSString *)message{
    if ([self isLocalNotificationEnabled]) {
        [self scheduleOneTimeNotificationForDate:date andMessage:message userInfo:nil];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        [self openAppSettings];
    }
}

#pragma mark - Local

-(BOOL)isLocalNotificationEnabled{
    BOOL toReturn = NO;
    UIUserNotificationSettings *grantedSettings = [[UIApplication sharedApplication] currentUserNotificationSettings];
    
    if (grantedSettings.types == UIUserNotificationTypeNone) {
        NSLog(@"No permiossion granted");
        toReturn = NO;
    }
    else if (grantedSettings.types & UIUserNotificationTypeSound & UIUserNotificationTypeAlert ){
        NSLog(@"Sound and alert permissions ");
        toReturn = YES;
    }
    else if (grantedSettings.types  & UIUserNotificationTypeAlert){
        NSLog(@"Alert Permission Granted");
        toReturn = YES;
    }
    
    return toReturn;
}

-(void)registerNotification{
    
    UIUserNotificationType types = UIUserNotificationTypeBadge |
    UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
    
    UIUserNotificationSettings *mySettings =
    [UIUserNotificationSettings settingsForTypes:types categories:nil];
    
    [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
    
    [SettingsManager setNotificationGrantRequested:YES];
}

-(void)scheduleOneTimeNotificationForDate:(NSDate *)date andMessage:(NSString *)body userInfo:(NSDictionary *)userInfo {
    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
    localNotification.alertBody = body;
    localNotification.alertAction = NSLocalizedString(@"see stations nearby", nil);
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    localNotification.userInfo = userInfo;
    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    localNotification.fireDate = date;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

-(BOOL)areThereActiveNotifications {
    return [[UIApplication sharedApplication] scheduledLocalNotifications].count > 0;
}

-(void)cancelAllNotification{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

#pragma mark - Helpers
- (void)openAppSettings{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}

@end
