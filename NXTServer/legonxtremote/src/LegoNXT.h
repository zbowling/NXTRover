/* $Id: LegoNXT.h 17 2009-02-01 01:18:33Z querry43 $ */

/*! \file LegoNXT.h
 * This file defines the interface for Lego NXT Mindstorms(tm) brick
 * and a delegate object for receiving actions from the brick. 
 *
 * \author Matt Harrington
 * \date 01/04/09
 */

#ifndef __LegoNXT_H__
#define __LegoNXT_H__

#import <Cocoa/Cocoa.h>


#import <IOBluetooth/objc/IOBluetoothDevice.h>
#import <IOBluetooth/objc/IOBluetoothSDPUUID.h>
#import <IOBluetooth/objc/IOBluetoothRFCOMMChannel.h>
#import <IOBluetoothUI/objc/IOBluetoothDeviceSelectorController.h>




/*! Message Codes.  These codes specify message type and specify if the command requires a return value or acknowledgement. */
enum {
    kNXTRet   = 0x00, /*!< Command returns a value */
    kNXTNoRet = 0x80, /*!< Command does not return a value */
    kNXTSysOP = 0x01  /*!< Command is a system operation (USB only) */
};


/*! Operation Codes.  This is a list of command operations.  Commands typically control sensors or servos, or request information. */
enum {
    kNXTStartProgram          = 0x00, /*!< Start Program Op Code */
    kNXTStopProgram           = 0x01, /*!< Stop Program Op Code */
    kNXTPlaySoundFile         = 0x02, /*!< Play Sound File Op Code */
    kNXTPlayTone              = 0x03, /*!< Play Tone Op Code */
    kNXTSetOutputState        = 0x04, /*!< Set Output State Op Code */
    kNXTSetInputMode          = 0x05, /*!< */
    kNXTGetOutputState        = 0x06, /*!< */
    kNXTGetInputValues        = 0x07, /*!< */
    kNXTResetScaledInputValue = 0x08, /*!< */
    kNXTMessageWrite          = 0x09, /*!< */
    kNXTResetMotorPosition    = 0x0A, /*!< */
    kNXTGetBatteryLevel       = 0x0B, /*!< */
    kNXTStopSoundPlayback     = 0x0C, /*!< */
    kNXTKeepAlive             = 0x0D, /*!< */
    kNXTLSGetStatus           = 0x0E, /*!< */
    kNXTLSWrite               = 0x0F, /*!< */
    kNXTLSRead                = 0x10, /*!< */
    kNXTGetCurrentProgramName = 0x11, /*!< */
    kNXTMessageRead           = 0x13  /*!< */
};


/*! Port Specifiers.  These enums specify sensor or motor ports. */
enum {
    kNXTSensor1  = 0x00, /*!< Sensor Port 1 */
    kNXTSensor2  = 0x01, /*!< Sensor Port 2 */
    kNXTSensor3  = 0x02, /*!< Sensor Port 3 */
    kNXTSensor4  = 0x03, /*!< Sensor Port 4, the serial port */
    
    kNXTMotorA   = 0x00, /*!< Motor Port A */
    kNXTMotorB   = 0x01, /*!< Motor Port B */
    kNXTMotorC   = 0x02, /*!< Motor Port C */
    kNXTMotorAll = 0xFF  /*!< All Motors */
};


/*! Servo Modes.  These modes alter the behavior of servos. */
enum {
    kNXTCoast     = 0x00, /*!< */
    kNXTMotorOn   = 0x01, /*!< */
    kNXTBrake     = 0x02, /*!< */
    kNXTRegulated = 0x04  /*!< */
};


/*! Servo Regulation Modes.  These regulation modes alter the behavior of servos. */
enum {
    kNXTRegulationModeIdle       = 0x00, /*!< */
    kNXTRegulationModeMotorSpeed = 0x01, /*!< */
    kNXTRegulationModeMotorSync  = 0x02  /*!< */
};


