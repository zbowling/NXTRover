/* $Id: LegoNXTRemote.m 17 2009-02-01 01:18:33Z querry43 $ */

/*! \file LegoNXTRemote.h
* This file implements a graphical interface for the LegoNXT Framework.
*
* \author Matt Harrington
* \date 01/04/09
*/

#import "LegoNXTRemote.h"

@implementation LegoNXTRemote


// enable all poll buttons
- (void)enableControls:(BOOL)enable
{
    [sensorPoll1 setEnabled:enable];
    [sensorPoll2 setEnabled:enable];
    [sensorPoll3 setEnabled:enable];
    [sensorPoll4 setEnabled:enable];
    
    [sensorType1 setEnabled:enable];
    [sensorType2 setEnabled:enable];
    [sensorType3 setEnabled:enable];
    [sensorType4 setEnabled:enable];
    
    [servoEnableA setEnabled:enable];
    [servoEnableB setEnabled:enable];
    [servoEnableC setEnabled:enable];
    
    [servoPollA setEnabled:enable];
    [servoPollB setEnabled:enable];
    [servoPollC setEnabled:enable];
    
    [servoPositionReset setEnabled:enable];
    
    if ( ! enable )
    {
        [sensorPoll1 setTitle:@"Poll"];
        [sensorPoll2 setTitle:@"Poll"];
        [sensorPoll3 setTitle:@"Poll"];
        [sensorPoll4 setTitle:@"Poll"];
        
        [servoPollA setTitle:@"Poll"];
        [servoPollB setTitle:@"Poll"];
        [servoPollC setTitle:@"Poll"];
        
        [servoEnableA setState:NSOffState];
        [servoEnableB setState:NSOffState];
        [servoEnableC setState:NSOffState];
        
        [servoSpeedA setEnabled:enable];
        [servoSpeedB setEnabled:enable];
        [servoSpeedC setEnabled:enable];
        
        [servoSpeedA setIntValue:0];
        [servoSpeedB setIntValue:0];
        [servoSpeedC setIntValue:0];
        
        int i ;
        
        for ( i = 0; i < 4; i++ )
            isPollingSensor[i] = NO;
        for ( i = 0; i < 3; i++ )
            isPollingServo[i] = NO;
    }
}


// begin polling a sensor
- (void)startPollingSensor:(BOOL)start
                sensorPort:(UInt8)port
            sensorSelector:(NSPopUpButton*)sensorSelector
                pollButton:(NSButton*)pollButton
{
    NSString *sensorType = [sensorSelector titleOfSelectedItem];
    
    if ( start )
    {
        BOOL isUltrasound = NO;
        
        
        // setup sensor
        NSLog(@"startPollingSensor: setup sensor");
        if ([sensorType isEqualToString:@"Touch"])
            [_nxt setupTouchSensor:port];
        else if ([sensorType isEqualToString:@"Sound"])
            [_nxt setupSoundSensor:port adjusted:TRUE];
        else if ([sensorType isEqualToString:@"Light"])
            [_nxt setupLightSensor:port active:YES];
        else if ([sensorType isEqualToString:@"Light Passive"])
            [_nxt setupLightSensor:port active:NO];
        else if ([sensorType isEqualToString:@"Sonar"])
        {
            isUltrasound = YES;
            [_nxt setupUltrasoundSensor:port continuous:YES];
        }
        else
        {
            NSLog(@"startPollingSensor: unknown sensor type");
            return;
        }
        
        
        // start polling
        NSLog(@"startPollingSensor: start polling");
        if ( isUltrasound )
            [_nxt pollUltrasoundSensor:port interval:1];
        else
            [_nxt pollSensor:port interval:1];
        
        [pollButton setTitle:@"Stop"];
        [sensorSelector setEnabled:NO];
    }
    
    else
    {
        // ultrasound gets special treatment
        if ([sensorType isEqualToString:@"Sonar"])
            [_nxt pollUltrasoundSensor:port interval:0];
        else
            [_nxt pollSensor:port interval:0];
        
        [pollButton setTitle:@"Poll"];
        [sensorSelector setEnabled:YES];
    }
}


- (void)enableServo:(int)state port:(UInt8)port speedControl:(NSSlider*)servoSpeed
{
    if ( state == NSOnState )
        [servoSpeed setEnabled:YES];
    else
    {
        [servoSpeed setEnabled:NO];
        [servoSpeed setIntValue:0];
        [_nxt setOutputState:port
                       power:0
                        mode:kNXTCoast
              regulationMode:kNXTRegulationModeIdle
                   turnRatio:0
                    runState:kNXTMotorRunStateIdle
                  tachoLimit:0];
    }
}


