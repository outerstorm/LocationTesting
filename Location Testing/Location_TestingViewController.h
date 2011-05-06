//
//  Location_TestingViewController.h
//  Location Testing
//
//  Created by Justin Storm on 5/3/11.
//  Copyright 2011 HealthMEDX. All rights reserved.
// Edited by Andy S.



#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface Location_TestingViewController : UIViewController
    <CLLocationManagerDelegate> {
    
    IBOutlet UILabel *latitudeLabel;
    IBOutlet UILabel *longitudeLabel;
    IBOutlet UILabel *eventDateLabel;
    IBOutlet MKMapView *mapView;
        
@private
    BOOL sigChangeTrackingOn;
    CLLocationManager *locationManager;
    NSURLConnection *conn;	 
    CLLocation  *lastLocation;
    NSDate *lastEventDate;    
}

@end
