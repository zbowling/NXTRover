//
//  VideoGameKitRemoteConnection.h
//  SuperRover
//
//  Created by Zac Bowling on 3/5/11.
//  Copyright 2011 i'mhello. All rights reserved.
//
//@generate

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import "VideoController.h"

@interface GameKitRemoteConnection : NSObject<RemoteVideoConnnection,GKPeerPickerControllerDelegate,GKSessionDelegate> {
	//@privateProperties
	GKSession *gsession;
	GKPeerPickerController *gpicker;
	
	//@properties(assign)
	NSObject<RemoteVideoConnnectionDelegate> delegate;
}

@end