// begin polling a servo
- (void)startPollingServo:(BOOL)start
                servoPort:(UInt8)port
               pollButton:(NSButton*)pollButton
{
    if ( start )
    {
        NSLog(@"startPollingServo: start polling");
        [_nxt pollServo:port interval:1];
        [pollButton setTitle:@"Stop"];
    }
    else
    {
        [_nxt pollServo:port interval:0];
        [pollButton setTitle:@"Poll"];
    }
}

- (void)setSensorTextField:(UInt8)port value:(NSString*)value
{
    switch ( port )
    {
        case kNXTSensor1:
            [sensorValue1 setStringValue:value];
            break;
        case kNXTSensor2:
            [sensorValue2 setStringValue:value];
            break;
        case kNXTSensor3:
            [sensorValue3 setStringValue:value];
            break;
        case kNXTSensor4:
            [sensorValue4 setStringValue:value];
            break;
    }
}


#pragma mark -
#pragma mark GUI Delegates

- (id)awakeFromNib
{
    [NSApp setDelegate:self];
    
    // set a status label
    [connectMessage setStringValue:[NSString stringWithFormat:@"Disconnected"]];
    
    return self;
}

- (BOOL)windowShouldClose:(id)sender
{
    [NSApp terminate:self];
    return true;
}

- (IBAction)doConnect:(id)sender
{
    [connectMessage setStringValue:[NSString stringWithFormat:@"Connecting..."]];
	
    _nxt = [[NXT alloc] init];
    [_nxt connect:self];
}

- (IBAction)doPollSensor1:(id)sender
{    
    if ( isPollingSensor[0] )
        isPollingSensor[0] = NO;
    else
        isPollingSensor[0] = YES;
    
    [self startPollingSensor:isPollingSensor[0] sensorPort:kNXTSensor1 sensorSelector:sensorType1 pollButton:sensorPoll1];
}

- (IBAction)doPollSensor2:(id)sender
{
    if ( isPollingSensor[1] )
        isPollingSensor[1] = NO;
    else
        isPollingSensor[1] = YES;
    
    [self startPollingSensor:isPollingSensor[1] sensorPort:kNXTSensor2 sensorSelector:sensorType2 pollButton:sensorPoll2];
}

- (IBAction)doPollSensor3:(id)sender
{
    if ( isPollingSensor[2] )
        isPollingSensor[2] = NO;
    else
        isPollingSensor[2] = YES;
    
    [self startPollingSensor:isPollingSensor[2] sensorPort:kNXTSensor3 sensorSelector:sensorType3 pollButton:sensorPoll3];
}

- (IBAction)doPollSensor4:(id)sender
{
    if ( isPollingSensor[3] )
        isPollingSensor[3] = NO;
    else
        isPollingSensor[3] = YES;
    
    [self startPollingSensor:isPollingSensor[3] sensorPort:kNXTSensor4 sensorSelector:sensorType4 pollButton:sensorPoll4];
}

- (IBAction)enableServoA:(id)sender
{
    [self enableServo:[sender state] port:kNXTMotorA speedControl:servoSpeedA];
}

- (IBAction)enableServoB:(id)sender
{
    [self enableServo:[sender state] port:kNXTMotorB speedControl:servoSpeedB];
}

- (IBAction)enableServoC:(id)sender
{
    [self enableServo:[sender state] port:kNXTMotorC speedControl:servoSpeedC];
}

- (IBAction)doChangeSpeedA:(id)sender
{
    int speed = [sender intValue];
    [_nxt moveServo:kNXTMotorA power:speed tacholimit:0];
}

- (IBAction)doChangeSpeedB:(id)sender
{
    int speed = [sender intValue];
    [_nxt moveServo:kNXTMotorB power:speed tacholimit:0];
}

- (IBAction)doChangeSpeedC:(id)sender
{
    int speed = [sender intValue];
    [_nxt moveServo:kNXTMotorC power:speed tacholimit:0];   
}

- (IBAction)doPollServoA:(id)sender
{
    if ( isPollingServo[0] )
        isPollingServo[0] = NO;
    else
        isPollingServo[0] = YES;
    
    [self startPollingServo:isPollingServo[0] servoPort:kNXTMotorA pollButton:servoPollA];
}

- (IBAction)doPollServoB:(id)sender
{
    if ( isPollingServo[1] )
        isPollingServo[1] = NO;
    else
        isPollingServo[1] = YES;
    
    [self startPollingServo:isPollingServo[1] servoPort:kNXTMotorB pollButton:servoPollB];
}

- (IBAction)doPollServoC:(id)sender
{
    if ( isPollingServo[2] )
        isPollingServo[2] = NO;
    else
        isPollingServo[2] = YES;
    
    [self startPollingServo:isPollingServo[2] servoPort:kNXTMotorC pollButton:servoPollC];
}


