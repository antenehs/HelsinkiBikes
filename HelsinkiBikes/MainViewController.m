//
//  ViewController.m
//  HelsinkiBikes
//
//  Created by Anteneh Sahledengel on 4/5/16.
//  Copyright © 2016 Anteneh Sahledengel. All rights reserved.
//

#import "MainViewController.h"
#import "AppManager.h"
#import "DataManager.h"
#import "ServicePointAnnotation.h"
#import "BikeStation.h"
#import "UIScrollView+APParallaxHeader.h"

CLLocationCoordinate2D kHslRegionCenter = {.latitude =  60.170163, .longitude =  24.941352};

@interface MainViewController ()

@property (nonatomic, strong)DataManager *dataManager;

@end

@implementation MainViewController
@synthesize dataManager;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    skipUserLocation = YES;
    self.bikeStations = @[];
    dataManager = [[DataManager alloc] init];
    
    [self setupMainView];
    [self setupMapView];
    [self initializeLocation];
    [self fetchAllBikeStations];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self setupMapView];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self setupMapView];
}

- (void)setupMainView {
    [self setTitle:NSLocalizedString(@"HELSINKI ROUTES", nil)];
}

- (void)setUpTimerView {
    [startRideButton setTitle:NSLocalizedString(@"START RIDE", nil) forState:UIControlStateNormal];
}

- (void)setupMapView {
    CGFloat height = 300;
    [mapContainerView setFrame:CGRectMake(0, 0, self.view.frame.size.width, height)];
    
    CLLocationCoordinate2D coord = {.latitude =  60.1733239, .longitude =  24.9410248};
    [self centerMapRegionToCoordinate:coord];
    
    currentLocationButton.layer.cornerRadius = 4.0;
    currentLocationButton.layer.borderWidth = 0.5;
    currentLocationButton.layer.borderColor = [AppManager systemYellowColor].CGColor;
    
    [self.tableView addParallaxWithView:mapContainerView andHeight:height];
}

#pragma mark - table view methods
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.bikeStations.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"bikeStationCell" forIndexPath:indexPath];
    //TODO: show last update time.
    BikeStation *station = self.bikeStations[indexPath.section];
    
    UILabel *nameLabel = (UILabel *)[cell viewWithTag:1002];
    UILabel *bikesLabel = (UILabel *)[cell viewWithTag:1004];
    UILabel *spacesLabel = (UILabel *)[cell viewWithTag:1005];
    
    nameLabel.text = station.name;
    bikesLabel.text = [NSString stringWithFormat:@"%d %@", station.bikesAvailable.intValue, NSLocalizedString(@"BIKES", nil)];
    spacesLabel.text = [NSString stringWithFormat:@"%d %@", station.spacesAvailable.intValue, NSLocalizedString(@"SPACES", nil)];
    
    bikesLabel.layer.borderWidth = 0.5;
    bikesLabel.layer.borderColor = [UIColor lightGrayColor].CGColor;
    bikesLabel.layer.cornerRadius = 2;
    
    spacesLabel.layer.borderWidth = 0.5;
    spacesLabel.layer.borderColor = [UIColor lightGrayColor].CGColor;
    spacesLabel.layer.cornerRadius = 2;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 30;
    }
    
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 10.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section != 0) {
        return nil;
    }
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
    view.backgroundColor = [UIColor clearColor];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 110, 30)];
    titleLabel.font = [UIFont systemFontOfSize:14];
    titleLabel.textColor = [AppManager systemYellowColor];
    titleLabel.adjustsFontSizeToFitWidth = YES;
    if (section == 0) {
        titleLabel.text = [self isLocationServiceAvailableWithNotification:NO] ? NSLocalizedString(@"NEAR ME", nil) : NSLocalizedString(@"ALL STATIONS", nil);
    }
    [view addSubview:titleLabel];
    
//    if (self._busStop.timetable_link) {
//        fullTimeTableButton = [UIButton buttonWithType:UIButtonTypeSystem];
//        fullTimeTableButton.frame = CGRectMake(self.view.frame.size.width - 107, 0, 100, 30);
//        [fullTimeTableButton setTitle:@"Full timetable" forState:UIControlStateNormal];
//        [fullTimeTableButton setTintColor:[AppManager systemGreenColor]];
//        [fullTimeTableButton addTarget:self action:@selector(showFullTimeTable:) forControlEvents:UIControlEventTouchUpInside];
//        
//        fullTimeTableButton.enabled = stopFetched;
//        
//        [view addSubview:fullTimeTableButton];
//    }
    
    UIView *topLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1000, 2)];
    topLineView.backgroundColor = [AppManager systemYellowColor];
    
    [view addSubview:topLineView];
//    view.backgroundColor = [UIColor colorWithWhite:1 alpha:1];
    
    return view;
}

#pragma mark - map methods
- (void)initializeLocation
{
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    [locationManager startUpdatingLocation];
    [locationManager requestWhenInUseAuthorization];
    
    mapView.showsBuildings = YES;
    mapView.pitchEnabled = YES;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    CLLocation *newLocation = [locations lastObject];
    
    if (currentUserLocation == nil && !skipUserLocation) {
        currentUserLocation = newLocation;
        [self centerMapRegionToCoordinate:currentUserLocation.coordinate];
        return;
    }
    
    skipUserLocation = NO;
    
    //    CLLocationDistance dist = [currentUserLocation distanceFromLocation:newLocation];
    //    if (dist > 10) {
    //        currentUserLocation = newLocation;
    //        [self centerMapRegionToCoordinate:currentUserLocation.coordinate];
    //    }
}

