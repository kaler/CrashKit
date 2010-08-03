//
//  CrashController.m
//  CrashKit
//
//  Created by Parveen Kaler on 10-08-02.
//  Copyright 2010 Smartful Studios Inc. All rights reserved.
//

#import "CrashController.h"
#include <signal.h>
#include <execinfo.h>

static CrashController *sharedInstance = nil;

#pragma mark C Functions 
void sighandler(int signal)
{
  const char* names[NSIG];
  names[SIGABRT] = "SIGABRT";
  names[SIGBUS] = "SIGBUS";
  names[SIGFPE] = "SIGFPE";
  names[SIGILL] = "SIGILL";
  names[SIGPIPE] = "SIGPIPE";
  names[SIGSEGV] = "SIGSEGV";

  NSArray *arr = [[CrashController sharedInstance] callstackAsArray];
  NSLog(@"Signal: %s", names[signal]);
  NSLog(@"Callstack: %@", arr);
  
  exit(signal);
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

#pragma mark methods
- (NSArray*)callstackAsArray
{
  void* callstack[128];
  const int numFrames = backtrace(callstack, 128);
  char **symbols = backtrace_symbols(callstack, numFrames);
  
  // Need to ignore the top frames which will be this function
  // and sig trap interrupt function calls
  int bottom = 3;
  NSMutableArray *arr = [NSMutableArray arrayWithCapacity:numFrames - bottom];
  for (int i = bottom; i < numFrames; ++i) 
  {
    [arr addObject:[NSString stringWithUTF8String:symbols[i]]];
  }
  
  free(symbols);
  
  return arr;
}

@end
