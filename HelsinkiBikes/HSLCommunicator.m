//
//  HSLCommunication.m
//  Reitti
//
//  Created by Anteneh Sahledengel on 12/4/15.
//  Copyright (c) 2015 Anteneh Sahledengel. All rights reserved.
//

#import "HSLCommunicator.h"
#import "StringFormatter.h"
#import "AppManager.h"
#import "BikeStation.h"

@interface HSLCommunicator ()

@property (nonatomic, strong) APIClient *bikeStationApi;

@end

@implementation HSLCommunicator

-(id)init{
    self = [super init];
    super.apiBaseUrl = @"http://api.reittiopas.fi/hsl/1_2_0/";
    
    self.bikeStationApi = [[APIClient alloc] init];
    self.bikeStationApi.apiBaseUrl = @"http://api.digitransit.fi/routing/v1/routers/hsl/bike_rental";
    
    hslApiUserNames = @[@"asacommuterstops", @"asacommuterstops2", @"asacommuterstops3", @"asacommuterstops4", @"asacommuterstops5",                        @"asacommuterstops6", @"asacommuterstops7", @"asacommuterstops8",
                        @"asacommuterroutes", @"asacommuterroutes2", @"asacommuterroutes3", @"asacommuterroutes4", @"asacommuterroutes5", @"asacommuterroutes6", @"asacommuterroutes7", @"asacommuterroutes8",
                        @"asacommuternearby", @"asacommuternearby2", @"asacommuternearby3", @"asacommuternearby4", @"asacommuternearby5", @"asacommuternearby6", @"asacommuternearby7", @"asacommuternearby8",
                        @"asacommutersearch", @"asacommutersearch2", @"asacommutersearch3", @"asacommutersearch4", @"asacommutersearch5", @"asacommutersearch6", @"asacommutersearch7", @"asacommutersearch8",
                        @"asacommuter", @"asacommuter2", @"asacommuter3", @"asacommuter4", @"commuterreversegeo" ];
    
    nextApiUsernameIndex = arc4random_uniform((int)hslApiUserNames.count);
    
    return self;
}

#pragma mark - Bike station fetching
-(void)fetchBikeStationsWithCompletionHandler:(ActionBlock)completion {
    [self.bikeStationApi doXmlApiFetchWithParams:nil responseDescriptor:[BikeStation responseDiscriptorForPath:@"stations"] andCompletionBlock:^(NSArray *responseArray, NSError *error) {
        completion(responseArray, error);
    }];
}

-(void)fetchBikeStationsForId:(NSString *)stationId WithCompletionHandler:(ActionBlock)completion {
    [self fetchBikeStationsWithCompletionHandler:^(NSArray *allStations, NSError *error) {
        if (!error && allStations && allStations.count > 0) {
            BikeStation *searchedStation = nil;
            for (BikeStation *station in allStations) {
                if ([station.stationId isEqualToString:stationId]) {
                    searchedStation = station;
                    break;
                }
            }
            completion(searchedStation, searchedStation ? nil : @"Station not found.");
        } else {
            completion(nil, @"Station not found.");
        }
    }];
}

#pragma mark - Stops in areas search protocol implementation
- (void)fetchStopsInAreaForRegionCenterCoords:(CLLocationCoordinate2D)regionCenter andDiameter:(NSInteger)diameter withCompletionBlock:(ActionBlock)completionBlock{
    
    NSMutableDictionary *optionsDict = [@{} mutableCopy];
    
    NSString *username = [self getApiUsername];
    
    [optionsDict setValue:username forKey:@"user"];
    [optionsDict setValue:@"rebekah" forKey:@"pass"];
    
    [super fetchStopsInAreaForRegionCenterCoords:regionCenter andDiameter:diameter withOptionsDictionary:optionsDict withCompletionBlock:completionBlock];
}

#pragma mark - stop detail fetch protocol implementation

