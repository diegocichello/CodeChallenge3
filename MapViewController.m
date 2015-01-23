//
//  MapViewController.m
//  CodeChallenge3
//
//  Created by Vik Denic on 10/16/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import "MapViewController.h"
#import <MapKit/MapKit.h>

@interface MapViewController () <MKMapViewDelegate>

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property CLLocationCoordinate2D bikeStationCoordinate;
@property UIAlertView *alert;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mapView.delegate = self;



    self.bikeStationCoordinate = CLLocationCoordinate2DMake([self.currentBikeStation.latitude floatValue], [self.currentBikeStation.longitude floatValue]);


    self.mapView.showsUserLocation = YES;
    [self makePinInLocationWithLatitude:[self.currentBikeStation.latitude floatValue] longitude:[self.currentBikeStation.longitude floatValue] title:self.currentBikeStation.name];

    MKCoordinateSpan span = MKCoordinateSpanMake(0.05, 0.05);
    MKCoordinateRegion region = MKCoordinateRegionMake(self.bikeStationCoordinate, span);
    [self.mapView setRegion:region animated:true];




}

- (void) makePinInLocationWithLatitude:(float)latitude longitude:(float)longitude title:(NSString *)title
{
    MKPointAnnotation *point = [MKPointAnnotation new];
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(latitude,longitude);
    point.coordinate = coordinate;
    point.title = title;
    [self.mapView addAnnotation:point];

}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKPinAnnotationView *pin = [[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:nil];
    if (annotation == mapView.userLocation)
    {
            return nil;
    }
    else

    {
        pin.image = [UIImage imageNamed:@"bikeImage"];
    }
    pin.canShowCallout = YES;

    pin.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];


    return pin;
    
}



- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    self.alert = [UIAlertView new];
    self.alert.title = [NSString stringWithFormat:@"How to get to %@",self.currentBikeStation.name];
    [self.alert addButtonWithTitle:@"OK"];
    [self getDirectionsToBikeStationClicked];


}

-(void)getDirectionsToBikeStationClicked
{


    MKDirectionsRequest *request = [MKDirectionsRequest new];


    request.source = [MKMapItem mapItemForCurrentLocation];

    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:self.bikeStationCoordinate addressDictionary:nil];


    request.destination = [[MKMapItem alloc] initWithPlacemark:placemark];




    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];


    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        NSArray *routes = response.routes;
        MKRoute *route = routes.firstObject;


        int x =1;
        NSMutableString *directionsString = [NSMutableString string];
        for (MKRouteStep *step in route.steps)
        {
            [directionsString appendFormat:@"%d: %@\n", x, step.instructions];
            x++;
        }


        self.alert.message= directionsString;
        [self.alert show];
    }];


        
        
        
        

    
    
}



@end
