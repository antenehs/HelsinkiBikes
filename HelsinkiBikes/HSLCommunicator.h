//
//  HSLCommunication.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 12/4/15.
//  Copyright (c) 2015 Anteneh Sahledengel. All rights reserved.
//


#import "HSLAndTRECommon.h"

@class HSLCommunicator;

@interface HSLCommunicator : HSLAndTRECommon {
    
    NSArray *hslApiUserNames;
    NSInteger nextApiUsernameIndex;
}

-(void)fetchBikeStationsWithCompletionHandler:(ActionBlock)completion;
-(void)fetchBikeStationsForId:(NSString *)sationId WithCompletionHandler:(ActionBlock)completion;

+(NSString *)parseBusNumFromLineCode:(NSString *)lineCode;

@end