- (void)fetchStopDetailForCode:(NSString *)stopCode withCompletionBlock:(ActionBlock)completionBlock{
//    NSMutableDictionary *optionsDict = [@{} mutableCopy];
//    
//    NSString *username = [self getApiUsername];
//    
//    [optionsDict setValue:username forKey:@"user"];
//    [optionsDict setValue:@"rebekah" forKey:@"pass"];
//    
//    [super fetchStopDetailForCode:stopCode andOptionsDictionary:optionsDict withCompletionBlock:^(NSArray *fetchResult, NSString *error){
//        if (!error) {
//            if (fetchResult.count > 0) {
//                //Assuming the stop code was unique and there is only one result
//                BusStop *stop = fetchResult[0];
//                
//                //Parse lines and departures
//                [self parseStopLines:stop];
//                [self parseStopDepartures:stop];
//                
//                completionBlock(stop, nil);
//            }
//        }else{
//            completionBlock(nil, error);
//        }
//    }];
}

#pragma mark - Geocode search protocol implementation
-(void)searchGeocodeForSearchTerm:(NSString *)searchTerm withCompletionBlock:(ActionBlock)completionBlock{
    NSMutableDictionary *optionsDict = [@{} mutableCopy];
    
    NSString *username = [self getApiUsername];
    
    [optionsDict setValue:username forKey:@"user"];
    [optionsDict setValue:@"rebekah" forKey:@"pass"];
    
    [optionsDict setValue:searchTerm forKey:@"key"];
    
    [super fetchGeocodeWithOptionsDictionary:optionsDict withcompletionBlock:completionBlock];
}

#pragma mark - Reverse geocode fetch protocol implementation
-(void)searchAddresseForCoordinate:(CLLocationCoordinate2D)coords withCompletionBlock:(ActionBlock)completionBlock{
    NSMutableDictionary *optionsDict = [@{} mutableCopy];
    
    NSString *username = [self getApiUsername];
    
    [optionsDict setValue:username forKey:@"user"];
    [optionsDict setValue:@"rebekah" forKey:@"pass"];
    
    NSString *coordStrings = [NSString stringWithFormat:@"%f,%f", coords.longitude, coords.latitude];
    [optionsDict setValue:coordStrings forKey:@"coordinate"];
    
    [super fetchRevereseGeocodeWithOptionsDictionary:optionsDict withcompletionBlock:completionBlock];
}
#pragma mark - Helpers
- (NSString *)getRandomUsername{
    int r = arc4random_uniform((int)hslApiUserNames.count);
    
    return hslApiUserNames[r];
}

- (NSString *)getApiUsername{
    
    if (nextApiUsernameIndex < hslApiUserNames.count - 1)
        nextApiUsernameIndex++;
    else
        nextApiUsernameIndex = 0;
    
    return hslApiUserNames[nextApiUsernameIndex];
}

