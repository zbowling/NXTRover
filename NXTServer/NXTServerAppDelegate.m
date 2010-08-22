//
//  NXTServerAppDelegate.m
//  NXTServer
//
//  Created by Jonathan Wight on 08/21/10.
//  Copyright 2010 toxicsoftware.com. All rights reserved.
//

#import "NXTServerAppDelegate.h"

#import "CHTTPServer.h"
#import "CNXTHandler.h"
#import "CTCPSocketListener_Extensions.h"

@implementation NXTServerAppDelegate

@synthesize window;
@synthesize startButton;
@synthesize stopButton;
@synthesize server;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	
}

- (IBAction)start:(id)inSender
{
CHTTPServer *theHTTPServer = [[[CHTTPServer alloc] init] autorelease];
[theHTTPServer createDefaultSocketListener];

CNXTHandler *theNXTHandler = [[[CNXTHandler alloc] init] autorelease];
[theHTTPServer.defaultRequestHandlers addObject:theNXTHandler];

NSError *theError = NULL;
[theHTTPServer.socketListener start:&theError];

self.server = theHTTPServer;

[self.startButton setEnabled:NO];
[self.stopButton setEnabled:YES];
}

- (IBAction)stop:(id)inSender
{
[self.server.socketListener stop];
self.server = NULL;

[self.startButton setEnabled:YES];
[self.stopButton setEnabled:NO];
}


@end
