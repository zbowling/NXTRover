//
//  CapTestAppDelegate.h
//  CapTest
//
//  Created by Max Weisel on 8/21/10.
//  Copyright Develoe 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>
#import "CaptureController.h"
@interface CapTestAppDelegate : NSObject <UIApplicationDelegate,GKPeerPickerControllerDelegate,GKSessionDelegate> {
    UIWindow *window;
	GKSession *gsession;
	GKPeerPickerController *gpicker;
	IBOutlet CaptureController *captureController;
	UIImagePickerController *picker;
	
}
@property (retain) CaptureController *captureController;
@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (retain) GKSession *gsession;
@property (retain) GKPeerPickerController *gpicker;
@end

