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
#import "BikeStationAnnotation.h"
#import "BikeStation.h"
#import "UIScrollView+APParallaxHeader.h"
#import <pop/POP.h>
#import "StringFormatter.h"
#import "SettingsManager.h"
#import "LocalNotificationManager.h"

CLLocationCoordinate2D kHslRegionCenter = {.latitude =  60.170163, .longitude =  24.941352};
const NSInteger kUpdateInterval = 30;

//#if DEBUG
//const NSInteger kCounterUpdateInterval = 1;
//const NSInteger kCounterSlowUpdateInterval = 60;
//const NSInteger kAllowedFreeTime = 5;
//const NSInteger kOneHourMark = 10;
//const NSInteger kTwoHourMark = 20;
//const NSInteger kMaxAllowedTime = 50;
//
//const NSInteger kChargableTimeUnit = 5;
//#else
const NSInteger kCounterUpdateInterval = 1;
const NSInteger kCounterSlowUpdateInterval = 60;
const NSInteger kAllowedFreeTime = 1800;
const NSInteger kOneHourMark = 3600;
const NSInteger kTwoHourMark = 7200;
const NSInteger kMaxAllowedTime = 18000;

const NSInteger kChargableTimeUnit = 1800;
//#endif

@interface MainViewController ()

@property (nonatomic, strong)DataManager *dataManager;
@property(nonatomic, strong)LocalNotificationManager *notificationManager;

@end

@implementation MainViewController
@synthesize dataManager;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    viewAppearedFirstTime = YES;
    
    skipUserLocation = YES;
    isTimerRunning = NO;
    totalExtraCharge = 0;
    tableViewInfoCellText = NSLocalizedString(@"LOADING...", nil);
    showRetryButton = NO;
    self.bikeStations = @[];
    dataManager = [[DataManager alloc] init];
    self.notificationManager = [LocalNotificationManager sharedManger];
    
    [self setupMainView];
    [self setupMapView];
    [self initializeLocation];
    [self fetchAllBikeStations];
    [self initUpdateTimer];
    [self setTimerViewMode:TimerViewModeCompact animated:NO];
//    [self testMoneyCalculation];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //Maybe prevents flickering at counter.
    [self updateTime];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (viewAppearedFirstTime)
        [self setupMapView];
    
    [self.tableView reloadData];
    
    viewAppearedFirstTime = NO;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self setupMapView];
}

- (void)setupMainView {
    [self setTitle:NSLocalizedString(@"HELSINKI BIKES", nil)];
    
    lastUpdateTimeLabel = [[UILabel alloc] init];
    lastUpdateTimeLabel.font = [UIFont systemFontOfSize:11];
    lastUpdateTimeLabel.textColor = [UIColor lightGrayColor];
}

- (void)setupMapView {
    //Never exceed half
    CGFloat halfView = self.view.frame.size.height/2;
    CGFloat maxPosible = self.view.frame.size.height - 250;
    CGFloat height = maxPosible > halfView ? halfView : maxPosible;
    [mapContainerView setFrame:CGRectMake(0, 0, self.view.frame.size.width, height)];
    
    CLLocationCoordinate2D coord = {.latitude =  60.1733239, .longitude =  24.9410248};
    [self centerMapRegionToCoordinate:coord];
    
    currentLocationButton.layer.cornerRadius = 4.0;
    currentLocationButton.layer.borderWidth = 0.5;
    currentLocationButton.layer.borderColor = [AppManager systemYellowColor].CGColor;
    
    [self.tableView addParallaxWithView:mapContainerView andHeight:height];
}

- (void)initUpdateTimer {
    updateTimer = [NSTimer scheduledTimerWithTimeInterval:kUpdateInterval target:self selector:@selector(updateStations:) userInfo:nil repeats:YES];
}

- (void)updateStations:(id)sender {
    [self fetchAllBikeStations];
}

