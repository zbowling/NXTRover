//
//  CaptureController.h
//  CapTest
//
//  Created by Zac Bowling on 8/22/10.
//  Copyright 2010 i'mhello. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CaptureController : UIViewController {
	UIImagePickerController *picker;
	id appdelegate;
}

@property (retain) id appdelegate;

@end
