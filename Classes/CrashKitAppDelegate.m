//
//  CrashKitAppDelegate.m
//  CrashKit
//
//  Created by Parveen Kaler on 10-08-02.
//  Copyright Smartful Studios Inc 2010. All rights reserved.
//

#import "CrashKitAppDelegate.h"
#import "CrashController.h"
#include <unistd.h>

@implementation CrashKitAppDelegate

@synthesize window;

- (void)sigabrt
{
  abort();
}

- (void)sigbus
{
  void (*func)() = 0;
  func();
}

- (void)sigfpe
{
  int zero = 0;  // LLVM is smart and actually catches divide by zero if it is constant
  int i = 10/zero;
  NSLog(@"Int: %i", i);
}

- (void)sigill
{
  typedef void(*FUNC)(void);
  const static unsigned char insn[4] = { 0xff, 0xff, 0xff, 0xff };
  void (*func)() = (FUNC)insn;
  func();
}

- (void)sigpipe
{
  // Hmm, can't actually generate a SIGPIPE.
  FILE *f = popen("ls", "r");
  const char *buf[128];
  pwrite(fileno(f), buf, 128, 0);
}

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{    
  [window makeKeyAndVisible];
	
  [CrashController sharedInstance];

//  [self performSelector:@selector(sigabrt) withObject:nil afterDelay:0.1];
//  [self performSelector:@selector(sigbus) withObject:nil afterDelay:0.1];
//  [self performSelector:@selector(sigfpe) withObject:nil afterDelay:0.1];
//  [self performSelector:@selector(sigill) withObject:nil afterDelay:0.1];
  [self performSelector:@selector(sigpipe) withObject:nil afterDelay:0.1];
  
	return YES;
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
  [window release];
  [super dealloc];
}


@end