#pragma mark - Timer view methods
- (void)setTimerViewMode:(TimerViewMode)viewMode animated:(BOOL)animated {
    CGFloat height = 0;
    CGFloat countDownCounterFont = 0;
    UIColor *buttonColor = [AppManager systemRedColor];
    NSString *buttonText = NSLocalizedString(@"END RIDE", nil);
    
    if (viewMode == TimerViewModeHidden) {
        height = 0;
        countDownCounterFont = 0;
        buttonColor = [AppManager systemGreenColor];
        buttonText = NSLocalizedString(@"START RIDE", nil);
        timerLabelBottomToInfoLabelConstraint.active = NO;
    } else if (viewMode == TimerViewModeCompact) {
        height = 60;
        countDownCounterFont = 40;
        buttonColor = [AppManager systemGreenColor];
        buttonText = NSLocalizedString(@"START RIDE", nil);
        timerLabelBottomToInfoLabelConstraint.active = NO;
    } else if(viewMode == TimerViewModeNormal) {
        height = 115;
        countDownCounterFont = 60;
        timerLabelBottomToInfoLabelConstraint.active = YES;
    } else {
        height = 115;
        countDownCounterFont = 30;
        NSAssert(NO, @"Should not reach here");
    }
    
    timerViewHeightConstraint.constant = height;
    timerLabel.font = [UIFont systemFontOfSize:countDownCounterFont weight:UIFontWeightUltraLight];
    
    //Animate size
    [self springAnimationWithDuration:animated?0.5:0 animation:^{
        [startRideButton setTitle:buttonText forState:UIControlStateNormal];
        [startRideButton setBackgroundColor:buttonColor];
        additionalInfoLabel.alpha = viewMode == TimerViewModeNormal ? 1.0 : 0.0;
        [self.view layoutSubviews];
        [timerView layoutSubviews];
    } completion:NULL];
    
    currentTimerViewMode = viewMode;
}

//-(void)makeFirstCellVisibleIfNot {
//    
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
//    if ([self.tableView.indexPathsForVisibleRows containsObject:indexPath]) {
//        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
//                              withRowAnimation:UITableViewRowAnimationFade];
//    }
//}

- (void)springAnimationWithDuration:(NSTimeInterval)duration animation:(ActionBlock)animation completion:(void (^ __nullable)(BOOL finished))completion {
    [UIView animateWithDuration:duration
                          delay:0
         usingSpringWithDamping:0.5
          initialSpringVelocity:1.1
                        options:0
                     animations:animation completion:completion];
}

