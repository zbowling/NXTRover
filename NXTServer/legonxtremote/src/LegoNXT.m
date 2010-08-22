/* $Id: LegoNXT.m 11 2009-01-05 01:26:25Z querry43 $ */

/*! \file LegoNXT.m
 * This file implements the interface for Lego NXT Mindstorms(tm).
 *
 * \author Matt Harrington
 * \date 01/04/09
 */

#import "LegoNXT.h"

#import <CoreServices/CoreServices.h>
#import <Foundation/NSData.h>

@implementation NSMutableArray(Queue)
- (id)popObject
{
    id object=nil;
    if ([self count])
    {
        object=[self objectAtIndex:0];
        [object retain];
        [self removeObjectAtIndex:0];
    }
    return [object autorelease];
}

- (void)pushObject:(id)object
{
    [self addObject:object];
}

@end

@implementation NXT



/////////////////////
// private methods //
/////////////////////

- (UInt8)doReturn
{
    if ( checkStatus )
        return kNXTRet;
    return kNXTNoRet;
}

- (void)dumpMessage:(const void*)message length:(int)length prefix:(NSString*)prefix
{
    NSString *hexMessage = [NSString string];
    int i;
    for (i = 0; i < length; i++)
        hexMessage = [hexMessage stringByAppendingString:[NSString stringWithFormat:@"%.2p, ", *((unsigned char *)message+i)]];
    NSLog(@"%@%@", prefix, hexMessage);
}

- (void)dumpMessage:(NSData*)message prefix:(NSString*)prefix
{
    [self dumpMessage:[message bytes] length:[message length] prefix:prefix];
}

- (void)sendMessage:(void*)message length:(UInt8)length
{
    char fullMessage[66]; // maximum message size (64) + size (2)
    
    fullMessage[0] = length;
    fullMessage[1] = 0;
    memcpy(fullMessage+2, message, length);
    
    
    [self dumpMessage:fullMessage length:length+2 prefix:@"-> "];
    [mRFCOMMChannel writeSync:fullMessage length:length+2];
}

- (void)doSensorPoll:(NSTimer*)theTimer
{
    UInt8 port = *((UInt8*) [[theTimer userInfo] bytes]);
    [self getInputValues:port];
}

- (void)doUltrasoundPoll:(NSTimer*)theTimer
{
    UInt8 port = *((UInt8*) [[theTimer userInfo] bytes]);
    NSLog(@"polling port %d\n", port);
    
    //
    [self getUltrasoundByte:port byte:0];
    [self LSGetStatus:port];
}

- (void)doKeepAlivePoll:(NSTimer*)theTimer
{
    [self keepAlive];
}

- (void)doBatteryPoll:(NSTimer*)theTimer
{
    [self getBatteryLevel];
}

- (void)doServoPoll:(NSTimer*)theTimer
{
    UInt8 port = *((UInt8*) [[theTimer userInfo] bytes]);
    [self getOutputState:port];
}

- (void)checkSensorPort:(UInt8)port
{
    if ( port > kNXTSensor4 )
        NSLog(@"pollSensor: unknown sensor port %d", port);
}

- (void)invalidateSensorTimer:(UInt8)port
{
    if ( sensorTimers[port] != nil )
    {
        [sensorTimers[port] invalidate];
        sensorTimers[port] = nil;
    }
}

- (void)pushLsGetStatusQueue:(UInt8)port
{
    [lsGetStatusLock lock];
    [lsGetStatusQueue pushObject:[NSNumber numberWithUnsignedShort:port]];
    [lsGetStatusLock unlock];
}

- (UInt8)popLsGetStatusQueue
{
    [lsGetStatusLock lock];
    id object = [lsGetStatusQueue popObject];
    [lsGetStatusLock unlock];
    return [object unsignedShortValue];
}

- (void)pushLsReadQueue:(UInt8)port
{
    [lsReadLock lock];
    [lsReadQueue pushObject:[NSNumber numberWithUnsignedShort:port]];
    [lsReadLock unlock];
}

- (UInt8)popLsReadQueue
{
    [lsReadLock lock];
    id object = [lsReadQueue popObject];
    [lsReadLock unlock];
    return [object unsignedShortValue];
}