-(BOOL)centerMapRegionToCoordinate:(CLLocationCoordinate2D)coordinate{
    
    BOOL toReturn = YES;
    
    if (![self isLocationServiceAvailableWithNotification:NO]) {
        coordinate = kHslRegionCenter;
        toReturn = NO;
    }
    
    CGFloat spanSize = 0.005;
    
    MKCoordinateSpan span = {.latitudeDelta =  spanSize, .longitudeDelta =  spanSize};
    MKCoordinateRegion region = {coordinate, span};
    
    [mapView setRegion:region animated:YES];
    
    return toReturn;
}

-(BOOL)isLocationServiceAvailableWithNotification:(BOOL)notify{
    BOOL accessGranted = [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse;
    BOOL locationServicesEnabled = [CLLocationManager locationServicesEnabled];
    
    BOOL enabled = YES;
    NSString *errorString = nil;
    if (!locationServicesEnabled) {
        errorString = NSLocalizedString(@"Looks like location services is not enabled. Enable it from Settings.", nil);
        enabled = NO;
    }
    
    if (!accessGranted) {
        errorString = NSLocalizedString(@"Looks like access is not granted to this app for location services. Grant access from Settings.", nil);
        enabled = NO;
    }
    
    if (!enabled && notify) {
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Uh-Oh", nil)
                                                                       message:errorString
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Settings", nil) style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {
                                                                  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
                                                              }];
        
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleCancel
                                                            handler:nil];
        [alert addAction:okAction];
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
    return enabled;
}

- (void)plotBikeSations:(NSArray *)stations {
    for (id<MKAnnotation> annotation in mapView.annotations) {
        if ([annotation isKindOfClass:[ServicePointAnnotation class]]) {
            [mapView removeAnnotation:annotation];
        }
    }
    
    for (BikeStation *station in stations) {
        if (![station isValid]) continue;
        NSString * title = station.name;
        NSString * subTitle = [NSString stringWithFormat:@"%d bikes - %d spaces", station.bikesAvailable.intValue, station.spacesAvailable.intValue];
        CLLocationCoordinate2D coords = station.coordinates;
        
        ServicePointAnnotation *newAnnotation = [[ServicePointAnnotation alloc] initWithTitle:title andSubtitle:subTitle andCoordinate:coords];
        newAnnotation.code = station.stationId;
        newAnnotation.imageNameForView = @"bikeAnnotation";
        newAnnotation.annotIdentifier = @"bikeAnnotation";
        
        [mapView addAnnotation:newAnnotation];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)_mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    //    static NSString *selectedIdentifier = @"selectedLocation";
    if ([annotation isKindOfClass:[ServicePointAnnotation class]]) {
        ServicePointAnnotation *spAnnotation = (ServicePointAnnotation *)annotation;
        
        MKAnnotationView *annotationView = (MKAnnotationView *) [_mapView dequeueReusableAnnotationViewWithIdentifier:spAnnotation.annotIdentifier];
        if (annotationView == nil) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:spAnnotation.annotIdentifier];
            annotationView.enabled = YES;
            annotationView.canShowCallout = YES;
            
            NSString *imageName = spAnnotation.imageNameForView;
            annotationView.image = [UIImage imageNamed:imageName];
            
            UIButton *leftCalloutButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 55, 50)];
            [leftCalloutButton setImage:[UIImage imageNamed:@"rightArrow"] forState:UIControlStateNormal];
            UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(52, 0, 0.5, 50)];
            lineView.backgroundColor = [AppManager systemYellowColor];
            [leftCalloutButton addSubview:lineView];
            annotationView.leftCalloutAccessoryView = leftCalloutButton;
            
            [annotationView setFrame:CGRectMake(0, 0, 25, 37.5)];
            annotationView.centerOffset = CGPointMake(0,-12);
            
        } else {
            annotationView.annotation = annotation;
        }
        
        return annotationView;
    }
    
    return nil;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    id <MKAnnotation> annotation = [view annotation];
    if ([annotation isKindOfClass:[ServicePointAnnotation class]])
    {
        ServicePointAnnotation *spAnnotation = (ServicePointAnnotation *)annotation;
        MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:spAnnotation.coordinate addressDictionary:nil];
        MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
        [mapItem setName:spAnnotation.title];
        
        [self launchMapsAppForDirectionTo:mapItem];
    }
}

- (void)launchMapsAppForDirectionTo:(MKMapItem *)from{
    //    [from openInMapsWithLaunchOptions:nil];
    [MKMapItem openMapsWithItems:[NSArray arrayWithObject:from]
                   launchOptions:[NSDictionary dictionaryWithObjectsAndKeys:
                                  MKLaunchOptionsDirectionsModeWalking, MKLaunchOptionsDirectionsModeKey, nil]];
}

#pragma mark - Api methods
- (void)fetchAllBikeStations {
    [dataManager getBikeStationsWithCompletionHandler:^(NSArray *allStations, NSString *error){
        if (!error) {
            self.bikeStations = allStations;
            [self.tableView reloadData];
            //Plot annotations
            [self plotBikeSations:allStations];
        }
    }];
}

#pragma mark - IbActions
- (IBAction)currentLocationButtonTapped:(id)sender {
    if (![self isLocationServiceAvailableWithNotification:YES])
        return;
    
    if (mapView.userLocation.location != nil) {
        [self centerMapRegionToCoordinate:mapView.userLocation.location.coordinate];
    }
}

- (IBAction)startTimerButtonTapped:(id)sender {
    timerViewHeightConstraint.constant = timerViewHeightConstraint.constant == 60 ? 105 : 60;
    
    [UIView animateWithDuration:0.4 animations:^{
        timerLabel.font = [UIFont systemFontOfSize:timerViewHeightConstraint.constant == 60 ? 40 : 60 weight:UIFontWeightUltraLight]; // TODO: in completion
        [self.view layoutSubviews];
        [timerView layoutSubviews];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
