//
//  CrashLogger.m
//  CrashKit
//
//  Created by Parveen Kaler on 10-08-03.
//  Copyright 2010 Smartful Studios Inc. All rights reserved.
//

#import "CrashLogger.h"


@implementation CrashLogger

@end

@implementation CrashEmailLogger
@synthesize email;

- (id)initWithEmail:(NSString*)toEmail
{
  if ((self = [super init]))
  {
    email = [[NSString alloc] initWithString:toEmail];
  }
  
  return self;
}

- (void)dealloc
{
  [email release];
  [super dealloc];
}

@end