/*! Servo Run States.  These regulation modes alter the behavior of servos. */
enum {
    kNXTMotorRunStateIdle        = 0x00, /*!< */
    kNXTMotorRunStateRampUp      = 0x10, /*!< */
    kNXTMotorRunStateRunning     = 0x20, /*!< */
    kNXTMotorRunStateRampDown    = 0x40  /*!< */
};


/*! Sensor Types.  Specify sensor type and operation. */
enum {
    kNXTNoSensor            = 0x00, /*!< */
    kNXTSwitch              = 0x01, /*!< */
    kNXTTemperature         = 0x02, /*!< */
    kNXTReflection          = 0x03, /*!< */
    kNXTAngle               = 0x04, /*!< */
    kNXTLightActive         = 0x05, /*!< */
    kNXTLightInactive       = 0x06, /*!< */
    kNXTSoundDB             = 0x07, /*!< */
    kNXTSoundDBA            = 0x08, /*!< */
    kNXTCustom              = 0x09, /*!< */
    kNXTLowSpeed            = 0x0A, /*!< */
    kNXTLowSpeed9V          = 0x0B, /*!< */
    kNXTNoOfSensorTypes     = 0x0C  /*!< */
};


/*! Sensor Modes.  These modes control sensor operation. */
enum {
    kNXTRawMode             = 0x00, /*!< */
    kNXTBooleanMode         = 0x20, /*!< */
    kNXTTransitionCntMode   = 0x40, /*!< */
    kNXTPeriodCounterMode   = 0x60, /*!< */
    kNXTPCTFullScaleMode    = 0x80, /*!< */
    kNXTCelciusMode         = 0xA0, /*!< */
    kNXTFahrenheitMode      = 0xC0, /*!< */
    kNXTAngleStepsMode      = 0xE0, /*!< */
    kNXTSlopeMask           = 0x1F, /*!< */
    kNXTModeMask            = 0xE0  /*!< */
};


/*! Command Return Values.  Success and error codes returned by commands. */
enum {
    kNXTSuccess                 = 0x00, /*!< */
    kNXTPendingCommunication    = 0x20, /*!< */
    kNXTMailboxEmpty            = 0x40, /*!< */
    kNXTNoMoreHandles           = 0x81, /*!< */
    kNXTNoSpace                 = 0x82, /*!< */
    kNXTNoMoreFiles             = 0x83, /*!< */
    kNXTEndOfFileExpected       = 0x84, /*!< */
    kNXTEndOfFile               = 0x85, /*!< */
    kNXTNotALinearFile          = 0x86, /*!< */
    kNXTFileNotFound            = 0x87, /*!< */
    kNXTHandleAllReadyClosed    = 0x88, /*!< */
    kNXTNoLinearSpace           = 0x89, /*!< */
    kNXTUndefinedError          = 0x8A, /*!< */
    kNXTFileIsBusy              = 0x8B, /*!< */
    kNXTNoWriteBuffers          = 0x8C, /*!< */
    kNXTAppendNotPossible       = 0x8D, /*!< */
    kNXTFileIsFull              = 0x8E, /*!< */
    kNXTFileExists              = 0x8F, /*!< */
    kNXTModuleNotFound          = 0x90, /*!< */
    kNXTOutOfBoundary           = 0x91, /*!< */
    kNXTIllegalFileName         = 0x92, /*!< */
    kNXTIllegalHandle           = 0x93, /*!< */
    kNXTRequestFailed           = 0xBD, /*!< */
    kNXTUnknownOpCode           = 0xBE, /*!< */
    kNXTInsanePacket            = 0xBF, /*!< */
    kNXTOutOfRange              = 0xC0, /*!< */
    kNXTBusError                = 0xDD, /*!< */
    kNXTCommunicationOverflow   = 0xDE, /*!< */
    kNXTChanelInvalid           = 0xDF, /*!< */
    kNXTChanelBusy              = 0xE0, /*!< */
    kNXTNoActiveProgram         = 0xEC, /*!< */
    kNXTIllegalSize             = 0xED, /*!< */
    kNXTIllegalMailbox          = 0xEE, /*!< */
    kNXTInvalidField            = 0xEF, /*!< */
    kNXTBadInputOutput          = 0xF0, /*!< */
    kNXTInsufficientMemmory     = 0xFB, /*!< */
    kNXTBadArguments            = 0xFF  /*!< */
};