- (IBAction)doResetServoPosition:(id)sender
{
    [_nxt resetMotorPosition:kNXTMotorA relative:YES];
    [_nxt resetMotorPosition:kNXTMotorB relative:YES];
    [_nxt resetMotorPosition:kNXTMotorC relative:YES];
    
    [servoPositionA setStringValue:@""];
    [servoPositionB setStringValue:@""];
    [servoPositionC setStringValue:@""];
}


#pragma mark -
#pragma mark NXT Delegates

// connected
- (void) NXTDiscovered:(NXT*)nxt
{
    [connectMessage setStringValue:[NSString stringWithFormat:@"Connected"]];
    [connectButton setEnabled:NO];
    [self enableControls:YES];
    
	[nxt playTone:523 duration:500];
    [nxt getBatteryLevel];
    [nxt pollKeepAlive];
}


// disconnected
- (void) NXTClosed:(NXT*)nxt
{
    [connectMessage setStringValue:[NSString stringWithFormat:@"Disconnected"]];
    [connectButton setEnabled:YES];
    
    [self enableControls:NO];
}


// NXT delegate methods
- (void) NXTError:(NXT*)nxt code:(int)code
{
    [connectMessage setIntValue:code];
}


// handle errors, special case ls pending communication
- (void)NXTOperationError:(NXT*)nxt operation:(UInt8)operation status:(UInt8)status
{
    // if communication is pending on the LS port, just keep polling
	if ( operation == kNXTLSGetStatus && status == kNXTPendingCommunication )
		[nxt LSGetStatus:kNXTSensor4];
	else
		NSLog(@"nxt error: operation=0x%x status=0x%x", operation, status);
}


// if bytes are ready to read, read 'em
- (void) NXTLSGetStatus:(NXT *)nxt port:(UInt8)port bytesReady:(UInt8)bytesReady
{
    NSLog(@"bytes ready on port %d: %d", port, bytesReady);
	
    // XXX: problem here
	if ( bytesReady > 0 )
		[nxt LSRead:port];
}


// read battery level
- (void)NXTBatteryLevel:(NXT*)nxt batteryLevel:(UInt16)batteryLevel
{
    [batteryLevelIndicator setIntValue:batteryLevel];
}



// read sensor values
- (void)NXTGetInputValues:(NXT*)nxt port:(UInt8)port isCalibrated:(BOOL)isCalibrated type:(UInt8)type mode:(UInt8)mode
				 rawValue:(UInt16)rawValue normalizedValue:(UInt16)normalizedValue
			  scaledValue:(SInt16)scaledValue calibratedValue:(SInt16)calibratedValue
{
    NSString *value = [NSString stringWithFormat:@"%d", scaledValue];
    
    [self setSensorTextField:port value:value];
    /*
    switch ( port )
    {
        case kNXTSensor1:
            [sensorValue1 setStringValue:value];
            break;
        case kNXTSensor2:
            [sensorValue2 setStringValue:value];
            break;
        case kNXTSensor3:
            [sensorValue3 setStringValue:value];
            break;
        case kNXTSensor4:
            [sensorValue4 setStringValue:value];
            break;
    }*/
}


// read the sonar values
- (void)NXTLSRead:(NXT*)nxt port:(UInt8)port bytesRead:(UInt8)bytesRead data:(NSData*)data
{
    short int d;
    [data getBytes:&d length:2];
    d = OSSwapLittleToHostInt16(d);
    NSString *value;

    // out of bounds
    if ( d == 255 )
        value = [NSString stringWithFormat:@"--"];
    else
        value = [NSString stringWithFormat:@"%hu", d];
    
    [self setSensorTextField:port value:value];
    //[sensorValue4 setStringValue:value];
}

// read servo values
- (void) NXTGetOutputState:(NXT *)nxt
                      port:(UInt8)port
                     power:(SInt8)power
                      mode:(UInt8)mode
            regulationMode:(UInt8)regulationMode
                 turnRatio:(SInt8)turnRatio
                  runState:(UInt8)runState
                tachoLimit:(UInt32)tachoLimit
                tachoCount:(SInt32)tachoCount
           blockTachoCount:(SInt32)blockTachoCount
             rotationCount:(SInt32)rotationCount
{
    NSString *value = [NSString stringWithFormat:@"%d", blockTachoCount];
    
    switch ( port )
    {
        case kNXTMotorA:
            [servoPositionA setStringValue:value];
            break;
        case kNXTMotorB:
            [servoPositionB setStringValue:value];
            break;
        case kNXTMotorC:
            [servoPositionC setStringValue:value];
            break;
    }
    
}

@end
