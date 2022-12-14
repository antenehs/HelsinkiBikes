//
//  ModelMapping.h
//  HelsinkiBikes
//
//  Created by Anteneh Sahledengel on 4/5/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RestKit/RestKit.h>

@protocol MappableObject <NSObject>

+(RKResponseDescriptor *)responseDiscriptorForPath:(NSString *)path;

@end

@interface ModelMapping : NSObject

@end
