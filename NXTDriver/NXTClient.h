//
//  NXTClient.h
//  NXTDriver
//
//  Created by Zac Bowling on 8/21/10.
//  Copyright 2010 i'mhello. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NXTClient : NSObject {
	
};


+ (void)sendGoMessage:(NSString*)server 
				  left:(SInt8)left 
				 right:(SInt8)right
				shoot:(SInt8)shoot;

@end
