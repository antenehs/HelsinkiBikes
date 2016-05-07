//
//  AppManager.m
//  HelsinkiBikes
//
//  Created by Anteneh Sahledengel on 4/5/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "AppManager.h"

@implementation AppManager

+(NSString *)appAppStoreLink {
    return @"itms-apps://itunes.apple.com/app/id1110847211";
}

+(NSString *)appAppStoreRateLink {
    return @"http://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=1110847211&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8";
}

//fcbc19
+(UIColor *)systemYellowColor {
    return [UIColor colorWithRed:0.988 green:0.737 blue:0.098 alpha:1.00];
}

//2ebd59
+(UIColor *)systemGreenColor {
    return [UIColor colorWithRed:0.180 green:0.741 blue:0.349 alpha:1.00];
}

//fd4140
+(UIColor *)systemRedColor {
    return [UIColor colorWithRed:0.992 green:0.255 blue:0.251 alpha:1.00];
}

@end
