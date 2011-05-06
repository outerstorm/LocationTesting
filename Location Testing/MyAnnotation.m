//
//  MyAnnotation.m
//  Location Testing
//
//  Created by Justin Storm on 5/4/11.
//  Copyright 2011 HealthMEDX. All rights reserved.
//

#import "MyAnnotation.h"


@implementation MyAnnotation

@synthesize coordinate;

- (id) initWithCoordinate:(CLLocationCoordinate2D)coord
{
    coordinate = coord;
    
    return self;
}

@end
