//
//  StationsListViewController.m
//  CodeChallenge3
//
//  Created by Vik Denic on 10/16/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import "StationsListViewController.h"
#import "Parser.h"
#import "BikeStation.h"
#import <CoreLocation/CoreLocation.h>
#import "MapViewController.h"

@interface StationsListViewController () <UITabBarDelegate, UITableViewDataSource,UISearchBarDelegate, ParserDelegate,CLLocationManagerDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property Parser *parser;
@property NSMutableArray *bikeStations;
@property NSMutableArray *currentStations;
@property CLLocationManager *locationManager;
@property CLLocation *currentLocation;

@end

@implementation StationsListViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    [self startInitializations];
    [self.locationManager startUpdatingLocation];

}

//Start Initializations Method to make viewDidLoad easily to read.
- (void)startInitializations {
    self.parser = [Parser new];
    self.parser.delegate = self;
    self.bikeStations = [NSMutableArray new];
    self.currentStations = [NSMutableArray new];
    self.locationManager = [CLLocationManager new];
    [self.locationManager requestAlwaysAuthorization];
    self.locationManager.delegate = self;
}


- (void)viewWillAppear:(BOOL)animated
{
    [self.parser getDataFromBikeStationJSON];
}



#pragma mark - Parser Methods
//------------------------------ Parser Methods ------------------------------------------------

//Load the Bike Stations Array using the Parser
- (void)arrayLoadedWithBikeStations:(NSMutableArray *)bikeStations
{
    self.bikeStations = bikeStations;

    //Sort the array by distance from current location;
    self.currentStations = [self sortArrayByDistanceToCurrentLocation:self.bikeStations];

    [self.tableView reloadData];
}


#pragma mark - Search Bar Methods
//------------------------------ Search Bar Methods -------------------------------------------

//Search Bar Method that goes everytime the text inside it changes
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    self.currentStations = [NSMutableArray new];

    //If there is nothing inside the search bar, just load all bike stations
    if ([searchText isEqualToString:@""])
    {
        self.currentStations = [self sortArrayByDistanceToCurrentLocation:self.bikeStations];
    }
    //If there is something typed over there, just change the Current Stations Array with the ones that appears there.
    else
    {
        for (BikeStation *bikeStation in self.bikeStations)
        {
            if ([[bikeStation.name uppercaseString] containsString:[searchText uppercaseString]])
            {
                [self.currentStations addObject:bikeStation];
            }
        }
        self.currentStations = [self sortArrayByDistanceToCurrentLocation:self.currentStations];
    }
    [self.tableView reloadData];

}

#pragma mark - Location Manager Methods
//------------------------------ Location Manager Methods -------------------------------------

//Location Method to grab the location when it is changed;
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    for (CLLocation *location in locations)
    {
        if(location.verticalAccuracy < 1000 && location.horizontalAccuracy <1000)
        {

            self.currentLocation = location;
            [self.locationManager stopUpdatingLocation];


            break;
        }
    }
}



#pragma mark - UITableView

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return self.currentStations.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];

    BikeStation *bikeStation = [self.currentStations objectAtIndex:indexPath.row];

    cell.textLabel.text = bikeStation.name;
    //Show Available Bikes and Current Distance inside the detail text
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Available bikes: %i   Distance from here: %.f m",[bikeStation.availableBikes intValue],[self.currentLocation distanceFromLocation:[[CLLocation alloc]initWithLatitude:[bikeStation.latitude floatValue] longitude:[bikeStation.longitude floatValue]]]];


    //Based on how many bikes are left in a station considering the % of the total ones, shows red, yellow or green bikes.
    float division = [bikeStation.availableBikes floatValue] / [bikeStation.availableDocks floatValue];
    if (division == 0.0)
    {
        cell.imageView.image = [UIImage imageNamed:@"bikeRedImage"];
        cell.imageView.alpha = 0.4;
    }
    else if (division <= 0.2)
    {
        cell.imageView.image = [UIImage imageNamed:@"bikeRedImage"];
        cell.imageView.alpha = 1.0;
    }
    else if (division <= 0.6)
    {
        cell.imageView.image = [UIImage imageNamed:@"bikeYellowImage"];
        cell.imageView.alpha = 1.0;
    }
    else
    {
        cell.imageView.image = [UIImage imageNamed:@"bikeGreenImage"];
        cell.imageView.alpha = 1.0;
    }

 




    return cell;
}

#pragma mark Segue Methods
//------------------------------ Segue Methods -----------------------------------------------

//Segue Method set the currentBikeLocation and current Location to the other view controller
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    MapViewController *mapVC = segue.destinationViewController;

    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];

    mapVC.currentBikeStation = [self.currentStations objectAtIndex:indexPath.row];
    mapVC.currentLocation = self.currentLocation;
    
    
}

#pragma mark Helper Methods
//----------------------------- Helper Methods -------------------------------------------------
- (NSMutableArray *) sortArrayByDistanceToCurrentLocation :(NSMutableArray *)array
{
    array = [array sortedArrayUsingComparator:^NSComparisonResult(BikeStation *obj1, BikeStation *obj2) {


        CLLocation *location1 = [[CLLocation alloc]initWithLatitude:[obj1.latitude floatValue] longitude:[obj1.longitude floatValue]];
        CLLocation *location2 = [[CLLocation alloc]initWithLatitude:[obj2.latitude floatValue] longitude:[obj2.longitude floatValue]];

        CLLocationDistance distance1 = [self.currentLocation distanceFromLocation:location1];
        CLLocationDistance distance2 = [self.currentLocation distanceFromLocation:location2];

        if (distance1>distance2)
        {
            return NSOrderedDescending;
        }
        else if (distance2>distance1)
        {
            return NSOrderedAscending;
        }
        else
        {
            return NSOrderedSame;
        }
    }];
    return array;
}





@end