/* These are USB only commands
enum {
    kNXT_SYS_OPEN_READ                = 0x80,
    kNXT_SYS_OPEN_WRITE               = 0x81,
    kNXT_SYS_READ                     = 0x82,
    kNXT_SYS_WRITE                    = 0x83,
    kNXT_SYS_CLOSE                    = 0x84,
    kNXT_SYS_DELETE                   = 0x85,
    kNXT_SYS_FIND_FIRST               = 0x86,
    kNXT_SYS_FIND_NEXT                = 0x87,
    kNXT_SYS_GET_FIRMWARE_VERSION     = 0x88,
    kNXT_SYS_OPEN_WRITE_LINEAR        = 0x89,
    kNXT_SYS_OPEN_READ_LINEAR         = 0x8A,
    kNXT_SYS_OPEN_WRITE_DATA          = 0x8B,
    kNXT_SYS_OPEN_APPEND_DATA         = 0x8C,
    kNXT_SYS_BOOT                     = 0x97,
    kNXT_SYS_SET_BRICK_NAME           = 0x98,
    kNXT_SYS_GET_DEVICE_INFO          = 0x9B,
    kNXT_SYS_DELETE_USER_FLASH        = 0xA0,
    kNXT_SYS_POLL_COMMAND_LENGTH      = 0xA1,
    kNXT_SYS_POLL_COMMAND             = 0xA2,
    kNXT_SYS_BLUETOOTH_FACTORY_RESET  = 0xA4
};
*/


#define NXT_ASSERT_SENSOR_PORT(port) NSAssert1( port <= kNXTSensor4, @"invalid sensor port: %d", port);
#define NXT_ASSERT_MOTOR_PORT(port)  NSAssert1( port <= kNXTMotorC || port == kNXTMotorAll, @"invalid servo port: %d", port);


@interface NSMutableArray(Queue)
- (id)popObject;
- (void)pushObject:(id)object;
@end

/*! NXT Object. */
@interface NXT : NSObject {
    id _delegate;
	
    BOOL connected;
    BOOL checkStatus;
    
    NSTimer *sensorTimers[4];
    NSTimer *motorTimers[3];
    NSTimer *batteryLevelTimer;
    NSTimer *keepAliveTimer;
    
    NSMutableArray *lsGetStatusQueue;
    NSMutableArray *lsReadQueue;
    
    NSLock *lsGetStatusLock;
    NSLock *lsReadLock;
    
	IOBluetoothDevice *mBluetoothDevice;
	IOBluetoothRFCOMMChannel *mRFCOMMChannel;
}


- (void)setDelegate:(id)delegate;

- (BOOL)isConnected;
- (void)alwaysCheckStatus:(BOOL)check;

- (BOOL)connect:(id)delegate;

#pragma mark -
#pragma mark NXT Commands
/*! \name NXT Commands
 * NXT Commands.
 * Low-level NXT commands.  Each command sends a single message to the brick.
 */
//@{

/*! Start a Stored Program.
 * Starts a program stored on the brick.  Program names always end in ".rxe".  For example: "Untitled-1.rxe".
 */
- (void)startProgram:(NSString*)program;

/*! Stop a Running Program.
 * Stops a program run by startProgram:()program.
 */
- (void)stopProgram;

/*! Get Running Program Name.
 * Gets the name of a program run by startProgram:()program.
 */
- (void)getCurrentProgramName;

/*! Play a Sound File.
 * Plays a sound file stored on the brick.  Sound file names always end in ".rso".  For example: "Woops.rso".
 */
- (void)playSoundFile:(NSString*)soundfile loop:(BOOL)loop;

/*! Play a Tone.
 * Plays a tone with a pitch and duration. */
- (void)playTone:(UInt16)tone duration:(UInt16)duration;

/*! Stop Sound Playback.
 * Stops playing sound files or tones. */