- (void)clearPortQueues
{
    [lsReadLock lock];
    [lsReadQueue removeAllObjects];
    [lsReadLock unlock];
    
    [lsGetStatusLock lock];
    [lsGetStatusQueue removeAllObjects];
    [lsGetStatusLock unlock];
}




/////////////////
// constructor //
/////////////////

- (id)init
{    
    int i;
    
    connected = NO;
    checkStatus = NO;
    
    for ( i = 0; i < 4; i++ )
        sensorTimers[i] = nil;
    
    lsGetStatusQueue = [[NSMutableArray alloc] init];
    lsReadQueue = [[NSMutableArray alloc] init];
    
    lsGetStatusLock = [NSLock new];
    lsReadLock = [NSLock new];
	
    return self;
}





////////////////////////////////////
// bluetooth connection delegates //
////////////////////////////////////

- (void)close:(IOBluetoothDevice*)device
{
    int port;
    
    connected = NO;
    
    for ( port = 0; port < 4; port++ )
        [self invalidateSensorTimer:port];	
    
    [self clearPortQueues];
			
    if ( mBluetoothDevice == device )
    {
        IOReturn error = [mBluetoothDevice closeConnection];
        if ( error != kIOReturnSuccess )
        {
            NSLog(@"Error - failed to close the device connection with error %08lx.\n", (UInt32)error);
            if ([_delegate respondsToSelector:@selector(NXTCommunicationError:code:)])
                [_delegate NXTCommunicationError:self code:error];
        }
    
        [mBluetoothDevice release];
    }
}

// from NXTMailController
- (BOOL)connect:(id)delegate
{
    IOBluetoothDeviceSelectorController	*deviceSelector;
	IOBluetoothSDPUUID					*sppServiceUUID;
	NSArray								*deviceArray;

    NSLog( @"Attempting to connect" );
    [self setDelegate:delegate];
	
    // The device selector will provide UI to the end user to find a remote device
    deviceSelector = [IOBluetoothDeviceSelectorController deviceSelector];
	
	if ( deviceSelector == nil ) {
		NSLog( @"Error - unable to allocate IOBluetoothDeviceSelectorController.\n" );
		return FALSE;
	}
	sppServiceUUID = [IOBluetoothSDPUUID uuid16:kBluetoothSDPUUID16ServiceClassSerialPort];
	[deviceSelector addAllowedUUID:sppServiceUUID];
	if ( [deviceSelector runModal] != kIOBluetoothUISuccess ) {
		NSLog( @"User has cancelled the device selection.\n" );
		return FALSE;
	}	
	deviceArray = [deviceSelector getResults];	
	if ( ( deviceArray == nil ) || ( [deviceArray count] == 0 ) ) {
		NSLog( @"Error - no selected device.  ***This should never happen.***\n" );
		return FALSE;
	}
	IOBluetoothDevice *device = [deviceArray objectAtIndex:0];
	IOBluetoothSDPServiceRecord	*sppServiceRecord = [device getServiceRecordForUUID:sppServiceUUID];
	if ( sppServiceRecord == nil ) {
		NSLog( @"Error - no spp service in selected device.  ***This should never happen since the selector forces the user to select only devices with spp.***\n" );
		return FALSE;
	}
	// To connect we need a device to connect and an RFCOMM channel ID to open on the device:
	UInt8	rfcommChannelID;
	if ( [sppServiceRecord getRFCOMMChannelID:&rfcommChannelID] != kIOReturnSuccess ) {
		NSLog( @"Error - no spp service in selected device.  ***This should never happen an spp service must have an rfcomm channel id.***\n" );
		return FALSE;
	}
	
	// Open asyncronously the rfcomm channel when all the open sequence is completed my implementation of "rfcommChannelOpenComplete:" will be called.
	if ( ( [device openRFCOMMChannelAsync:&mRFCOMMChannel withChannelID:rfcommChannelID delegate:self] != kIOReturnSuccess ) && ( mRFCOMMChannel != nil ) ) {
		// Something went bad (looking at the error codes I can also say what, but for the moment let's not dwell on
		// those details). If the device connection is left open close it and return an error:
		NSLog( @"Error - open sequence failed.***\n" );
		[self close:device];
		return FALSE;
	}
	
	mBluetoothDevice = device;
	[mBluetoothDevice  retain];
	[mRFCOMMChannel retain];
	return TRUE;
}







