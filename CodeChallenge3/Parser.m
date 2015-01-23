//
//  Parser.m
//  CodeChallenge3
//
//  Created by Diego Cichello on 1/23/15.
//  Copyright (c) 2015 Mobile Makers. All rights reserved.
//

#import "Parser.h"
#import "BikeStation.h"

@implementation Parser

-(void)getDataFromBikeStationJSON
{

    NSMutableArray * bikeStations = [[NSMutableArray alloc] init];
    //create connection using public
    NSURL * url = [NSURL URLWithString:@"http://www.bayareabikeshare.com/stations/json"];
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {

        NSDictionary * jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSArray * jsonArray = [jsonDictionary objectForKey:@"stationBeanList"];
        for (NSDictionary * jsonData in jsonArray )
        {
            BikeStation *bikeStation = [BikeStation new];

            bikeStation.id = jsonData[@"id"];
            bikeStation.name = jsonData[@"stationName"];
            bikeStation.availableDocks = jsonData[@"availableDocks"];
            bikeStation.totalDocks = jsonData[@"totalDocks"];
            bikeStation.availableBikes = jsonData[@"availableBikes"];
            bikeStation.latitude = jsonData[@"latitude"];
            bikeStation.longitude = jsonData[@"longitude"];
            bikeStation.stAddress1 = jsonData[@"stAddress1"];
            bikeStation.stAddress2 = jsonData[@"stAddress2"];
            bikeStation.location= jsonData[@"location"];
            bikeStation.city = jsonData[@"city"];

            [bikeStations addObject:bikeStation];

        }
        [self.delegate arrayLoadedWithBikeStations:bikeStations];
        
    }];
}

@end
