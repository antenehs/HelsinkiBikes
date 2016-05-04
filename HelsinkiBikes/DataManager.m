//
//  DataManager.m
//  HelsinkiBikes
//
//  Created by Anteneh Sahledengel on 4/5/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "DataManager.h"

@interface DataManager ()

@property (nonatomic, strong)HSLCommunicator *hslCommunicator;

@end

@implementation DataManager
@synthesize hslCommunicator;

-(instancetype)init {
    self = [super init];
    if (self) {
        hslCommunicator = [[HSLCommunicator alloc] init];
    }
    
    return self;
}

-(void)getBikeStationsWithCompletionHandler:(ActionBlock)completion {
    [hslCommunicator fetchBikeStationsWithCompletionHandler:completion];
}

-(void)getBikeStationsForId:(NSString *)sationId WithCompletionHandler:(ActionBlock)completion {
    [hslCommunicator fetchBikeStationsForId:sationId WithCompletionHandler:completion];
}

@end
