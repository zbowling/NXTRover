//
//  NXTiPhoneAVCaptureAppDelegate.m
//  NXTiPhoneAVCapture
//
//  Created by Zac Bowling on 8/24/10.
//  Copyright i'mhello 2010. All rights reserved.
//

#import "NXTiPhoneAVCaptureAppDelegate.h"

@implementation NXTiPhoneAVCaptureAppDelegate

@synthesize window, session, gsession, gpicker;
// Create and configure a capture session and start it running
- (void)setupCaptureSession 
{
    NSError *error = nil;
	
    // Create the session
    self.session = [[AVCaptureSession alloc] init];
	
    // Configure the session to produce lower resolution video frames, if your 
    // processing algorithm can cope. We'll specify medium quality for the
    // chosen device.
    session.sessionPreset = AVCaptureSessionPresetMedium;
	
    // Find a suitable AVCaptureDevice
    AVCaptureDevice *device = [AVCaptureDevice
							   defaultDeviceWithMediaType:AVMediaTypeVideo];
	
    // Create a device input with the device and add it to the session.
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device 
																		error:&error];
    if (!input) {
        // Handling the error appropriately.
    }
    [session addInput:input];
	
    // Create a VideoDataOutput and add it to the session
    AVCaptureVideoDataOutput *output = [[[AVCaptureVideoDataOutput alloc] init] autorelease];
    [session addOutput:output];
	
    // Configure your output.
    dispatch_queue_t queue = dispatch_queue_create("myQueue", NULL);
    [output setSampleBufferDelegate:self queue:queue];
    dispatch_release(queue);
	
    // Specify the pixel format
    output.videoSettings = 
	[NSDictionary dictionaryWithObject:
	 [NSNumber numberWithInt:kCVPixelFormatType_32BGRA] 
								forKey:(id)kCVPixelBufferPixelFormatTypeKey];
	
	
    // If you wish to cap the frame rate to a known value, such as 15 fps, set 
    // minFrameDuration.
    output.minFrameDuration = CMTimeMake(1, 10);
	
	
	preview = [AVCaptureVideoPreviewLayer layerWithSession:session];
	preview.frame = window.bounds;
	[window.layer addSublayer:preview];
    // Start the session running to start the flow of data
    [session startRunning];
	
}

// Delegate routine that is called when a sample buffer was written
- (void)captureOutput:(AVCaptureOutput *)captureOutput 
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer 
	   fromConnection:(AVCaptureConnection *)connection
{ 
    // Create a UIImage from the sample buffer data
	
	if (gsession != nil)
	{
		UIImage *image = [self imageFromSampleBuffer:sampleBuffer];
		image.
		[gsession sendDataToAllPeers:UIImageJPEGRepresentation(image,0.1f) withDataMode:GKSendDataUnreliable error:nil];
		[image release];
	}
	
	
}

- (void)peerPickerController:(GKPeerPickerController *)picker2 didConnectPeer:(NSString *)peerID toSession: (GKSession *) msession {
	// Use a retaining property to take ownership of the session.
    self.gsession = msession;
	// Assumes our object will also become the session's delegate.
    self.gsession.delegate = self;
    [msession setDataReceiveHandler:self withContext:nil];
	// Remove the picker.
    self.gpicker.delegate = nil;
    [self.gpicker dismiss];
    self.gpicker=nil;
}


// Create a UIImage from sample buffer data
- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer 
{
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer,0);
	
    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer); 
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer); 
    size_t height = CVPixelBufferGetHeight(imageBuffer); 
	
    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB(); 
    if (!colorSpace) 
    {
        NSLog(@"CGColorSpaceCreateDeviceRGB failure");
        return nil;
    }
	
    // Get the base address of the pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    // Get the data size for contiguous planes of the pixel buffer.
    size_t bufferSize = CVPixelBufferGetDataSize(imageBuffer); 
	
    // Create a Quartz direct-access data provider that uses data we supply
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, baseAddress, bufferSize, 
															  NULL);
    // Create a bitmap image from data supplied by our data provider
    CGImageRef cgImage = 
	CGImageCreate(width,
				  height,
				  8,
				  32,
				  bytesPerRow,
				  colorSpace,
				  kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrder32Little,
				  provider,
				  NULL,
				  true,
				  kCGRenderingIntentDefault);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
	
    // Create and return an image object representing the specified Quartz image
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
	
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
	
    return image;
}


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after application launch.
	
	[self setupCaptureSession];
	[self setupGameKit];
    [window makeKeyAndVisible];
	
	return YES;
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

- (void)peerPickerControllerDidCancel:(GKPeerPickerController *)picker
{
    self.gpicker.delegate = nil;
    // The controller dismisses the dialog automatically.
    self.gpicker = nil;
}

- (GKSession *)peerPickerController:(GKPeerPickerController *)picker sessionForConnectionType:(GKPeerPickerConnectionType)type
{
	NSString *nxtstring=@"nxtdriver";
	GKSession *msession = [[GKSession alloc] initWithSessionID:nxtstring displayName:@"Client" sessionMode:GKSessionModePeer];
	msession.delegate = self;
	msession.available = YES;
    return msession;
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
	
	self.session = nil;
	
    [window release];
    [super dealloc];
}


@end
