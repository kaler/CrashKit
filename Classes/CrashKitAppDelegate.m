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

- (void)crash
{
  void (*func)() = 0;
  func();
}

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{    
  [window makeKeyAndVisible];
	
  [CrashController sharedInstance];
  [self performSelector:@selector(crash) withObject:nil afterDelay:0.1];
  
	return YES;
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
  [window release];
  [super dealloc];
}


@end
