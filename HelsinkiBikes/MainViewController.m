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

CLLocationCoordinate2D kHslRegionCenter = {.latitude =  60.170163, .longitude =  24.941352};

@interface MainViewController ()

@property (nonatomic, strong)DataManager *dataManager;

@end

@implementation MainViewController
@synthesize dataManager;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    skipUserLocation = YES;
    dataManager = [[DataManager alloc] init];
    
    [self setupView];
    [self initializeMapComponents];
    [self fetchAllBikeStations];
}

- (void)setupView {
    
    [self setTitle:NSLocalizedString(@"HELSINKI ROUTES", nil)];
    
    currentLocationButton.layer.cornerRadius = 4.0;
    currentLocationButton.layer.borderWidth = 0.5;
    currentLocationButton.layer.borderColor = [AppManager systemYellowColor].CGColor;
    
}

#pragma mark - map methods
- (void)initializeMapComponents
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
    
    if (!locationServicesEnabled) {
        if (notify) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Uh-Oh", nil)
                                                                message:NSLocalizedString(@"Looks like location services is not enabled. Enable it from Settings.", nil)
                                                               delegate:self
                                                      cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                      otherButtonTitles:NSLocalizedString(@"Settings", nil), nil];
            alertView.tag = 2003;
            [alertView show];
        }
        
        return NO;
    }
    
    if (!accessGranted) {
        if (notify) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Uh-Oh", nil)
                                                                message:NSLocalizedString(@"Looks like access is not granted to this app for location services. Grant access from Settings.", nil)
                                                               delegate:self
                                                      cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                                      otherButtonTitles:NSLocalizedString(@"Settings", nil), nil];
            alertView.tag = 2003;
            [alertView show];
        }
        
        return NO;
    }
    
    return YES;
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
            [leftCalloutButton setImage:[UIImage imageNamed:@"goToLocation"] forState:UIControlStateNormal];
            annotationView.leftCalloutAccessoryView = leftCalloutButton;
            
            [annotationView setFrame:CGRectMake(0, 0, 30, 45)];
            annotationView.centerOffset = CGPointMake(0,-16);
            
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
