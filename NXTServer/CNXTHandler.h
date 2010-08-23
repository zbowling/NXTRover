//
//  CNXTHandler.h
//  NXTServer
//
//  Created by Jonathan Wight on 08/21/10.
//  Copyright 2010 toxicsoftware.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "CHTTPRequestHandler.h"

@class NXT;

@interface CNXTHandler : NSObject <CHTTPRequestHandler> {
    NXT *nxt;
	SInt8 al,ar,as;
	UInt16 tick;
	NSTimer *timer; 
}

@end
