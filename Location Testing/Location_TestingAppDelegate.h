//
//  Location_TestingAppDelegate.h
//  Location Testing
//
//  Created by Justin Storm on 5/3/11.
//  Copyright 2011 HealthMEDX. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Location_TestingViewController;

@interface Location_TestingAppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet Location_TestingViewController *viewController;

@end
