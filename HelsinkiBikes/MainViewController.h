//
//  ViewController.h
//  HelsinkiBikes
//
//  Created by Anteneh Sahledengel on 4/5/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface MainViewController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource> {
    
    //TOP VIEW
    IBOutlet UIView *timerView;
    IBOutlet UIButton *startRideButton;
    IBOutlet UILabel *timerLabel;
    IBOutlet NSLayoutConstraint *timerViewHeightConstraint;
    
    //MAP VIEW
    IBOutlet UIView *mapContainerView;
    IBOutlet MKMapView *mapView;
    IBOutlet UIButton *currentLocationButton;
    
    CLLocationManager *locationManager;
    CLLocation * currentUserLocation;
    BOOL skipUserLocation;
    
    
}

@property (nonatomic, weak)IBOutlet UITableView *tableView;
@property (nonatomic, strong)NSArray *bikeStations;

@end

