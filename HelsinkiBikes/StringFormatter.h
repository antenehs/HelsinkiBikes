//
//  ReittiStringFormatter.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 27/2/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface StringFormatter : NSObject

+(NSString *)formatHSLAPITimeWithColon:(NSString *)hslTime;
+(NSString *)formatHSLAPITimeToHumanTime:(NSString *)hslTime;
+(NSString *)formatDurationString:(NSInteger)seconds;
+(NSString *)formatFullDurationString:(NSInteger)seconds;
+(NSString *)formatPrittyDate:(NSDate *)date;
+(NSAttributedString *)formatAttributedDurationString:(NSInteger)seconds withFont:(UIFont *)font;
+(NSAttributedString *)formatAttributedString:(NSString *)numberString withUnit:(NSString *)unitString withFont:(UIFont *)font andUnitFontSize:(NSInteger)smallFontSize;
+(NSString *)formatHSLDateWithDots:(NSString *)hslData;
+(NSString *)commaSepStringFromArray:(NSArray *)array withSeparator:(NSString *)separator;
+(NSAttributedString *)highlightSubstringInString:(NSString *)text substring:(NSString *)substring normalFont:(UIFont *)font hightlightColor:(UIColor *)color;
+(NSAttributedString *)highlightSubstringInString:(NSString *)text substring:(NSString *)substring normalFont:(UIFont *)font highlightedFont:(UIFont *)highlightedFont hightlightColor:(UIColor *)color;
+(CLLocationCoordinate2D)convertStringTo2DCoord:(NSString *)coordString;
+(NSString *)convert2DCoordToString:(CLLocationCoordinate2D)coord;
+(NSString *)formatRoundedNumberFromDouble:(double)doubleVal roundDigits:(int)roundPoints androundUp:(BOOL)roundUp;

@end