//- (void)parseStopLines:(BusStop *)stop {
//    //Parse departures and lines
//    if (stop.lines) {
//        NSMutableArray *stopLinesArray = [@[] mutableCopy];
//        for (NSString *lineString in stop.lines) {
//            StopLine *line = [StopLine new];
//            NSArray *info = [lineString asa_stringsBySplittingOnString:@":"];
//            if (info.count >= 2) {
//                line.name = info[1];
//                line.destination = info[1];
//                NSString *lineCode = info[0];
//                line.fullCode = lineCode;
//                line.code = [HSLCommunication parseBusNumFromLineCode:lineCode];
//                
//                if (lineCode.length == 7) {
//                    line.direction = [lineCode substringWithRange:NSMakeRange(6, 1)];
//                }
//            }
//            line.lineType = [EnumManager lineTypeForStopType:stop.stopType];
//            line.lineEnd = line.destination;
//            [stopLinesArray addObject:line];
//        }
//        
//        stop.lines = stopLinesArray;
//    }
//}
//
//- (void)parseStopDepartures:(BusStop *)stop{
//    if (stop.departures && stop.departures.count > 0) {
//        NSMutableArray *departuresArray = [@[] mutableCopy];
//        for (NSDictionary *dictionary in stop.departures) {
//            if (![dictionary isKindOfClass:[NSDictionary class]]) 
//                continue;
//                
//            StopDeparture *departure = [StopDeparture modelObjectWithDictionary:dictionary];
//            //Parse line code
//            NSString *lineFullCode = departure.code;
//            departure.destination = [stop destinationForLineFullCode:lineFullCode];
//            
//            departure.code = [HSLCommunication parseBusNumFromLineCode:departure.code];
//            //Parse dates
//            departure.parsedDate = [super dateFromDateString:departure.date andHourString:departure.time];
//            if (!departure.parsedDate) {
//                //Do it the old school way. Might have a wrong date for after midnight times
//                NSString *notFormattedTime = departure.time ;
//                NSString *timeString = [ReittiStringFormatter formatHSLAPITimeWithColon:notFormattedTime];
//                departure.parsedDate = [[ReittiDateFormatter sharedFormatter] createDateFromString:timeString withMinOffset:0];
//            }
//            [departuresArray addObject:departure];
//        }
//        
//        stop.departures = departuresArray;
//    }
//}

//Expected format is XXXX(X) X
//Parsing logic https://github.com/HSLdevcom/navigator-proto/blob/master/src/routing.coffee#L40
//Original logic - http://developer.reittiopas.fi/pages/en/http-get-interface/frequently-asked-questions.php
+(NSString *)parseBusNumFromLineCode:(NSString *)lineCode{
    //TODO: Test with 1230 for weird numbers of the same 24 bus. 
//    NSArray *codes = [lineCode componentsSeparatedByString:@" "];
//    NSString *code = [codes objectAtIndex:0];
    
    //Line codes from HSL live could be only 4 characters
    if (lineCode.length < 4)
        return lineCode;
    
    //Try getting from line cache
//    CacheManager *cacheManager = [CacheManager sharedManager];
//    
//    NSString * lineName = [cacheManager getRouteNameForCode:lineCode];
    
//    if (lineName != nil && ![lineName isEqualToString:@""]) {
//        return lineName;
//    }
    
    //Can be assumed a metro
    if ([lineCode hasPrefix:@"1300"])
        return @"Metro";
    
    //Can be assumed a ferry
    if ([lineCode hasPrefix:@"1019"])
        return @"Ferry";
    
    //Can be assumed a train line
    if (([lineCode hasPrefix:@"3001"] || [lineCode hasPrefix:@"3002"]) && lineCode.length > 4) {
        NSString * trainLineCode = [lineCode substringWithRange:NSMakeRange(4, 1)];
        if (trainLineCode != nil && trainLineCode.length > 0)
            return trainLineCode;
    }
    
    //2-4. character = line code (e.g. 102)
    NSString *codePart = [lineCode substringWithRange:NSMakeRange(1, 3)];
    while ([codePart hasPrefix:@"0"]) {
        codePart = [codePart substringWithRange:NSMakeRange(1, codePart.length - 1)];
    }
    
    if (lineCode.length <= 4)
        return codePart;
    
    //5 character = letter variant (e.g. T)
    NSString *firstLetterVariant = [lineCode substringWithRange:NSMakeRange(4, 1)];
    if ([firstLetterVariant isEqualToString:@" "])
        return codePart;

    if (lineCode.length <= 5)
        return [NSString stringWithFormat:@"%@%@", codePart, firstLetterVariant];
    
    //6 character = letter variant or numeric variant (ignore number variant)
    NSString *secondLetterVariant = [lineCode substringWithRange:NSMakeRange(5, 1)];
    if ([secondLetterVariant isEqualToString:@" "] || [secondLetterVariant intValue])
        return [NSString stringWithFormat:@"%@%@", codePart, firstLetterVariant];
    
    return [NSString stringWithFormat:@"%@%@%@", codePart, firstLetterVariant, secondLetterVariant];
}

@end
