/* $Id: LegoNXTRemote.h 17 2009-02-01 01:18:33Z querry43 $ */

/*! \file LegoNXTRemote.h
* This file describes a graphical interface for the LegoNXT Framework.
*
* \author Matt Harrington
* \date 01/04/09
*/

#import <Cocoa/Cocoa.h>
#import <LegoNXT.h>

@interface LegoNXTRemote : NSObject
{
    NXT *_nxt;
    
    IBOutlet NSLevelIndicator *batteryLevelIndicator;
    IBOutlet NSTextField *connectMessage;
    
    IBOutlet NSButton *connectButton;
    
    IBOutlet NSButton *servoEnableA;
    IBOutlet NSButton *servoEnableB;
    IBOutlet NSButton *servoEnableC;
    
    IBOutlet NSButton *sensorPoll1;
    IBOutlet NSButton *sensorPoll2;
    IBOutlet NSButton *sensorPoll3;
    IBOutlet NSButton *sensorPoll4;
    
    IBOutlet NSButton *servoPollA;
    IBOutlet NSButton *servoPollB;
    IBOutlet NSButton *servoPollC;
    IBOutlet NSButton *servoPositionReset;
    
    IBOutlet NSPopUpButton *sensorType1;
    IBOutlet NSPopUpButton *sensorType2;
    IBOutlet NSPopUpButton *sensorType3;
    IBOutlet NSPopUpButton *sensorType4;
    
    IBOutlet NSTextField *sensorValue1;
    IBOutlet NSTextField *sensorValue2;
    IBOutlet NSTextField *sensorValue3;
    IBOutlet NSTextField *sensorValue4;
    
    IBOutlet NSTextField *servoPositionA;
    IBOutlet NSTextField *servoPositionB;
    IBOutlet NSTextField *servoPositionC;
    
    IBOutlet NSSlider *servoSpeedA;
    IBOutlet NSSlider *servoSpeedB;
    IBOutlet NSSlider *servoSpeedC;
    
    BOOL isPollingSensor[4];
    BOOL isPollingServo[3];
}
- (IBAction)doConnect:(id)sender;

- (IBAction)doPollSensor1:(id)sender;
- (IBAction)doPollSensor2:(id)sender;
- (IBAction)doPollSensor3:(id)sender;
- (IBAction)doPollSensor4:(id)sender;

- (IBAction)doPollServoA:(id)sender;
- (IBAction)doPollServoB:(id)sender;
- (IBAction)doPollServoC:(id)sender;

- (IBAction)enableServoA:(id)sender;
- (IBAction)enableServoB:(id)sender;
- (IBAction)enableServoC:(id)sender;

- (IBAction)doChangeSpeedA:(id)sender;
- (IBAction)doChangeSpeedB:(id)sender;
- (IBAction)doChangeSpeedC:(id)sender;

- (IBAction)doResetServoPosition:(id)sender;
@end
