//
//  ViewController.h
//  HelsinkiBikes
//
//  Created by Anteneh Sahledengel on 4/5/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "BouncingButton.h"

typedef enum
{
    TimerViewModeHidden = 0,
    TimerViewModeCompact = 1,
    TimerViewModeNormal = 2,
    TimerViewModeExpanded = 3
} TimerViewMode;

typedef enum
{
    TimerModeNotStarted = 0,
    TimerModeInitial = 1,
    TimerModeExtraTime = 2
} TimerMode;

@interface MainViewController : UIViewController <CLLocationManagerDelegate, MKMapViewDelegate, UITableViewDelegate, UITableViewDataSource> {
    
    //TOP VIEW
    IBOutlet UIView *timerView;
    IBOutlet BouncingButton *startRideButton;
    IBOutlet UILabel *timerLabel;
    IBOutlet NSLayoutConstraint *timerViewHeightConstraint;
    IBOutlet UILabel *additionalInfoLabel;
    IBOutlet NSLayoutConstraint *timerLabelBottomToInfoLabelConstraint;
    
    //MAP VIEW
    IBOutlet UIView *mapContainerView;
    IBOutlet MKMapView *mapView;
    IBOutlet UIButton *currentLocationButton;
    
    UILabel *lastUpdateTimeLabel;
    
    CLLocationManager *locationManager;
    CLLocation * currentUserLocation;
    BOOL skipUserLocation;
    BOOL isLocationServiceAvailable;
    
    NSTimer *updateTimer;
    NSDate *lastUpdateTime;
    
    NSTimer *counterTimer;
    NSDate *timerStartTime;
    BOOL isTimerSlowUpdating;
    BOOL isTimerRunning;
    
    double totalExtraCharge;
    
    NSString *tableViewInfoCellText;
    BOOL showRetryButton;
    BOOL viewAppearedFirstTime;
    
    TimerViewMode currentTimerViewMode;
    TimerMode currentTimerMode;
}

-(void)setNotificationForRunningTimer;

@property (nonatomic, weak)IBOutlet UITableView *tableView;
@property (nonatomic, strong)NSArray *bikeStations;

@end