- (void)rfcommChannelClosed:(IOBluetoothRFCOMMChannel *)rfcommChannel
{
	[self performSelector:@selector(close:) withObject:mBluetoothDevice afterDelay:1.0];
    [self stopAllTimers];
    [_delegate NXTClosed:self];
}

- (void)rfcommChannelOpenComplete:(IOBluetoothRFCOMMChannel*)rfcommChannel status:(IOReturn)error
{
    connected = YES;
    
    [_delegate NXTDiscovered:self];
    
	if ( error != kIOReturnSuccess ) {
		NSLog(@"Error - failed to open the RFCOMM channel with error %08lx.\n", (UInt32)error);
        if ([_delegate respondsToSelector:@selector(NXTCommunicationError:code:)])
            [_delegate NXTCommunicationError:self code:error];
		[self rfcommChannelClosed:rfcommChannel];
		return;
	}
    
	
}

- (void)rfcommChannelData:(IOBluetoothRFCOMMChannel*)rfcommChannel data:(void *)dataPointer length:(size_t)dataLength
{
    int i = 0;
    
    [self dumpMessage:dataPointer length:dataLength prefix:@"<- "];
    
    while ( i < dataLength )
    {
        UInt16 messageLength = 0;
        UInt8  opCode = 0;
        UInt8 status = 0;
        
        // get the command length
        memcpy(&messageLength, dataPointer+i, 2);
        messageLength = OSSwapLittleToHostInt16(messageLength);
        i += 2;
        
        // read the opcode and status
        memcpy(&opCode, dataPointer+i+1, 1);
        memcpy(&status, dataPointer+i+2, 1);
        i += 3;
		
		
        
        // report error status
        if ( status != kNXTSuccess && [_delegate respondsToSelector:@selector(NXTOperationError:operation:status:)] )
            [_delegate NXTOperationError:self operation:opCode status:status];
        else
        {
			
			
			
			
            if ( opCode == kNXTGetOutputState )
            {
                UInt8 port;
                SInt8 power;
                UInt8 mode;
                UInt8 regulationMode;
                SInt8 turnRatio;
                UInt8 runState;
                UInt32 tachoLimit;
                SInt32 tachoCount;
                SInt32 blockTachoCount;
                SInt32 rotationCount;
                
                memcpy(&port,            dataPointer+i+0,  1); // 3
                memcpy(&power,           dataPointer+i+1,  1); // 4
                memcpy(&mode,            dataPointer+i+2,  1); // 5
                memcpy(&regulationMode,  dataPointer+i+3,  1); // 6
                memcpy(&turnRatio,       dataPointer+i+4,  1); // 7
                memcpy(&runState,        dataPointer+i+5,  1); // 8
                memcpy(&tachoLimit,      dataPointer+i+6,  4); // 9
                memcpy(&tachoCount,      dataPointer+i+10, 4); // 13
                memcpy(&blockTachoCount, dataPointer+i+14, 4); // 17
                memcpy(&rotationCount,   dataPointer+i+18, 4); // 21
                i += 21;
                
                tachoLimit      = OSSwapLittleToHostInt32(tachoLimit);
                tachoCount      = OSSwapLittleToHostInt32(tachoCount);
                blockTachoCount = OSSwapLittleToHostInt32(blockTachoCount);
                rotationCount   = OSSwapLittleToHostInt32(rotationCount);
                
                if ( [_delegate respondsToSelector:@selector(NXTGetOutputState:port:power:mode:regulationMode:turnRatio:runState:tachoLimit:tachoCount:blockTachoCount:rotationCount:)] )
                    [_delegate NXTGetOutputState:self
                                            port:port
                                           power:power
                                            mode:mode
                                  regulationMode:regulationMode
                                       turnRatio:turnRatio
                                        runState:runState
                                      tachoLimit:tachoLimit
                                      tachoCount:tachoCount
                                 blockTachoCount:blockTachoCount
                                   rotationCount:rotationCount];
            }
            else if ( opCode == kNXTGetInputValues )
            {
                UInt8  port;
                UInt8  valid;
                UInt8  isCalibrated;
                UInt8  sensorType;
                SInt8  sensorMode;
                UInt16 rawValue;
                UInt16 normalizedValue;
                SInt16 scaledValue;
                SInt16 calibratedValue;
                
                memcpy(&port,               dataPointer+i+0,  1); // 3
                memcpy(&valid,              dataPointer+i+1,  1); // 4
                memcpy(&isCalibrated,       dataPointer+i+2,  1); // 5
                memcpy(&sensorType,         dataPointer+i+3,  1); // 6
                memcpy(&sensorMode,         dataPointer+i+4,  1); // 7
                memcpy(&rawValue,           dataPointer+i+5,  2); // 8
                memcpy(&normalizedValue,    dataPointer+i+7,  2); // 10
                memcpy(&scaledValue,        dataPointer+i+9,  2); // 12
                memcpy(&calibratedValue,    dataPointer+i+11, 2); // 14
                i += 12;
                
                rawValue        = OSSwapLittleToHostInt16(rawValue);
                normalizedValue = OSSwapLittleToHostInt16(normalizedValue);
                scaledValue     = OSSwapLittleToHostInt16(scaledValue);
                calibratedValue = OSSwapLittleToHostInt16(calibratedValue);
                
                if ( valid && [_delegate respondsToSelector:@selector(NXTGetInputValues:port:isCalibrated:type:mode:rawValue:normalizedValue:scaledValue:calibratedValue:)] )
                    [_delegate NXTGetInputValues:self
											port:port
									isCalibrated:isCalibrated
											type:sensorType
											mode:sensorMode
										rawValue:rawValue
								 normalizedValue:normalizedValue
									 scaledValue:scaledValue
								 calibratedValue:scaledValue];
            }
            else if ( opCode == kNXTGetBatteryLevel )
            {
                UInt16 batteryLevel;
                
                memcpy(&batteryLevel, dataPointer+i+0, 2); // 3
                i += 2;
                
                batteryLevel = OSSwapLittleToHostInt16(batteryLevel);
                
                if ( [_delegate respondsToSelector:@selector(NXTBatteryLevel:batteryLevel:)] )
                    [_delegate NXTBatteryLevel:self batteryLevel:batteryLevel];
            }
            else if ( opCode == kNXTKeepAlive )
            {
                UInt32 sleepTime;
                
                memcpy(&sleepTime, dataPointer+i+0, 4); // 3
                i += 4;
                
                sleepTime = OSSwapLittleToHostInt32(sleepTime);
                
                if ( [_delegate respondsToSelector:@selector(NXTSleepTime:sleepTime:)] )
                    [_delegate NXTSleepTime:self sleepTime:sleepTime];
            }
			
			// LSGetStatus often returns the kNXTPendingCommunication error status
            else if ( opCode == kNXTLSGetStatus )
            {
                UInt8 bytesReady;
                
                memcpy(&bytesReady, dataPointer+i+0, 1); // 3
                i += 1;
                if ( [_delegate respondsToSelector:@selector(NXTLSGetStatus:port:bytesReady:)] )
                    [_delegate NXTLSGetStatus:self port:[self popLsGetStatusQueue] bytesReady:bytesReady];
            }
            else if ( opCode == kNXTLSRead )
            {
                UInt8 bytesRead;
                NSData *data;
                
                memcpy(&bytesRead, dataPointer+i+0, 1); // 3
                
                data = [[NSData dataWithBytes:(dataPointer+i+1) length:16] retain];
                i += 17;
				
                if ( [_delegate respondsToSelector:@selector(NXTLSRead:port:bytesRead:data:)] )
                    [_delegate NXTLSRead:self port:[self popLsReadQueue] bytesRead:bytesRead data:data];
            }
            else if ( opCode == kNXTGetCurrentProgramName )
            {
                NSString *currentProgramName = [[NSString stringWithCString:(dataPointer+i) encoding:NSASCIIStringEncoding] retain]; // 3-22
                i += 20;
				
                if ( [_delegate respondsToSelector:@selector(NXTCurrentProgramName:currentProgramName:)] )
                    [_delegate NXTCurrentProgramName:self currentProgramName:currentProgramName];
            }
            else if ( opCode == kNXTMessageRead )
            {
                UInt8 localInbox;
                UInt8 messageSize;
                NSData *message;
                
                memcpy(&localInbox, dataPointer+i+0, 1); // 3
                memcpy(&messageSize, dataPointer+i+1, 1); // 4
                message = [NSData dataWithBytes:dataPointer+i+2 length:messageSize-1];
                i += 61;
                
                if ( [_delegate respondsToSelector:@selector(NXTMessageRead:message:localInbox:)] )
                    [_delegate NXTMessageRead:self message:message localInbox:localInbox];
            }
        }
    }
}







