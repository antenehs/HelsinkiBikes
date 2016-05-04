//
//  ViewController.h
//  HelsinkiBikes
//
//  Created by Anteneh Sahledengel on 4/5/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface MainViewController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate> {
    
    IBOutlet MKMapView *mapView;
    IBOutlet UIButton *currentLocationButton;
    
    CLLocationManager *locationManager;
    CLLocation * currentUserLocation;
    BOOL skipUserLocation;
}


@end