#pragma mark - Time counting methods
-(BOOL)isTimerRunning {
    return isTimerRunning;
}
-(void)startTimer {
    if ([self isTimerRunning]) return;
    
    [self saveTimerStartTime:[NSDate date]];
    [self updateTime];
    counterTimer = [NSTimer scheduledTimerWithTimeInterval:kCounterUpdateInterval target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
    isTimerSlowUpdating = NO;
    
    isTimerRunning = YES;
    
    if (![self.notificationManager isLocalNotificationEnabled]) {
        [self.notificationManager registerNotification];
    } else {
        [self setNotificationForRunningTimer];
    }
    
    currentTimerMode = TimerModeInitial;
}

-(void)setNotificationForRunningTimer {
    if (isTimerRunning && timerStartTime) {
        if ([SettingsManager areNotificationsEnabled]) {
            [self.notificationManager setNotificationForDefaultTypeFromTime:timerStartTime];
        }
    }
}

-(void)endTimer {
    [counterTimer invalidate];
    timerLabel.text = [self prettyFormatTimeFromSeconds:kAllowedFreeTime];
    isTimerRunning = NO;
    [[LocalNotificationManager sharedManger] cancelAllNotification];
    currentTimerMode = TimerModeNotStarted;
}

-(void)saveTimerStartTime:(NSDate *)startTime {
    //This is where to save start time to defaults in case it needs to be persisted
    timerStartTime = startTime;
}

-(NSDate *)getTimerStartTime {
    return timerStartTime;
}

-(void)updateTime {
    if (!timerStartTime) {
        timerLabel.text = [self prettyFormatTimeFromSeconds:kAllowedFreeTime];
        return;
    }
    
    NSTimeInterval timeSinceStart = [[NSDate date] timeIntervalSinceDate:timerStartTime];
    additionalInfoLabel.attributedText = [self extraChargeStringForTime:timeSinceStart];
    
    if (timeSinceStart <= kAllowedFreeTime) {
        //Count down to kAllowedFreeTime
        NSTimeInterval remaining = kAllowedFreeTime - timeSinceStart;
        timerLabel.text = [self prettyFormatTimeFromSeconds:remaining];
    } else if (timeSinceStart <= kMaxAllowedTime) {
        //Count up
        currentTimerMode = TimerModeExtraTime;
        if (timeSinceStart > 3600 && !isTimerSlowUpdating) { //Slow timer down after one hour
            counterTimer = [NSTimer scheduledTimerWithTimeInterval:kCounterSlowUpdateInterval target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
            isTimerSlowUpdating = YES;
        }
        
        timerLabel.text = [NSString stringWithFormat:@"+%@", [self prettyFormatTimeFromSeconds:timeSinceStart - kAllowedFreeTime]];
    } else {
        timerLabel.text = [NSString stringWithFormat:@"+%@", [self prettyFormatTimeFromSeconds:kMaxAllowedTime - kAllowedFreeTime]];
        [counterTimer invalidate];
    }
    
}

-(NSString *)prettyFormatTimeFromSeconds:(NSInteger)totalSeconds {
    //1800,
    int seconds, minutes, hours;
    seconds = totalSeconds % 60;
    minutes = (totalSeconds/60) % 60;
    hours = (totalSeconds/3600) % 60;
    
    NSString *secondString = [NSString stringWithFormat:@"%d", seconds];
    if (seconds < 10) {
        secondString = [NSString stringWithFormat:@"0%d", seconds];
    }
    
    NSString *minuteString = [NSString stringWithFormat:@"%d", minutes];
    if (minutes < 10) {
        minuteString = [NSString stringWithFormat:@"0%d", minutes];
    }
    
    if (hours > 0) {
        return [NSString stringWithFormat:@"%dh %@", hours, minuteString];
    } else {
        return [NSString stringWithFormat:@"%@:%@", minuteString, secondString];
    }
}

-(NSAttributedString *)extraChargeStringForTime:(NSInteger)totalSeconds {
    double moneyAmount = [self moneyForSeconds:totalSeconds];
    
    if (moneyAmount == 0)
        return [[NSAttributedString alloc] initWithString:NSLocalizedString(@"NO EXTRA CHARGE", nil)];
    
    NSString *moneyString = [NSString stringWithFormat:@"€%@", [StringFormatter formatRoundedNumberFromDouble:moneyAmount roundDigits:1 androundUp:YES]];
    
    NSString *fullText = nil;
    if (totalSeconds < kMaxAllowedTime) {
        fullText = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"EXTRA CHARGE", nil), moneyString];
    } else {
        fullText = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"MAX TIME EXCEEDED. CHARGE", nil), moneyString];
    }
    
    UIFont *normalFont = [UIFont systemFontOfSize:14];
    UIFont *highlightedFont = [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold];
    
    
    return [StringFormatter highlightSubstringInString:fullText substring:moneyString normalFont:normalFont highlightedFont:highlightedFont hightlightColor:[AppManager systemRedColor]];
}

-(double)moneyForSeconds:(NSInteger)totalSeconds {
    double totalMoney = 0;
    NSInteger chargableSecs = totalSeconds - kAllowedFreeTime;
    if (chargableSecs < 0) return 0;
    
    if (totalSeconds <= kOneHourMark) { //Charge 0.5 per 30 min
        totalMoney = 0.5;
    } else if (totalSeconds > kOneHourMark && totalSeconds <= kTwoHourMark) { //Charge 1 per 30 min
        totalMoney = (totalSeconds - kOneHourMark) <= kChargableTimeUnit ? 0.5 + 1 : 0.5 + 2;
    } else if (totalSeconds > kTwoHourMark && totalSeconds < kMaxAllowedTime) { //Charge 2 per 30 min
        NSInteger numberOf30s = ((totalSeconds - kTwoHourMark)/kChargableTimeUnit) + 1;
        totalMoney = 0.5 + 2 + (numberOf30s * 2);
    } else {
        totalMoney = 0.5 + 2 + 12;
    }
    
    NSLog(@"%ld - %f - %f", (long)totalSeconds, (totalSeconds/60.0)/30.0, totalMoney);
    return totalMoney;
}