///////////////////
// nxt interface //
///////////////////

- (void)startProgram:(NSString*)program
{
    char message[22] = {
        [self doReturn],
        kNXTStartProgram
    };
    
    [program getCString:(message+2) maxLength:20 encoding:NSASCIIStringEncoding];
    message[21] = '\0';
    
    // send the message
    [self sendMessage:message length:22];
}


- (void)stopProgram
{
    // construct the message
    char message[] = {
        [self doReturn],
        kNXTStopProgram
    };
    
    // send the message
    [self sendMessage:message length:2];
}

- (void)getCurrentProgramName
{
    char message[] = {
        kNXTRet,
        kNXTGetCurrentProgramName
    };
    
    // send the message
    [self sendMessage:message length:2];
}

- (void)playSoundFile:(NSString*)soundfile loop:(BOOL)loop
{
    char message[23] = {
        [self doReturn],
        kNXTPlaySoundFile,
        (loop ? 1 : 0)
    };
    
    [soundfile getCString:(message+3) maxLength:20 encoding:NSASCIIStringEncoding];
	
    // send the message
    [self sendMessage:message length:23];
}

- (void)playTone:(UInt16)tone duration:(UInt16)duration
{
    // construct the message
    char message[] = {
        [self doReturn],
        kNXTPlayTone,
        (tone & 0x00ff),
        (tone & 0xff00) >> 8,
        (duration & 0x00ff),
        (duration & 0xff00) >> 8
    };
    
    // send the message
    [self sendMessage:message length:6];
}

