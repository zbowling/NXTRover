//
//  DriverUI.h
//  NXTDriver
//
//  Created by Zac Bowling on 8/21/10.
//  Copyright 2010 i'mhello. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DriverUI : UIViewController {
	BOOL running;
	NSTimer *sendTimer;
	double ax;
	double ay;
	double az; 
}

- (IBAction) goButtonDown:(id)sender;
- (IBAction) goButtonUp:(id)sender;

@end
