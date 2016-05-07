//
//  SettingsManager.h
//  
//
//  Created by Anteneh Sahledengel on 1/9/15.
//
//

#import <Foundation/Foundation.h>

@interface SettingsManager : NSObject

+(void)saveNotificationsEnableStatus:(BOOL)enabled;
+(BOOL)areNotificationsEnabled;

+(void)setNotificationTypeIndex:(NSInteger)typeIndex;
+(NSInteger)notificationTypeIndex;

+(void)setIsCustomNotification:(BOOL)isCustom;
+(BOOL)isCustomNotification;

+(void)setNotificationGrantRequested:(BOOL)requested;
+(BOOL)notificationGrantRequested;

@end
