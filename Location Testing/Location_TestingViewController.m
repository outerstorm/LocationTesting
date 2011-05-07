//
//  Location_TestingViewController.m
//  Location Testing
//
//  Created by Justin Storm on 5/3/11.
//  Copyright 2011 HealthMEDX. All rights reserved.
//

#import "Location_TestingViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "MyAnnotation.h"

@interface Location_TestingViewController(private)
    -(void) startSignificantChangeTracking;
    -(void) logLocation:(CLLocation *)currentLocation forDateTime:(NSDate *)eventDate;
    -(void) updateUILocation;
@end

@implementation Location_TestingViewController

- (void)dealloc
{
    [latitudeLabel release], latitudeLabel=nil;
    [longitudeLabel release], longitudeLabel=nil;
    [eventDateLabel release], eventDateLabel=nil;
    [mapView release], mapView=nil;
    
    if (locationManager) {
        [locationManager release], locationManager=nil;
    }
    if (lastLocation) {
        [lastLocation release], lastLocation=nil;
    }
    if (lastEventDate) {
        [lastEventDate release], lastEventDate=nil;
    }
    if (conn) {
        [conn release], conn=nil;
    }
    
    [super dealloc];
    
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    lastLocation=nil;
    lastEventDate=nil;
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    [locationManager startUpdatingLocation];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void) viewWillAppear:(BOOL)animated {
    [self updateUILocation];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void) startSignificantChangeTracking {
    sigChangeTrackingOn=YES;
    [locationManager startMonitoringSignificantLocationChanges];
}

// Delegate method from the CLLocationManagerDelegate protocol.
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    // If it's a relatively recent event, turn off updates to save power
    NSDate* eventDate = newLocation.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (abs(howRecent) < 60.0)
    {
        NSLog(@"latitude %+.6f, longitude %+.6f\n",
              newLocation.coordinate.latitude,
              newLocation.coordinate.longitude);

        [self logLocation:newLocation forDateTime:eventDate];
        
        if (!sigChangeTrackingOn) {
            [locationManager stopUpdatingLocation];
            [self startSignificantChangeTracking];
        }
    }
    // else skip the event and process the next one.
}

-(void) updateUILocation {
    if (lastLocation && lastEventDate) {
        latitudeLabel.text = [NSString stringWithFormat:@"%+.6f", lastLocation.coordinate.latitude];
        longitudeLabel.text = [NSString stringWithFormat:@"%+.6f", lastLocation.coordinate.longitude];
        
        NSDateFormatter *formatter = [NSDateFormatter new];
        [formatter setDateStyle:NSDateFormatterShortStyle];
        [formatter setTimeStyle:NSDateFormatterMediumStyle];
        [formatter setDoesRelativeDateFormatting:NO];
        eventDateLabel.text = [formatter stringFromDate:lastEventDate];
        [formatter release], formatter=nil;                
        
        
        MKCoordinateRegion region;
        region.center = lastLocation.coordinate;
        
        //Set Zoom level using Span
        MKCoordinateSpan span;
        span.latitudeDelta = 0.015;
        span.longitudeDelta = 0.015;
        region.span = span;
        // Set the region here... but I want this to be a dynamic size
        // Obviously this should be set after I've added my annotations
        mapView.hidden=NO;
        mapView.mapType=MKMapTypeStandard;
        mapView.scrollEnabled=YES;
        mapView.zoomEnabled=YES;
        mapView.showsUserLocation=YES;
        [mapView setRegion:region animated:YES];
        
        //add the point
        [mapView removeAnnotations:mapView.annotations];
        MyAnnotation *a = [[MyAnnotation alloc] initWithCoordinate:lastLocation.coordinate];
        [mapView addAnnotation:a];
        [a release], a=nil;
    }
}

-(void) logLocation:(CLLocation *)currentLocation forDateTime:(NSDate *)eventDate {
    if (lastLocation) {
        if (lastLocation.coordinate.latitude==currentLocation.coordinate.latitude && lastLocation.coordinate.longitude==currentLocation.coordinate.longitude) {
            return;
        }
        
        [lastLocation release], lastLocation=nil;
    }
    if (lastEventDate) {
        [lastEventDate release], lastEventDate=nil;
    }
    
    lastLocation = [currentLocation copy];
    lastEventDate = [eventDate copy];
    
    NSString *deviceId = [[UIDevice currentDevice] uniqueIdentifier];
    NSString *latitude = [NSString stringWithFormat:@"%+.6f", currentLocation.coordinate.latitude];
    NSString *longitude = [NSString stringWithFormat:@"%+.6f", currentLocation.coordinate.longitude];
    NSString *urlStr = @"http://morning-planet-377.heroku.com/locations";
    NSURL *url = [NSURL URLWithString:urlStr];
    
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    NSString *data = [NSString stringWithFormat:@"location[deviceid]=%@&location[lat]=%@&location[long]=%@&commit=add", deviceId, latitude, longitude];
	NSData *reqData = [NSData dataWithBytes:[data UTF8String] length:[data lengthOfBytesUsingEncoding:NSUTF8StringEncoding]];
	
	//---set the HTTP method---
    [req setHTTPMethod:@"POST"];
	[req setHTTPBody:reqData];

    conn = [[NSURLConnection alloc] initWithRequest:req delegate:self];
    
    [self performSelectorOnMainThread:@selector(updateUILocation) withObject:nil waitUntilDone:NO];
}

-(void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"Response: %i", [((NSHTTPURLResponse *)response) statusCode]);
}

-(void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Error: %@", error);
}

@end
