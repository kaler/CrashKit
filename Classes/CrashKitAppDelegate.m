//
//  CrashKitAppDelegate.m
//  CrashKit
//
//  Created by Parveen Kaler on 10-08-02.
//  Copyright Smartful Studios Inc 2010. All rights reserved.
//

#import "CrashKitAppDelegate.h"
#import "CrashController.h"
#import "RootViewController.h"

@implementation CrashKitAppDelegate

@synthesize window, navigationController;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{
  RootViewController *r = [[RootViewController alloc] initWithStyle:UITableViewStylePlain];
  navigationController = [[UINavigationController alloc] initWithRootViewController:r];
  [r release];
  [window makeKeyAndVisible];
	
  CrashController *crash = [CrashController sharedInstance];
  crash.delegate = self;
  
	return YES;
}

- (void)onCrash
{
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Crash"
                                                  message:@"The App has crashed and will attempt to send a crash report"
                                                 delegate:nil
                                        cancelButtonTitle:@"OK"
                                        otherButtonTitles:nil];
  [alert show];
  [alert release];
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc 
{
  [navigationController release];
  [window release];
  [super dealloc];
}

@end
