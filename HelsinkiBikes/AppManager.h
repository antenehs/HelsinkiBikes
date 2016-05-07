//
//  AppManager.h
//  HelsinkiBikes
//
//  Created by Anteneh Sahledengel on 4/5/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface AppManager : NSObject

+(NSString *)appAppStoreLink;
+(NSString *)appAppStoreRateLink;

+(UIColor *)systemYellowColor;
+(UIColor *)systemGreenColor;
+(UIColor *)systemRedColor;

@end
