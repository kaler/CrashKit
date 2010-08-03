//
//  CrashLogger.h
//  CrashKit
//
//  Created by Parveen Kaler on 10-08-03.
//  Copyright 2010 Smartful Studios Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CrashLogger : NSObject 
{
}

@end

@interface CrashEmailLogger : CrashLogger
{
  NSString *email;
}

- (id)initWithEmail:(NSString *)toEmail;

@property (nonatomic, copy) NSString *email;

@end
