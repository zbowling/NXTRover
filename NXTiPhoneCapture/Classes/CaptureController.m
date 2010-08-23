//
//  CaptureController.m
//  CapTest
//
//  Created by Zac Bowling on 8/22/10.
//  Copyright 2010 i'mhello. All rights reserved.
//

#import "CaptureController.h"
#import <QuartzCore/QuartzCore.h>
#import <GameKit/GameKit.h>
#import "CapTestAppDelegate.h"

@implementation CaptureController
@synthesize appdelegate;
/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	picker = [[UIImagePickerController alloc] init];
	picker.sourceType = UIImagePickerControllerSourceTypeCamera;  
	picker.showsCameraControls = NO;  
	picker.delegate = nil;
	picker.wantsFullScreenLayout = YES;
	[self.view addSubview:picker.view];
	self.view.backgroundColor = [UIColor blueColor];
	[NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(captureFrame) userInfo:nil repeats:YES];
}


- (void)captureFrame {
	UIGraphicsBeginImageContext(picker.view.bounds.size);
	UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    [window.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    NSData *data = UIImageJPEGRepresentation(image, 1.0f); // Change this to change image data size. (0.0->1.0 low->high quality)
	[[(CapTestAppDelegate *)appdelegate gsession] sendDataToAllPeers:data withDataMode:GKSendDataReliable error:nil];
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

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
