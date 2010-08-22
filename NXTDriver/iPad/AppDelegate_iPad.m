//
//  AppDelegate_iPad.m
//  NXTDriver
//
//  Created by Zac Bowling on 8/21/10.
//  Copyright i'mhello 2010. All rights reserved.
//

#import "AppDelegate_iPad.h"
#import "DriverUI.h"
@implementation AppDelegate_iPad

@synthesize window;
@synthesize driverUIController;


#pragma mark -
#pragma mark Application lifecycle
#define degreesToRadians(x) (M_PI * x / 180.0)

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    	
	//self.driverUIController = [[[DriverUI alloc] initWithNibName:@"DriverUI" bundle: [NSBundle mainBundle]] autorelease];
    // Override point for customization after application launch
	
	window.autoresizesSubviews = YES;

	[window addSubview:self.driverUIController.view];
	//window.rootViewController = self.driverUIController;
    [window makeKeyAndVisible];
	
	//[[UIDevice currentDevice] setOrientation: UIInterfaceOrientationLandscapeRight];
	return YES;
}

-(void) receivedRotate: (NSNotification*) notification
{
	UIDeviceOrientation interfaceOrientation = [[UIDevice currentDevice] orientation];
	
	if(interfaceOrientation != UIDeviceOrientationUnknown)
		[self deviceInterfaceOrientationChanged:interfaceOrientation];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     */
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
    [window release];
    [super dealloc];
}


@end
