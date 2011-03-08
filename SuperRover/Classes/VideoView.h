//
//  VideoView.h
//  SuperRover
//
//  Created by Zac Bowling on 3/5/11.
//  Copyright 2011 i'mhello. All rights reserved.
//
//@generate

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@protocol VideoViewDelegate;

@interface VideoView : UIView {
	//@property 
	UIView *outgoingVideoView;
	UIView *incomingVideoView;
	
	//@property(assign)
	id<VideoViewDelegate> delegate;
}


@end


@protocol VideoViewDelegate : NSObject

- (void)outgoingVideoViewWasPressed;
- (void)incomingVideoViewWasPressed;

@end


