//
//  CrashController.m
//  CrashKit
//
//  Created by Parveen Kaler on 10-08-02.
//  Copyright 2010 Smartful Studios Inc. All rights reserved.
//

#import "CrashController.h"
#include <signal.h>

static CrashController *sharedInstance = nil;

#pragma mark C Functions 
void sighandler(int signal)
{
}

@implementation CrashController

#pragma mark Singleton methods

+ (CrashController*)sharedInstance
{
  @synchronized(self)
  {
    if (sharedInstance == nil)
      sharedInstance = [[CrashController alloc] init];
  }
  
  return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone
{
  @synchronized(self)
  {
    if (sharedInstance == nil)
    {
      sharedInstance = [super allocWithZone:zone];
      return sharedInstance;
    }
  }
  
  return nil;
}

- (id)copyWithZone:(NSZone *)zone
{
  return self;
}

- (id)retain
{
  return self;
}

- (unsigned)retainCount
{
  return UINT_MAX;
}

- (void)release {}

- (id)autorelease
{
  return self;
}

#pragma mark Lifetime methods

- (id)init
{
  if ((self = [super init]))
  {
    signal(SIGABRT, sighandler);
    signal(SIGBUS, sighandler);
    signal(SIGFPE, sighandler);
    signal(SIGILL, sighandler);
    signal(SIGPIPE, sighandler);    
    signal(SIGSEGV, sighandler);
  }
  
  return self;
}

- (void)dealloc
{
  signal(SIGABRT, SIG_DFL);
  signal(SIGBUS, SIG_DFL);
  signal(SIGFPE, SIG_DFL);
  signal(SIGILL, SIG_DFL);
  signal(SIGPIPE, SIG_DFL);    
  signal(SIGSEGV, SIG_DFL);
  
  [super dealloc];
}

@end
