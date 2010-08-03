//
//  CrashController.h
//  CrashKit
//
//  Created by Parveen Kaler on 10-08-02.
//  Copyright 2010 Smartful Studios Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CrashLogger;

@interface CrashController : NSObject 
{
  CrashLogger *logger;
}

+ (CrashController*)sharedInstance;
- (void)sendCrashReportsToEmail:(NSString*)toEmail;

- (NSArray*)callstackAsArray;
- (void)handleSignal:(NSDictionary*)userInfo;
- (void)handleNSException:(NSDictionary*)userInfo;

@end
