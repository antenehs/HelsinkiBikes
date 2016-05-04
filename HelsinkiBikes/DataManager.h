//
//  DataManager.h
//  HelsinkiBikes
//
//  Created by Anteneh Sahledengel on 4/5/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HSLCommunicator.h"

@interface DataManager : NSObject

-(void)getBikeStationsWithCompletionHandler:(ActionBlock)completion;
-(void)getBikeStationsForId:(NSString *)sationId WithCompletionHandler:(ActionBlock)completion;

@end
