//
//  StopAnnotation.h
//  Reitti
//
//  Created by Anteneh Sahledengel on 4/3/14.
//  Copyright (c) 2014 Anteneh Sahledengel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

//typedef enum
//{
//    ServicePointAnnotationType = 1,
//    SalesPointAnnotationType = 2
//} AnnotationType;

@interface BikeStationAnnotation : NSObject<MKAnnotation> {
    
	NSString *title;
	CLLocationCoordinate2D coordinate;
}

@property (nonatomic, copy) NSString *code;
@property (nonatomic, copy) NSString *imageNameForView;
@property (nonatomic, copy) NSString *annotIdentifier;
@property (nonatomic) BOOL isSelected;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
//@property (nonatomic, readonly) AnnotationType annotationType;

- (id)initWithTitle:(NSString *)ttl andSubtitle:(NSString *)subttl andCoordinate:(CLLocationCoordinate2D)c2d;

@end
