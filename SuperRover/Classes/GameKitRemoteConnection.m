//
//  VideoGameKitRemoteConnection.m
//  SuperRover
//
//  Created by Zac Bowling on 3/5/11.
//  Copyright 2011 i'mhello. All rights reserved.
//

#import "GameKitRemoteConnection.h"


@implementation VideoGameKitRemoteConnection

-(id)init {
	if (self = [super init])
	{
		self.gpicker = [[[GKPeerPickerController alloc] init] autorelease];
		gpicker.connectionTypesMask = GKPeerPickerConnectionTypeNearby;
		gpicker.delegate = self;
	}
	return self;
}


- (BOOL) isConnected {
	
}

//@extern
- (void) beginConnectionSession {
	if (!self.connected)
	{
		[self.gpicker show];
	}
}


//@extern
- (void) endConnectionSession {
	
}


@end
