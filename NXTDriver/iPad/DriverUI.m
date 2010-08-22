//
//  DriverUI.m
//  NXTDriver
//
//  Created by Zac Bowling on 8/21/10.
//  Copyright 2010 i'mhello. All rights reserved.
//

#import "DriverUI.h"
#import "NXTClient.h"

@implementation DriverUI

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

#define kAccelerometerFrequency        10.0 //Hz
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	running = NO;
	//motionManager = [[CMMotionManager alloc] init]; // motionManager is an instance variable
//	[motionManager startAccelerometerUpdatesToQueue:[NSOperationQueue currentQueue]
//                               withHandler: ^(CMAccelerometerData *accelData, NSError *error)
//	{
//		ax = accelData.acceleration.x;
//		ay = accelData.acceleration.y;
//		az = accelData.acceleration.z;
//		 NSLog(@"accel data = [%f, %f, %f]",  accelData.acceleration.x,  accelData.acceleration.y,  accelData.acceleration.z);
//	}];
	
	UIAccelerometer*  theAccelerometer = [UIAccelerometer sharedAccelerometer];
    theAccelerometer.updateInterval = 1 / kAccelerometerFrequency;
	
    theAccelerometer.delegate = self;
	
	sendTimer = [NSTimer scheduledTimerWithTimeInterval:4.0 target:self selector:@selector(moveCar) userInfo:nil repeats:YES];
	
}

#define kFilteringFactor 0.1
- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
	ax =  acceleration.x;//(acceleration.x * kFilteringFactor) + (ax * (1.0 - kFilteringFactor));
    ay =  acceleration.y;//(acceleration.y * kFilteringFactor) + (ay * (1.0 - kFilteringFactor));
    az =  acceleration.z;//(acceleration.z * kFilteringFactor) + (az * (1.0 - kFilteringFactor));
	NSLog(@"accel data = [%f, %f, %f]",  acceleration.x,  acceleration.y,  acceleration.z);
    // Do something with the values.
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)moveCar {
	SInt8 left, right;
	if (running)
	{
		if (ay < 0)
		{
			left = 50;
			right = 50 - (ay * -50.0);
		}
		else {
			left = 50 - (ay * 50.0);
			right = 50;
		}
	}
	else {
		if (ay < 0)
		{
			left = ay * 50;
			right = ay * -50;
		}
		else {
			left = ay * -50;
			right = ay * 50;
		}
	}

		
	@try {
		[NXTClient sendGoMessage:@"192.168.90.228" left:left right:right];
	}
	@catch ( NSException *e ) {
		NSLog (@"The exception is:\n name: %@\nreason: %@"
			   , [e name], [e reason]);
	}
	
}

- (void)viewDidUnload {
	running = NO;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (IBAction) goButtonDown:(id)sender {
	running = YES;
	
}

- (IBAction) goButtonUp:(id)sender {
	running = NO;
}


- (void)dealloc {
    [super dealloc];
}


@end
