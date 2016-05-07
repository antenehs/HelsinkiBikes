//
//  ReittiRemindersManager.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 4/4/15.
//  Copyright (c) 2015 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface LocalNotificationManager : NSObject<UIAlertViewDelegate>

+(id)sharedManger;

-(void)setNotificationForDefaultTypeFromTime:(NSDate *)fromDate;
-(void)updateCurrentNotification;

-(void)cancelAllNotification;

-(BOOL)isLocalNotificationEnabled;
-(void)registerNotification;

-(void)openAppSettings;

@property(nonatomic, strong)NSArray *customNotificationTypes;

@end
