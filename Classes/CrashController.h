//
//  CrashController.h
//  CrashKit
//
//  Created by Parveen Kaler on 10-08-02.
//  Copyright 2010 Smartful Studios Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CrashLogger;

@protocol CrashSaveDelegate
- (void)onCrash;
@end

@interface CrashController : NSObject 
{
  CrashLogger *logger;
  id <CrashSaveDelegate> delegate;
}

+ (CrashController*)sharedInstance;
- (void)sendCrashReportsToEmail:(NSString*)toEmail withViewController:(UIViewController*)rootViewController;
- (void)sendCrashReportsToBugzScoutURL:(NSString*)aURL withUser:(NSString*)aUser password:(NSString*)aPassword forProject:(NSString*)aProject withArea:(NSString*)aArea;

- (NSArray*)callstackAsArray;
- (void)handleSignal:(NSDictionary*)userInfo;
- (void)handleNSException:(NSDictionary*)userInfo;

@property (nonatomic, assign) id <CrashSaveDelegate> delegate;

@end
