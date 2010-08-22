//
//  AppDelegate_iPad.h
//  NXTDriver
//
//  Created by Zac Bowling on 8/21/10.
//  Copyright i'mhello 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DriverUI.h" 

@interface AppDelegate_iPad : NSObject <UIApplicationDelegate> {
	IBOutlet UIWindow *window;
	IBOutlet DriverUI *driverUIController;
}
@property (nonatomic, retain) IBOutlet DriverUI *driverUIController;
@property (nonatomic, retain) IBOutlet UIWindow *window;

@end

