//
//  NXTiPhoneAVCaptureAppDelegate.h
//  NXTiPhoneAVCapture
//
//  Created by Zac Bowling on 8/24/10.
//  Copyright i'mhello 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>

@interface NXTiPhoneAVCaptureAppDelegate : NSObject <UIApplicationDelegate,GKPeerPickerControllerDelegate,GKSessionDelegate> {
	AVCaptureVideoPreviewLayer *preview;
	AVCaptureSession *session;
	IBOutlet UIWindow *window;
	GKSession *gsession;
	GKPeerPickerController *gpicker;

}
@property (retain) GKSession *gsession;
@property (retain) GKPeerPickerController *gpicker;
@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) AVCaptureSession *session;

@end

