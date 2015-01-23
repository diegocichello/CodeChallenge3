//
//  Parser.h
//  CodeChallenge3
//
//  Created by Diego Cichello on 1/23/15.
//  Copyright (c) 2015 Mobile Makers. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ParserDelegate <NSObject>

- (void) arrayLoadedWithBikeStations:(NSMutableArray *)bikeStations;

@end

@interface Parser : NSObject

-(void)getDataFromBikeStationJSON;

@property (nonatomic,weak) id <ParserDelegate> delegate;

@end
