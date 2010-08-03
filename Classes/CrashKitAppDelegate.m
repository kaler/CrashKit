//
//  CrashKitAppDelegate.m
//  CrashKit
//
//  Created by Parveen Kaler on 10-08-02.
//  Copyright Smartful Studios Inc 2010. All rights reserved.
//

#import "CrashKitAppDelegate.h"
#import "CrashController.h"

@implementation CrashKitAppDelegate

@synthesize window;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{    
  [window makeKeyAndVisible];
	
  [CrashController sharedInstance];
  
	return YES;
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
  [window release];
  [super dealloc];
}


@end
