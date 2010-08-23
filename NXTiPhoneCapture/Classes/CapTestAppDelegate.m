//
//  CapTestAppDelegate.m
//  CapTest
//
//  Created by Max Weisel on 8/21/10.
//  Copyright Develoe 2010. All rights reserved.
//

#import "CapTestAppDelegate.h"
#import <QuartzCore/QuartzCore.h>

@implementation CapTestAppDelegate

@synthesize window, gsession, gpicker, captureController;


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

	[self performSelector:@selector(setupGameKit) withObject:nil afterDelay:1.0];
	return YES;
}


- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state {
	NSLog(@"Session: %@, Peer: %@, State: %i", session, peerID, state);
}

- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID {
	
}

- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error {
	
}

- (void)session:(GKSession *)session didFailWithError:(NSError *)error {
	NSLog(@"ERROR");
}

- (void)setupGameKit {
	self.gpicker = [[[GKPeerPickerController alloc] init] autorelease];
	self.gpicker.connectionTypesMask = GKPeerPickerConnectionTypeNearby;
	self.gpicker.delegate = self;
	[self.gpicker show];
	//
}


- (void) receiveData:(NSData *)data fromPeer:(NSString *)peer inSession: (GKSession *)session context:(void *)context
{
	NSLog(@"%@ %@",peer, data);
}




- (void)captureFrame {
	CGImageRef screen = UIGetScreenImage();
	UIImage *image = [[UIImage alloc] initWithCGImage:screen];
	[gsession sendDataToAllPeers:UIImageJPEGRepresentation(image,0.1f) withDataMode:GKSendDataReliable error:nil];
	/*UIGraphicsBeginImageContext(picker.view.bounds.size);
    [picker.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = [[UIImage alloc] initWithData:];
	NSLog(@"IMAGE: %@", image);UIImageJPEGRepresentation
    NSData *data = [UIImagePNGRepresentation(image) retain]; // Change this to change image data size. (0.0->1.0 low->high quality)
	[gsession sendDataToAllPeers:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"http://cdn0.knowyourmeme.com/i/1122/original/xzibit-happy.jpg"]] withDataMode:GKSendDataReliable error:nil];
	[data release];*/
}

- (void)peerPickerController:(GKPeerPickerController *)picker2 didConnectPeer:(NSString *)peerID toSession: (GKSession *) session {
	NSLog(@"DISMIESS!!!");
	// Use a retaining property to take ownership of the session.
    self.gsession = session;
	// Assumes our object will also become the session's delegate.
    self.gsession.delegate = self;
    [session setDataReceiveHandler:self withContext:nil];
	// Remove the picker.
    self.gpicker.delegate = nil;
    [self.gpicker dismiss];
    self.gpicker=nil;
	
	picker = [[UIImagePickerController alloc] init];
	picker.sourceType = UIImagePickerControllerSourceTypeCamera;  
	picker.showsCameraControls = NO;  
	picker.delegate = nil;
	picker.wantsFullScreenLayout = YES;
	[window addSubview:picker.view];
	[NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(captureFrame) userInfo:nil repeats:YES];
	
	// Start your game.
	[window makeKeyAndVisible];
}


- (void)peerPickerControllerDidCancel:(GKPeerPickerController *)picker
{
    self.gpicker.delegate = nil;
    // The controller dismisses the dialog automatically.
    self.gpicker = nil;
}

- (GKSession *)peerPickerController:(GKPeerPickerController *)picker sessionForConnectionType:(GKPeerPickerConnectionType)type
{
	NSString *nxtstring=@"nxtdriver";
	GKSession *session = [[GKSession alloc] initWithSessionID:nxtstring displayName:@"Client" sessionMode:GKSessionModePeer];
	session.delegate = self;
	session.available = YES;
    return session;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
	[self.gsession disconnectFromAllPeers];
	self.gsession.available = NO;
	[self.gsession setDataReceiveHandler: nil withContext: nil];
	self.gsession.delegate = nil;
	self.gsession = nil;
	
    [window release];
    [super dealloc];
}


@end