-(void)testMoneyCalculation {
    NSAssert([self moneyForSeconds:900] == 0, @"Wrong calc");
    NSAssert([self moneyForSeconds:1801] == 0.5, @"Wrong calc");
    NSAssert([self moneyForSeconds:3599] == 0.5, @"Wrong calc");
    NSAssert([self moneyForSeconds:4000] == 1.5, @"Wrong calc");
    NSAssert([self moneyForSeconds:7000] == 2.5, @"Wrong calc");
    NSAssert([self moneyForSeconds:7300] == 4.5, @"Wrong calc");
    NSAssert([self moneyForSeconds:9300] == 6.5, @"Wrong calc");
    NSAssert([self moneyForSeconds:11300] == 8.5, @"Wrong calc");
    NSAssert([self moneyForSeconds:13000] == 10.5, @"Wrong calc");
    NSAssert([self moneyForSeconds:14000] == 10.5, @"Wrong calc");
    NSAssert([self moneyForSeconds:15000] == 12.5, @"Wrong calc");
    NSAssert([self moneyForSeconds:16000] == 12.5, @"Wrong calc");
    NSAssert([self moneyForSeconds:17000] == 14.5, @"Wrong calc");
    NSAssert([self moneyForSeconds:20000] == 14.5, @"Wrong calc");
}

