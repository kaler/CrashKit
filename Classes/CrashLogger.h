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
  BOOL finishPump;
}

- (void)sendCrash:(NSDictionary*)crash;
- (void)pumpRunLoop;

@property BOOL finishPump;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@interface CrashEmailLogger : CrashLogger <MFMailComposeViewControllerDelegate>
{
  NSString *email;
  UIViewController *rootViewController;
}

- (id)initWithEmail:(NSString *)toEmail viewController:(UIViewController*)rootViewController;
- (void)sendCrash:(NSDictionary*)crash;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
@interface CrashBugzScoutLogger : CrashLogger <NSXMLParserDelegate>
{
  NSString *token;
  NSString *urlString;
  NSString *project;
  NSString *area;
  NSXMLParser *parser;
}

- (id)initWithURL:(NSString*)aURL user:(NSString*)aUser password:(NSString*)aPassword project:(NSString*)aProject area:(NSString*)aArea;
- (void)sendCrash:(NSDictionary*)crash;

@property (nonatomic, copy) NSString *token;
@property (nonatomic, copy) NSString *urlString;
@property (nonatomic, copy) NSString *project;
@property (nonatomic, copy) NSString *area;

@end