- (void)stopSoundPlayback
{
    // construct the message
    char message[] = {
        [self doReturn],
        kNXTStopSoundPlayback
    };
    
    // send the message
    [self sendMessage:message length:2];
}

- (void)setOutputState:(UInt8)port
                 power:(SInt8)power
                  mode:(UInt8)mode
        regulationMode:(UInt8)regulationMode
             turnRatio:(SInt8)turnRatio
              runState:(UInt8)runState
            tachoLimit:(UInt32)tachoLimit
{
    NXT_ASSERT_MOTOR_PORT(port);
    
    // construct the message
    char message[] = {
        [self doReturn],
        kNXTSetOutputState,
        port,
        power,
        mode,
        regulationMode,
        turnRatio,
        runState,
        (tachoLimit & 0x000000ff),
        (tachoLimit & 0x0000ff00) >> 8,
        (tachoLimit & 0x00ff0000) >> 16,
        (tachoLimit & 0xff000000) >> 24
    };
    
    // send the message
    [self sendMessage:message length:12];
}

- (void)setInputMode:(UInt8)port type:(UInt8)type mode:(UInt8)mode
{
    NXT_ASSERT_SENSOR_PORT(port);
    
    // construct the message
    char message[] = {
        [self doReturn],
        kNXTSetInputMode,
        port,
        type,
        mode
    };
    
    // send the message
    [self sendMessage:message length:5];
}

- (void)getOutputState:(UInt8)port
{
    NXT_ASSERT_SENSOR_PORT(port);
    
    char message[] = {
        kNXTRet,
        kNXTGetOutputState,
        port
    };
    
    // send the message
    [self sendMessage:message length:3];
}

- (void)getInputValues:(UInt8)port
{
    NXT_ASSERT_SENSOR_PORT(port);
    
    // construct the message
    char message[] = {
        kNXTRet,
        kNXTGetInputValues,
        port
    };
    
    // send the message
    [self sendMessage:message length:3];
}