#pragma mark - table view methods
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.bikeStations.count > 0 ? self.bikeStations.count : 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.bikeStations.count > 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"bikeStationCell" forIndexPath:indexPath];
        BikeStation *station = self.bikeStations[indexPath.section];
        
        UIView *bikeImage = [cell viewWithTag:1001];
        UILabel *nameLabel = (UILabel *)[cell viewWithTag:1002];
        UILabel *distanceLabel = (UILabel *)[cell viewWithTag:1003];
        UILabel *bikesLabel = (UILabel *)[cell viewWithTag:1004];
        UILabel *spacesLabel = (UILabel *)[cell viewWithTag:1005];
        
        distanceLabel.hidden = !isLocationServiceAvailable;
        distanceLabel.text = [NSString stringWithFormat:@"%@m", [StringFormatter formatRoundedNumberFromDouble:station.distance roundDigits:0 androundUp:YES]];
        
        nameLabel.text = station.name.uppercaseString;
        nameLabel.textColor = station.bikesAvailable.intValue == 0 ? [UIColor lightGrayColor] : [UIColor blackColor];
        
        UIColor *availabilityColor = [self colorForBikeAvailability:station];
        bikeImage.tintColor = availabilityColor;
        
        UIFont *highlightFont = [UIFont systemFontOfSize:17 weight:UIFontWeightSemibold];
        UIFont *normalFont = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
        
        bikesLabel.attributedText = [StringFormatter highlightSubstringInString:station.bikesAvailableString substring:[station.bikesAvailable stringValue] normalFont:normalFont highlightedFont:highlightFont hightlightColor:availabilityColor];
        
        spacesLabel.attributedText = [StringFormatter highlightSubstringInString:station.spacesAvailableString substring:[station.spacesAvailable stringValue] normalFont:normalFont highlightedFont:highlightFont hightlightColor:[self colorForSpaceAvailability:station]];
        
        bikesLabel.clipsToBounds = YES;
        bikesLabel.layer.borderColor = [UIColor lightGrayColor].CGColor;
        bikesLabel.layer.cornerRadius = 2;
        
        spacesLabel.clipsToBounds = YES;
        spacesLabel.layer.borderColor = [UIColor lightGrayColor].CGColor;
        spacesLabel.layer.cornerRadius = 2;
        
        return cell;
    } else { //Show info cell
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"infoCell" forIndexPath:indexPath];
        
        UILabel *infoLabel = (UILabel *)[cell viewWithTag:1001];
        UIButton *retryButton = (UIButton *)[cell viewWithTag:1002];
        [retryButton setTitle:NSLocalizedString(@"RETRY", nil) forState:UIControlStateNormal];
        
        infoLabel.text = tableViewInfoCellText.uppercaseString;
        retryButton.hidden = !showRetryButton;
        return cell;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.bikeStations.count > 0 ? 90
                                       : showRetryButton ? 80 : 50;
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
    view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 110, 30)];
    titleLabel.font = [UIFont systemFontOfSize:14];
    titleLabel.textColor = [AppManager systemYellowColor];
    titleLabel.adjustsFontSizeToFitWidth = YES;
    if (section == 0) {
        titleLabel.text = [self isLocationServiceAvailableWithNotification:NO] ? NSLocalizedString(@"NEAR YOU", nil) : NSLocalizedString(@"ALL STATIONS", nil);
    }
    [view addSubview:titleLabel];
    
    [view addSubview:lastUpdateTimeLabel];
    
    lastUpdateTimeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [view addConstraints:[NSLayoutConstraint
                           constraintsWithVisualFormat:@"H:[label]-(15)-|"
                           options:NSLayoutFormatDirectionLeadingToTrailing
                           metrics:nil
                           views:@{@"label" :lastUpdateTimeLabel}]];
    [view addConstraints:[NSLayoutConstraint
                          constraintsWithVisualFormat:@"V:|[label]|"
                          options:NSLayoutFormatDirectionLeadingToTrailing
                          metrics:nil
                          views:@{@"label" :lastUpdateTimeLabel}]];
    [view layoutIfNeeded];
    
    lastUpdateTimeLabel.hidden = !lastUpdateTime;
    [self setLastUpdateTime];
    
    UIView *topLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2000, 2)];
    topLineView.backgroundColor = [AppManager systemYellowColor];
    
    [view addSubview:topLineView];
    
    return view;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.bikeStations.count < 1) return;
    
    BikeStation *station = self.bikeStations[indexPath.section];
    
    [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    
    [UIView animateWithDuration:0.2
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{[self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];}
                     completion:(void (^ __nullable)(BOOL finished))^ {
                         [self centerMapRegionToCoordinate:station.coordinates];
                         [self selectLocationAnnotationWithCode:station.stationId];
                     }];
    
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
    
    isLocationServiceAvailable = [self isLocationServiceAvailableWithNotification:NO];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    CLLocation *newLocation = [locations lastObject];
    isLocationServiceAvailable = YES;
    
    if (currentUserLocation == nil && !skipUserLocation) {
        currentUserLocation = newLocation;
        [self centerMapRegionToCoordinate:currentUserLocation.coordinate];
        self.bikeStations = [self evaluateDistanceAndSortStations:self.bikeStations];
        [self.tableView reloadData];
        return;
    }
    
    skipUserLocation = NO;
    
    CLLocationDistance dist = [currentUserLocation distanceFromLocation:newLocation];
    CLLocationDistance distTreshold = currentTimerMode == TimerModeNotStarted ? 100 : 25;
    if (dist > distTreshold) {
        currentUserLocation = newLocation;
        [self evaluateDistanceAndSortStations:self.bikeStations];
        [self.tableView reloadData];
        [self centerMapRegionToCoordinate:currentUserLocation.coordinate]; //TODO: Only center in ride mode.
    }
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
        if ([annotation isKindOfClass:[BikeStationAnnotation class]]) {
            [mapView removeAnnotation:annotation];
        }
    }
    
    for (BikeStation *station in stations) {
        if (![station isValid]) continue;
        NSString * title = station.name;
        NSString * subTitle = [NSString stringWithFormat:@"%@ - %@", station.bikesAvailableString, station.spacesAvailableString];
        CLLocationCoordinate2D coords = station.coordinates;
        
        BikeStationAnnotation *newAnnotation = [[BikeStationAnnotation alloc] initWithTitle:title andSubtitle:subTitle andCoordinate:coords];
        newAnnotation.code = station.stationId;
        NSString *annotImageName = [self stationAnnotionImageName:station];
        newAnnotation.imageNameForView = annotImageName;
        newAnnotation.annotIdentifier = annotImageName;
        
        [mapView addAnnotation:newAnnotation];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)_mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    //    static NSString *selectedIdentifier = @"selectedLocation";
    if ([annotation isKindOfClass:[BikeStationAnnotation class]]) {
        BikeStationAnnotation *spAnnotation = (BikeStationAnnotation *)annotation;
        
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
    if ([annotation isKindOfClass:[BikeStationAnnotation class]])
    {
        BikeStationAnnotation *spAnnotation = (BikeStationAnnotation *)annotation;
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

-(void)selectLocationAnnotationWithCode:(NSString *)code{
    for (id<MKAnnotation> annotation in mapView.annotations) {
        if ([annotation isKindOfClass:[BikeStationAnnotation class]]) {
            BikeStationAnnotation *sAnnot = (BikeStationAnnotation *)annotation;
            if ([sAnnot.code isEqualToString:code]) {
                [mapView selectAnnotation:annotation animated:YES];
            }
        }
    }
}

#pragma mark - Api methods
- (void)fetchAllBikeStations {
    [dataManager getBikeStationsWithCompletionHandler:^(NSArray *allStations, NSString *error){
        if (!error) {
            self.bikeStations = [self evaluateDistanceAndSortStations:allStations];
            //Plot annotations
            [self plotBikeSations:allStations];
            lastUpdateTime = [NSDate date];
        } else {
            tableViewInfoCellText = error;
            showRetryButton = YES;
        }
        
        [self.tableView reloadData];
    }];
    
    [self setLastUpdateTime];
}

-(void)setLastUpdateTime{
    if (!lastUpdateTime) return;
    if ([lastUpdateTime timeIntervalSinceNow] > -180) {
        lastUpdateTimeLabel.text = NSLocalizedString(@"UPDATED JUST NOW", nil);
    }else{
        lastUpdateTimeLabel.text = [NSString stringWithFormat:NSLocalizedString(@"LAST UPDATED %@", nil), [StringFormatter formatPrittyDate:lastUpdateTime]];
    }
    
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
    if ([self isTimerRunning]) {
        [self setTimerViewMode:TimerViewModeCompact animated:YES];
        [self endTimer];
    } else {
        [self setTimerViewMode:TimerViewModeNormal animated:YES];
        [self startTimer];
    }
}

- (IBAction)retryButtonTapped:(id)sender {
    UIButton *retryButton = (UIButton *)sender;
    
    [retryButton setTitle:NSLocalizedString(@"RETRYING...", nil) forState:UIControlStateNormal];
    [self fetchAllBikeStations];
}

#pragma mark - Bike station helpers
- (UIColor *)colorForBikeAvailability:(BikeStation *)bikeStation {
    if (bikeStation.bikeAvailability == NotAvailable) {
        return [UIColor lightGrayColor];
    } else if (bikeStation.bikeAvailability == LowAvailability) {
        return [AppManager systemYellowColor];
    } else {
        return [AppManager systemGreenColor];
    }
}

- (UIColor *)colorForSpaceAvailability:(BikeStation *)bikeStation {
    if (bikeStation.spaceAvailability == NotAvailable) {
        return [UIColor lightGrayColor];
    } else if (bikeStation.spaceAvailability == LowAvailability) {
        return [AppManager systemYellowColor];
    } else {
        return [AppManager systemGreenColor];
    }
}

- (NSString *)stationAnnotionImageName:(BikeStation *)bikeStation {
    if (bikeStation.bikeAvailability == NotAvailable) {
        return @"noBikeAnnotation";
    } else if (bikeStation.bikeAvailability == LowAvailability) {
        return @"lowAvailBikeAnnotation";
    } else {
        return @"highAvailBikeAnnotation";
    }
}

- (NSArray *)evaluateDistanceAndSortStations:(NSArray *)stations {
    if (!isLocationServiceAvailable && !currentUserLocation && !stations) { return stations; }
    
    for (BikeStation *station in stations) {
        CLLocation *stationLocation = [[CLLocation alloc] initWithLatitude:station.coordinates.latitude longitude:station.coordinates.longitude];
        CLLocationDistance dist = [currentUserLocation distanceFromLocation:stationLocation];
        station.distance = dist;
    }
    
    stations = [self sortStationsByDistance:stations];
    return stations;
}

- (NSArray *)sortStationsByDistance:(NSArray *)stations {
    NSArray *sortedArray = [stations sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        if ([a isKindOfClass:BikeStation.class] && [b isKindOfClass:BikeStation.class]) {
            double first = [(BikeStation*)a distance];
            double second = [(BikeStation*)b distance];
            
            if (first < second)
                return NSOrderedAscending;
            else if (first > second)
                return NSOrderedDescending;
        }
        
        return NSOrderedSame;
    }];
    
    return sortedArray;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
