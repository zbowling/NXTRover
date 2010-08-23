//
//  NXTClient.m
//  NXTDriver
//
//  Created by Zac Bowling on 8/21/10.
//  Copyright 2010 i'mhello. All rights reserved.
//

#import "NXTClient.h"


@implementation NXTClient



+ (void) sendGoMessage:(NSString*)server 
				  left:(SInt8)left 
				 right:(SInt8)right
				 shoot:(SInt8)shoot{

	NSURLRequest *theRequest=[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat: @"http://%@:8080/go?left=%d&right=%d&shoot=%d",server,left,right,shoot]]
											  cachePolicy:NSURLRequestUseProtocolCachePolicy
										  timeoutInterval:1];
	
	
	
	NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	if (theConnection) {
		// Create the NSMutableData to hold the received data.
		// receivedData is an instance variable declared elsewhere.
		NSMutableData* receivedData = [[NSMutableData data] retain];
		
		
	} else {
		// Inform the user that the connection failed.
	}
}

@end