- (void)resetInputScaledValue:(UInt8)port
{
    NXT_ASSERT_SENSOR_PORT(port);
    
    // construct the message
    char message[] = {
        [self doReturn],
        kNXTResetScaledInputValue,
        port
    };
    
    // send the message
    [self sendMessage:message length:3];
}

- (void)messageWrite:(UInt8)inbox message:(void*)message size:(int)size
{
    char _message[size+4];
    
    _message[0] = [self doReturn];
    _message[1] = kNXTMessageWrite;
    _message[2] = inbox;
    _message[3] = size;
    
    memcpy(_message+4, message, size);
    
    [self sendMessage:_message length:size+4];
}


- (void)messageRead:(UInt8)remoteInbox localInbox:(UInt8)localInbox remove:(BOOL)remove
{
    char message[] = {
        kNXTRet,
        kNXTMessageRead,
        remoteInbox,
        localInbox,
        (remove ? 1 : 0)
    };
    
    [self sendMessage:message length:5];
}


- (void)resetMotorPosition:(UInt8)port relative:(BOOL)relative
{
    // construct the message
    char message[] = {
        [self doReturn],
        kNXTResetMotorPosition,
        port,
        (relative ? 1 : 0)
    };
    
    // send the message
    [self sendMessage:message length:4];
}


- (void)getBatteryLevel
{
    char message[] = {
        kNXTRet,
        kNXTGetBatteryLevel
    };
    
    // send the message
    [self sendMessage:message length:2];
}

- (void)LSGetStatus:(UInt8)port
{
    NXT_ASSERT_SENSOR_PORT(port);
    
    char message[] = {
        kNXTRet,
        kNXTLSGetStatus,
        port
    };
    
    // send the message
    [self sendMessage:message length:3];
}

- (void)LSWrite:(UInt8)port txLength:(UInt8)txLength rxLength:(UInt8)rxLength txData:(void*)txData
{
    NXT_ASSERT_SENSOR_PORT(port);
    char message[5+txLength];
    
    message[0] = kNXTRet;
    message[1] = kNXTLSWrite;
    message[2] = port;
    message[3] = txLength;
    message[4] = rxLength;
    
    memcpy(message+5, txData, txLength);
    
    [self sendMessage:message length:(5+txLength)];
}

- (void)LSRead:(UInt8)port
{
    NXT_ASSERT_SENSOR_PORT(port);
    
    char message[] = {
        kNXTRet,
        kNXTLSRead,
        port
    };
    
    [self pushLsReadQueue:port];
    [self sendMessage:message length:3];
}






///////////////////////////////
// high-level nxt interfaces //
///////////////////////////////

- (void)keepAlive
{
    char message[] = {
        [self doReturn],
        kNXTKeepAlive
    };
    
    // send the message
    [self sendMessage:message length:2];
}

- (void)setupTouchSensor:(UInt8)port
{
    [self setInputMode:port type:kNXTSwitch mode:kNXTBooleanMode];
}

- (void)setupSoundSensor:(UInt8)port adjusted:(BOOL)adjusted
{
    if ( adjusted )
        [self setInputMode:port type:kNXTSoundDBA mode:kNXTPCTFullScaleMode];
    else
        [self setInputMode:port type:kNXTSoundDB mode:kNXTPCTFullScaleMode];
}

- (void)setupLightSensor:(UInt8)port active:(BOOL)active
{
    if ( active )
        [self setInputMode:port type:kNXTLightActive mode:kNXTPCTFullScaleMode];
    else
        [self setInputMode:port type:kNXTLightInactive mode:kNXTPCTFullScaleMode];
}

- (void)setupUltrasoundSensor:(UInt8)port continuous:(BOOL)continuous
{
    char message[] = { 0x02, 0x41, 0x02 };
    [self setInputMode:port type:kNXTLowSpeed9V mode:kNXTRawMode];
    usleep(1000000);
    [self LSWrite:port txLength:3 rxLength:0 txData:message];
}