- (void)stopSoundPlayback;


/*! Servo Control.
 * Set the output state of a servo.
 * \param port Servo Port 
 * \param power 100 to -100
 * \param mode
 * \param regulationMode  
 * \param turnRatio  
 * \param runState 
 * \param tachoLimit */
- (void)setOutputState:(UInt8)port
                 power:(SInt8)power
                  mode:(UInt8)mode
        regulationMode:(UInt8)regulationMode
             turnRatio:(SInt8)turnRatio
              runState:(UInt8)runState
            tachoLimit:(UInt32)tachoLimit;

/*! Sensor Control.
 * Change the mode of sensors.  Modes are specific to each type of sensor.
 */
- (void)setInputMode:(UInt8)port type:(UInt8)type mode:(UInt8)mode;

/*! Get Servo Output State.
 * Read servo parameters and state, including current position.  Result is sent to delegate.
 */
- (void)getOutputState:(UInt8)port;

/*! Get Sensor Input Values.
 * Read sensor paremeters and state, including raw and calibrated values.  Result is sent to delegate.
 */
- (void)getInputValues:(UInt8)port;

/*! Untested.  What does this do?  Does it work? */
- (void)resetInputScaledValue:(UInt8)port;

/*! Untested.  What does this do?  Does it work? */
- (void)messageWrite:(UInt8)inbox message:(void*)message size:(int)size;

/*! Untested.  What does this do?  Does it work? */
- (void)messageRead:(UInt8)remoteInbox localInbox:(UInt8)localInbox remove:(BOOL)remove;

/*! Untested.  What does this do?  Does it work? */
- (void)resetMotorPosition:(UInt8)port relative:(BOOL)relative;

/*! Read Battery Level.
 * Gets the brick's battery level.  Result is sent to delegate.
 */
- (void)getBatteryLevel;

/*! Get Low-Speed Buffer Status.
 * Use this to determine if the LS device has data to send.  When requesting data with LSWrite, use this
 * method to determine when the data is ready.  This often results in a kNXTPendingCommunication error
 * status, which only means the data is not yet ready.  
 *
 * The easiest way to work with this method is to call LSRead within the delegate's NXTLSGetStatus
 * method.  To call LSGetStatus in loop when data is not ready, catch kNXTPendingCommunication in
 * delegate's NXTOperationError method and re-call LSGetStatus.
 */
- (void)LSGetStatus:(UInt8)port;

/*! Write Data to Low-Speed Device.
 * Writes data to the LS device.  Port must be kNXTSensor4.  Data length is liited to 16 bytes.  This
 * is usually followed by LSGetStatus:()port.
 */
- (void)LSWrite:(UInt8)port txLength:(UInt8)txLength rxLength:(UInt8)rxLength txData:(void*)txData;

/*! Read Data from Low-Speed Device.
 * Reads 16 bytes of 0-padded data from a low-speed device.  This is usually called from the delegate's
 * NXTLSGetStatus method when bytesReady is greater than 0.  Take care to always read data when it is
 * ready, as the buffer on the ultrasound sensor will overflow, resulting in a garbled message.
 */
- (void)LSRead:(UInt8)port;
//@}




#pragma mark -
#pragma mark NXT Methods
/*! \name NXT Methods
 * High-level NXT methods
 * Methods consisting of several NXT commands.  Some of which set timers for polling or keep-alive.
 */
//@{

/*! Keep Brick From Powering Down.
 * Reset's the brick's sleep timer, keeping it from shutting down to save power.
 */
- (void)keepAlive;

/*! Configures touch sensor on given port. */
- (void)setupTouchSensor:(UInt8)port;

/*! Configures sound sensor in given port. 
 * If sensor is adjusted, it will only hear sounds within the human-audible range.
 */
- (void)setupSoundSensor:(UInt8)port adjusted:(BOOL)adjusted;

/*! Configures light sensor on given port.
 * The light is on if active is specified.
 */
- (void)setupLightSensor:(UInt8)port active:(BOOL)active;

/*! Configures the ultrasound sensor.
 * This sensor can only be on kNXTSensor4.
 */
