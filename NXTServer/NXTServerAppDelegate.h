//
//  NXTServerAppDelegate.h
//  NXTServer
//
//  Created by Jonathan Wight on 08/21/10.
//  Copyright 2010 toxicsoftware.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class CHTTPServer;

@interface NXTServerAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
    CHTTPServer *server;
}

@property (assign) IBOutlet NSWindow *window;
@property (readwrite, nonatomic, retain) CHTTPServer *server;

- (IBAction)start:(id)inSender;

@end
