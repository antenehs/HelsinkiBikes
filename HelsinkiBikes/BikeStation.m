//
//  BikeStation.m
//  HelsinkiBikes
//
//  Created by Anteneh Sahledengel on 4/5/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "BikeStation.h"
#import "StringFormatter.h"

@implementation BikeStation

+(RKResponseDescriptor *)responseDiscriptorForPath:(NSString *)path {
    RKObjectMapping* stationMapping = [RKObjectMapping mappingForClass:[BikeStation class] ];
    [stationMapping addAttributeMappingsFromDictionary:@{
                                                      @"id" : @"stationId",
                                                      @"name" : @"name",
                                                      @"x"     : @"xCoord",
                                                      @"y" : @"yCoord",
                                                      @"bikesAvailable" : @"bikesAvailable",
                                                      @"spacesAvailable" : @"spacesAvailable",
                                                      @"allowDropoff" : @"allowDropoff",
                                                      @"realTimeData" : @"realTimeData",
                                                      }];
    
    return [RKResponseDescriptor responseDescriptorWithMapping:stationMapping
                                                        method:RKRequestMethodAny
                                                   pathPattern:nil
                                                       keyPath:path
                                                   statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
}

-(CLLocationCoordinate2D)coordinates {
    if (self.xCoord && self.yCoord) {
        return [StringFormatter convertStringTo2DCoord:[NSString stringWithFormat:@"%@,%@", self.xCoord, self.yCoord]];
    }
    
    return CLLocationCoordinate2DMake(0, 0);
}

-(BOOL)isValid {
    return self.xCoord && self.yCoord;
}

@end
