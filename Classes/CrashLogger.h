//
//  CrashLogger.h
//  CrashKit
//
//  Created by Parveen Kaler on 10-08-03.
//  Copyright 2010 Smartful Studios Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@interface CrashLogger : NSObject 
{
}

- (void)sendCrash:(NSDictionary*)crash;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@interface CrashEmailLogger : CrashLogger <MFMailComposeViewControllerDelegate>
{
  NSString *email;
  UIViewController *rootViewController;
  
  BOOL sendEmailDone;
}

- (id)initWithEmail:(NSString *)toEmail viewController:(UIViewController*)rootViewController;
- (void)sendCrash:(NSDictionary*)crash;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@interface CrashBugzScoutLogger : CrashLogger
{
  NSString *url;
  NSString *user;
  NSString *project;
  NSString *area;
}

- (id)initWithURL:(NSString*)aURL user:(NSString*)aUser project:(NSString*)aProject area:(NSString*)aArea;
- (void)sendCrash:(NSDictionary*)crash;

@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *user;
@property (nonatomic, copy) NSString *project;
@property (nonatomic, copy) NSString *area;

@end
