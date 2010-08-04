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

@synthesize window, rootViewController;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{
  [window makeKeyAndVisible];
	
  CrashController *crash = [CrashController sharedInstance];
  [crash sendCrashReportsToEmail:@"crash@smartfulstudios.com"
              withViewController:rootViewController];
  crash.delegate = self;
  

  [self performSelector:@selector(sigabrt) withObject:nil afterDelay:0.1];
//  [self performSelector:@selector(sigbus) withObject:nil afterDelay:0.1];
//  [self performSelector:@selector(sigfpe) withObject:nil afterDelay:0.1];
//  [self performSelector:@selector(sigill) withObject:nil afterDelay:0.1];
//  [self performSelector:@selector(sigpipe) withObject:nil afterDelay:0.1];
//  [self performSelector:@selector(sigsegv) withObject:nil afterDelay:0.1];
//  [self performSelector:@selector(throwNSException) withObject:nil afterDelay:0.1];
  
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

- (void)dealloc {
  [window release];
  [super dealloc];
}

#pragma mark -
#pragma mark Test Methods

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

- (void)sigsegv
{
  // This actually raises a SIGBUS.
  NSString *str = [[NSString alloc] initWithUTF8String:"SIGSEGV STRING"];
  [str release];
  NSLog(@"String %@", str);
}

- (void)throwNSException
{
  NSException *e = [NSException exceptionWithName:@"TestException" reason:@"Testing CrashKit" userInfo:nil];
  @throw e;
}  



@end
