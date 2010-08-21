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
    NSButton *startButton;
    NSButton *stopButton;
    CHTTPServer *server;
}

@property (readwrite, nonatomic, assign) IBOutlet NSWindow *window;
@property (readwrite, nonatomic, assign) IBOutlet NSButton *startButton;
@property (readwrite, nonatomic, assign) IBOutlet NSButton *stopButton;
@property (readwrite, nonatomic, retain) CHTTPServer *server;

- (IBAction)start:(id)inSender;
- (IBAction)stop:(id)inSender;

@end
