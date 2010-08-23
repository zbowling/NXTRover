//
//  DriverUI.h
//  NXTDriver
//
//  Created by Zac Bowling on 8/21/10.
//  Copyright 2010 i'mhello. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>
#define SESSION_ID @"nxtdriver"

@interface DriverUI : UIViewController<GKPeerPickerControllerDelegate,GKSessionDelegate> {
	BOOL running;
	NSTimer *sendTimer;
	double ax;
	double ay;
	double az; 
	IBOutlet UILabel *speedLabel;
	IBOutlet UILabel *leftLabel;
	IBOutlet UILabel *rightLabel;
	GKSession *mSession;
	IBOutlet UISwitch *switchContol;
	IBOutlet UIImageView *imageView;
}
@property (nonatomic, retain) IBOutlet UILabel* speedLabel;
@property (nonatomic, retain) IBOutlet UILabel* leftLabel;
@property (nonatomic, retain) IBOutlet UILabel* rightLabel;
@property (nonatomic, retain) IBOutlet UIImageView *imageView;
- (IBAction) goButtonDown:(id)sender;
- (IBAction) goButtonUp:(id)sender;
- (IBAction) hostingSwitch:(id)sender;

@property (retain) GKSession *mSession;
@end
