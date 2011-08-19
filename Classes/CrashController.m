//
//  CrashController.m
//  CrashKit
//
//  Created by Parveen Kaler on 10-08-02.
//  Copyright 2010 Smartful Studios Inc. All rights reserved.
//

#import "CrashController.h"
#import "CrashLogger.h"
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
  
  CrashController *crash = [CrashController sharedInstance];
  NSArray *arr = [crash callstackAsArray];
  NSString *title = [NSString stringWithFormat:@"Crash: %@", [arr objectAtIndex:6]];  // The 6th frame is where the crash happens
  
  NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:arr, @"Callstack",
                                                                      title, @"Title",
                                                                      [NSNumber numberWithInt:signal], @"Signal",
                                                                      [NSString stringWithUTF8String:names[signal]], @"Signal Name",
                                                                      nil];
  [crash performSelectorOnMainThread:@selector(handleSignal:) withObject:userInfo waitUntilDone:YES];
}

void uncaughtExceptionHandler(NSException *exception)
{
  CrashController *crash = [CrashController sharedInstance];
  NSArray *arr = [crash callstackAsArray];
  NSString *title = [NSString stringWithFormat:@"Exception: %@", [arr objectAtIndex:8]];  // The 8th frame is where the exception is thrown
  NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:arr, @"Callstack",
                                                                      title, @"Title",
                                                                      exception, @"Exception",
                                                                      nil];
  [crash performSelectorOnMainThread:@selector(handleNSException:) withObject:userInfo waitUntilDone:YES];
}

@interface CrashController()
@property (nonatomic, retain) CrashLogger *logger;
@end

@implementation CrashController
@synthesize logger, delegate;

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
    
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    
    logger = [[CrashLogger alloc] init];
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
  
  NSSetUncaughtExceptionHandler(NULL);
  
  [logger release];
  [super dealloc];
}

#pragma mark methods
- (void)sendCrashReportsToEmail:(NSString*)toEmail withViewController:(UIViewController*)rootViewController
{
  self.logger = [[CrashEmailLogger alloc] initWithEmail:toEmail viewController:rootViewController];
}

- (void)sendCrashReportsToBugzScoutURL:(NSString*)aURL withUser:(NSString*)aUser password:(NSString*)aPassword forProject:(NSString*)aProject withArea:(NSString*)aArea;
{
  self.logger = [[CrashBugzScoutLogger alloc] initWithURL:aURL user:aUser password:aPassword project:aProject area:aArea];
}

- (NSArray*)callstackAsArray
{
  void* callstack[128];
  const int numFrames = backtrace(callstack, 128);
  assert(numFrames >= 0);
  char **symbols = backtrace_symbols(callstack, numFrames);
  
  NSMutableArray *arr = [NSMutableArray arrayWithCapacity:(numFrames >= 0 ? (NSUInteger)numFrames : 0)];
  for (int i = 0; i < numFrames; ++i) 
  {
    [arr addObject:[NSString stringWithUTF8String:symbols[i]]];
  }
  
  free(symbols);
  
  return arr;
}

- (void)handleSignal:(NSDictionary*)userInfo
{  
  if (self.delegate)
    [self.delegate onCrash];

  [self.logger sendCrash:userInfo];
}

- (void)handleNSException:(NSDictionary*)userInfo
{
  if (self.delegate)
    [self.delegate onCrash];
  
  [self.logger sendCrash:userInfo];
}

@end