- (void)getUltrasoundByte:(UInt8)port byte:(UInt8)byte
{
    if ( byte > 7 )
        return;
    char message[] = { 0x02, 0x42+byte };
    [self pushLsGetStatusQueue:port];
    [self LSWrite:port txLength:2 rxLength:1 txData:message];
}

- (void)pollSensor:(UInt8)port interval:(NSTimeInterval)seconds
{
    NXT_ASSERT_SENSOR_PORT(port);
    [self invalidateSensorTimer:port];
    
    if ( seconds > 0 )
    {
        NSLog(@"pollSensor: starting poll timer");
        sensorTimers[port] = [[NSTimer scheduledTimerWithTimeInterval:seconds
                                                               target:self
                                                             selector:@selector(doSensorPoll:)
                                                             userInfo:[NSData dataWithBytes:&port length:1]
                                                              repeats:YES] retain];
    }
}

- (void)pollUltrasoundSensor:(UInt8)port interval:(NSTimeInterval)seconds
{
    NXT_ASSERT_SENSOR_PORT(port);
    [self invalidateSensorTimer:port]; 
    
    if ( seconds > 0 )
        sensorTimers[port] = [[NSTimer scheduledTimerWithTimeInterval:seconds
                                                               target:self
                                                             selector:@selector(doUltrasoundPoll:)
                                                             userInfo:[NSData dataWithBytes:&port length:1]
                                                              repeats:YES] retain];
}

- (void)pollKeepAlive
{
    if ( keepAliveTimer == nil )
        keepAliveTimer = [[NSTimer scheduledTimerWithTimeInterval:60
                                                           target:self
                                                         selector:@selector(doKeepAlivePoll:)
                                                         userInfo:nil
                                                          repeats:YES] retain];
}

- (void)pollBatteryLevel:(NSTimeInterval)seconds
{
    if ( batteryLevelTimer != nil )
    {
        [batteryLevelTimer invalidate];
        batteryLevelTimer = nil;
    }
    
    if ( seconds > 0 )
        batteryLevelTimer = [[NSTimer scheduledTimerWithTimeInterval:seconds
                                                              target:self
                                                            selector:@selector(doBatteryPoll:)
                                                            userInfo:nil
                                                             repeats:YES] retain];
}

- (void)pollServo:(UInt8)port interval:(NSTimeInterval)seconds
{
    NXT_ASSERT_MOTOR_PORT(port);
    
    if ( motorTimers[port] != nil )
    {
        [motorTimers[port] invalidate];
        motorTimers[port] = nil;
    }
    
    if ( seconds > 0 )
        motorTimers[port] = [[NSTimer scheduledTimerWithTimeInterval:seconds
                                                              target:self
                                                            selector:@selector(doServoPoll:)
                                                            userInfo:[NSData dataWithBytes:&port length:1]
                                                             repeats:YES] retain];
}

- (void)stopAllTimers
{
    int i;
    
    for ( i = 0; i < 4; i++ )
        [self pollSensor:i interval:0];
    for ( i = 0; i < 3; i++ )
        [self pollServo:i interval:0];
    
    if ( keepAliveTimer != nil )
    {
        [keepAliveTimer invalidate];
        keepAliveTimer = nil;
    }
    
    [self pollBatteryLevel:0];
}

- (void)moveServo:(UInt8)port power:(SInt8)power tacholimit:(UInt32)tacholimit
{
    NXT_ASSERT_MOTOR_PORT(port);
    
    [self setOutputState:port
                   power:power
                    mode:(kNXTMotorOn | kNXTRegulated)
          regulationMode:kNXTRegulationModeMotorSpeed
               turnRatio:0
                runState:kNXTMotorRunStateRunning
              tachoLimit:tacholimit];
}





- (void)stopServos
{
    [self setOutputState:kNXTMotorAll
                   power:0
                    mode:0
          regulationMode:kNXTRegulationModeIdle
               turnRatio:0
                runState:kNXTMotorRunStateIdle
              tachoLimit:0];
}



- (BOOL)isConnected
{
    return connected;
}

- (void)setDelegate:(id)delegate{
    _delegate = delegate;
}

- (void)alwaysCheckStatus:(BOOL)check
{
    checkStatus = check;
}

@end
