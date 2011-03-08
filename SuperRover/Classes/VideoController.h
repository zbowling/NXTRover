//
//  VideoController.h
//  SuperRover
//
//  Created by Zac Bowling on 3/5/11.
//  Copyright 2011 i'mhello. All rights reserved.
//
//@generate

#import <UIKit/UIKit.h>
#import "VideoView.h"
@protocol VideoRemoteConnnectionDelegate;
@protocol VideoRemoteConnnection;


@interface VideoController : UIViewController<RemoteVideoConnnectionDelegate> {
	//@properties
	NSObject<RemoteVideoConnnection> *remoteConnection;
	NSObject<LocalVideoSource> *localVideoSource;
	VideoView *videoView;
}




@end


@protocol LocalVideoSourceDelegate

- (void) localVideoSourceStateChanged:(BOOL)capturing;
- (void) didReceiveLocalVideoData:(NSData*)data;

@end


@protocol LocalVideoSource : NSObject 
- (void) beginCaptureSession;
- (void) endCaptureSession;

@property (readonly,getter=isCapturingVideo) BOOL capturingVideo;

- (CALayer*) localPreviewLayer;

@end


@protocol VideoDecoder

- (NSData*) encodeVideoFrameData:(id)data;
- (id) decodeVideoFrameData:(id)data;

@end




@protocol RemoteVideoConnnectionDelegate : NSObject
- (void) connectionStateChanged:(BOOL)connected;
- (void) didReceiveIncomingVideoData:(NSData*)data;
- (void) outgoingVideoDataWasSent;
@end


@protocol RemoteVideoConnnection : NSObject

- (void) beginConnectionSession;
- (void) endConnectionSession;
- (void) pushOutgoingVideoData:(NSData*)data;

@property(readonly,getter=isConnected) BOOL connected;

@end


