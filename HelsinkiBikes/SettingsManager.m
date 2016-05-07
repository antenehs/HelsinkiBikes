//
//  SettingsManager.m
//  
//
//  Created by Anteneh Sahledengel on 1/9/15.
//
//

#import "SettingsManager.h"

@implementation SettingsManager

+(void)saveNotificationsEnableStatus:(BOOL)enabled{
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    if (standardUserDefaults) {
        NSNumber *notificationsStatus = [NSNumber numberWithBool:enabled];
        [standardUserDefaults setObject:notificationsStatus  forKey:@"NotificationsEnabledStatus"];
        
        [standardUserDefaults synchronize];
    }
}

+(BOOL)areNotificationsEnabled{
    NSNumber *notificationsStatus = [[NSUserDefaults standardUserDefaults] objectForKey:@"NotificationsEnabledStatus"];
    
    if (notificationsStatus != nil) {
        bool status = [notificationsStatus boolValue];
        
        return status;
    }
    
    return NO;
}

+(void)setNotificationTypeIndex:(NSInteger)typeIndex {
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    if (standardUserDefaults) {
        [standardUserDefaults setObject:[NSNumber numberWithInteger:typeIndex]  forKey:@"NotificationsType"];
        
        [standardUserDefaults synchronize];
    }
}

+(NSInteger)notificationTypeIndex {
    NSNumber *notificationsType = [[NSUserDefaults standardUserDefaults] objectForKey:@"NotificationsType"];
    
    if (!notificationsType)
        return 1;
    
    return [notificationsType integerValue];
}

+(void)setIsCustomNotification:(BOOL)isCustom {
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    if (standardUserDefaults) {
        [standardUserDefaults setObject:[NSNumber numberWithBool:isCustom]  forKey:@"IsCustomNotificationsType"];
        
        [standardUserDefaults synchronize];
    }
}

+(BOOL)isCustomNotification {
    NSNumber *notificationsType = [[NSUserDefaults standardUserDefaults] objectForKey:@"IsCustomNotificationsType"];
    
    if (!notificationsType)
        return YES;
    
    return [notificationsType boolValue];
}

+(void)setNotificationGrantRequested:(BOOL)requested {
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    if (standardUserDefaults) {
        [standardUserDefaults setObject:[NSNumber numberWithBool:requested]  forKey:@"notificationGrantRequested"];
        
        [standardUserDefaults synchronize];
    }
}

+(BOOL)notificationGrantRequested {
    NSNumber *requested = [[NSUserDefaults standardUserDefaults] objectForKey:@"notificationGrantRequested"];
    
    if (!requested)
        return NO;
    
    return [requested boolValue];
}

@end
