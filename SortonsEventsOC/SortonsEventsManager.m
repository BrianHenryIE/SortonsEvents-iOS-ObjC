//
//  SortonsEventsManager.m
//  DublinTheatreOC
//
//  Created by Brian Henry on 15/02/2015.
//  Copyright (c) 2015 Sorton. All rights reserved.
//

#import "SortonsEventsManager.h"

#import "DiscoveredEventBuilder.h"
#import "DiscoveredEvent.h"
#import "SortonsEventsCommunicator.h"


@implementation SortonsEventsManager


- (void)fetchDiscoveredEvents{
    [self.communicator getDiscoveredEvents];
}


#pragma mark - SortonsEventsCommunicatorDelegate

- (void)receivedDiscoveredEventsJSON:(NSData *)objectNotation
{
    NSError *error = nil;
    NSArray *discoveredEvents = [DiscoveredEventBuilder discoveredEventsFromJSON:objectNotation error:&error];
    
    NSLog(@"receivedDiscoveredEventsJSON %lu", (unsigned long)discoveredEvents.count);
    
    
    if (error != nil) {
        [self.delegate fetchingDiscoveredEventsFailedWithError:error];
        
    } else {
        [self.delegate didReceiveDiscoveredEvents:discoveredEvents];
    }
}

- (void)fetchingDiscoveredEventsFailedWithError:(NSError *)error
{
    [self.delegate fetchingDiscoveredEventsFailedWithError:error];
}



@end