- (void)setupUltrasoundSensor:(UInt8)port continuous:(BOOL)continuous;

/*! Get Untrasound Reading.
 * Fetches a single ultrasound reading.  If you are using continuous mode,
 * byte will always be 0.  Call setupUltrasoundSensor:()continuous before
 * using this method.
 */
- (void)getUltrasoundByte:(UInt8)port byte:(UInt8)byte;

/*! Poll Sensor Values.
 * Polls a sensor with getInputValues:()port every interval.  This does not work
 * for low-speed sensors, such as the ultrasound.
 */
- (void)pollSensor:(UInt8)port interval:(NSTimeInterval)seconds;

/*! Poll Ultrasound Distance.
 * Similar to pollSensor, this polls the ultrasound sensor at a regular interval.
 * Call setupUltrasoundSensor:()continuous before using this method.  Take care not
 * to poll too frequently, as polling the ultrasound generates a lot of chatter and
 * may overwhelm the brick.
 */
- (void)pollUltrasoundSensor:(UInt8)port interval:(NSTimeInterval)seconds;

/*! Poll Keep Alive.
 * Polls the brick with keepAlive:() regularly to keep it from suspending.
 */
- (void)pollKeepAlive;

/*! Poll Battery Lebel.
 * Poll the brick's battery level.
 */
- (void)pollBatteryLevel:(NSTimeInterval)seconds;

/*! Poll Servo Values.
 * Polls a servo with getOutputState:()port every interval.
 */
- (void)pollServo:(UInt8)port interval:(NSTimeInterval)seconds;

/*! Stop all Polling Timers.
 * Stops all scheduled timers, killing all polling.
 */
- (void)stopAllTimers;

/*! Move a Servo.
 * Move a servo at a given power to the set tacho limit.  If limit is 0, move indefinately.
 */
- (void)moveServo:(UInt8)port power:(SInt8)power tacholimit:(UInt32)tacholimit;

/*! Stop All Servos.
 * Set power to 0 on all servos.
 */
- (void)stopServos;
//@}

@end


/*! NXT Delegate Object. */
@interface NSObject( NXTDelegate )
- (void)NXTDiscovered:(NXT*)nxt;
- (void)NXTClosed:(NXT*)nxt;
- (void)NXTCommunicationError:(NXT*)nxt code:(int)code;
- (void)NXTOperationError:(NXT*)nxt operation:(UInt8)operation status:(UInt8)status;
- (void)NXTGetInputValues:(NXT*)nxt port:(UInt8)port isCalibrated:(BOOL)isCalibrated type:(UInt8)type mode:(UInt8)mode
                 rawValue:(UInt16)rawValue normalizedValue:(UInt16)normalizedValue
              scaledValue:(SInt16)scaledValue calibratedValue:(SInt16)calibratedValue;
- (void)NXTGetOutputState:(NXT*)nxt port:(UInt8)port power:(SInt8)power mode:(UInt8)mode regulationMode:(UInt8)regulationMode
                turnRatio:(SInt8)turnRatio runState:(UInt8)runState tachoLimit:(UInt32)tachoLimit tachoCount:(SInt32)tachoCount
          blockTachoCount:(SInt32)blockTachoCount rotationCount:(SInt32)rotationCount;
- (void)NXTBatteryLevel:(NXT*)nxt batteryLevel:(UInt16)batteryLevel;
- (void)NXTSleepTime:(NXT*)nxt sleepTime:(UInt32)sleepTime;
- (void)NXTCurrentProgramName:(NXT*)nxt currentProgramName:(NSString*)currentProgramName;
- (void)NXTLSGetStatus:(NXT*)nxt port:(UInt8)port bytesReady:(UInt8)bytesReady;
- (void)NXTLSRead:(NXT*)nxt port:(UInt8)port bytesRead:(UInt8)bytesRead data:(NSData*)data;
- (void)NXTMessageRead:(NXT*)nxt message:(NSData*)message localInbox:(UInt8)localInbox;
@end

#endif __LegoNXT_H__