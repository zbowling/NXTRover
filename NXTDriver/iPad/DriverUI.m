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
@synthesize leftLabel, rightLabel, speedLabel, mSession, imageView;

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
	
	sendTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(moveCar) userInfo:nil repeats:YES];
	
	imageView.transform = CGAffineTransformRotate(imageView.transform, 1*(M_PI / 2.0));
}

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{

}

- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
}

#define kFilteringFactor 0.1
- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
	ax =  acceleration.x; //(acceleration.x * kFilteringFactor) + (ax * (1.0 - kFilteringFactor));
    ay =  acceleration.y; //(acceleration.y * kFilteringFactor) + (ay * (1.0 - kFilteringFactor));
    az =  acceleration.z; //(acceleration.z * kFilteringFactor) + (az * (1.0 - kFilteringFactor));
	//NSLog(@"accel data = [%f, %f, %f]",  acceleration.x,  acceleration.y,  acceleration.z);
    // Do something with the values.
}



// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)moveCar {
	SInt8 left, right;
	/*if (running)
	{
		if (ay > 0)
		{
			left = 50;
			right = 50 - (ay * -50.0);
		}
		else {
			left = 50 - (ay * 50.0);
			right = 50;
		}
	}
	else {*/
#define MAXVIDEO 
	double speed = ax * 100.0;
	if (ax>0.1 || ax < -0.1) {
		if (ay > 0)
		{
			left = speed;
			right = (1.0 - fabs(ay)) * speed;
		}
		else {
			left = (1.0 - fabs(ay)) * speed;
			right = speed;
		}
	}
	else {
		if (ay > 0)
		{
			left = speed;
			right = speed - (ay * -100.0);
		}
		else {
			left = speed - (ay * 100.0);
			right = speed;
		}
	}
	
	speedLabel.text = [NSString stringWithFormat:@"%d",speed];
	leftLabel.text = [NSString stringWithFormat:@"%d",left];
	rightLabel.text = [NSString stringWithFormat:@"%d",right];
	
	//}
//	if (running)
//		NSLog(@"running: running\nleft: %d\nright:%d",left,right);
//	else
//		NSLog(@"running: not running\nleft: %d\nright:%d",left,right);
		
	@try {
		[NXTClient sendGoMessage:@"10.0.2.1" left:left right:right shoot:0];
	}
	@catch ( NSException *e ) {
		NSLog (@"The exception is:\n name: %@\nreason: %@"
			   , [e name], [e reason]);
	}
	
	
}

- (IBAction) hostingSwitch:(id) sender {
	if (switchContol.on)
	{
		self.mSession = [[GKSession alloc] initWithSessionID:SESSION_ID displayName:@"NXTDriverIPAD" sessionMode:GKSessionModePeer];
		self.mSession.delegate = self;
		self.mSession.available = YES;
		[self.mSession setDataReceiveHandler:self withContext:nil];
	}
	else {
		self.mSession.available = NO;
		//[self.mSession disconnectFromAllPeers];
		//self.mSession = nil;
	}

	
}


- (void) receiveData:(NSData *)data fromPeer:(NSString *)peer inSession: (GKSession *)session context:(void *)context {
	NSLog(@"Receive: %@", [UIImage imageWithData:data]);
	
	imageView.image = [UIImage imageWithData:data];
}

- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID {
	[self.mSession acceptConnectionFromPeer:peerID error:nil];
	NSLog(@"session didReceiveConnectionRequestFromPeer %@",peerID);
}

- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state {
	NSLog(@"session didChangeState %d %@",state,peerID);
}

- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error {
	NSLog(@"session connectionWithPeerFailed %@",peerID);
}

- (void)session:(GKSession *)session didFailWithError:(NSError *)error {
	NSLog(@"session didFailWithError %@",error);
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
	@try {
		[NXTClient sendGoMessage:@"10.0.2.1" left:0 right:0 shoot:1];
	}
	@catch ( NSException *e ) {
		NSLog (@"The exception is:\n name: %@\nreason: %@"
			   , [e name], [e reason]);
	}
	
}


- (void)dealloc {
    [super dealloc];
}


@end
