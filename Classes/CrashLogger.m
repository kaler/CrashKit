//
//  CrashLogger.m
//  CrashKit
//
//  Created by Parveen Kaler on 10-08-03.
//  Copyright 2010 Smartful Studios Inc. All rights reserved.
//

#import "CrashLogger.h"

@implementation CrashLogger

- (void)sendCrash:(NSDictionary*)crash
{
  // Do nothing
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -

@interface CrashEmailLogger()
- (void)pumpRunLoop;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, retain) UIViewController *rootViewController;
@property BOOL sendEmailDone;
@end


@implementation CrashEmailLogger
@synthesize email, rootViewController, sendEmailDone;

- (id)initWithEmail:(NSString*)toEmail viewController:(UIViewController*)aViewController
{
  if ((self = [super init]))
  {
    email = [[NSString alloc] initWithString:toEmail];
    rootViewController = [aViewController retain];
    sendEmailDone = FALSE;
  }
  
  return self;
}

- (void)dealloc
{
  [email release];
  [rootViewController release];
  [super dealloc];
}

- (void)sendCrash:(NSDictionary*)crash
{
  if ([MFMailComposeViewController canSendMail])
  {
    NSLog(@"Can Send Email");
    
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    
    [picker setSubject:@"Crash Report"];
    NSArray *toRecipients = [NSArray arrayWithObject:self.email]; 
    [picker setToRecipients:toRecipients];
    
    NSString *error;
    NSData *data = [NSPropertyListSerialization dataFromPropertyList:crash 
                                                              format:NSPropertyListBinaryFormat_v1_0 
                                                    errorDescription:&error];
    [picker addAttachmentData:data mimeType:@"text/plain" fileName:@"CrashReport"];
    
    NSLog(@"ViewController: %@", self.rootViewController.title);
    [self.rootViewController presentModalViewController:picker animated:YES];
    [picker release];
    
    self.sendEmailDone = FALSE;
    [self pumpRunLoop];
  }
  else
  {
    NSLog(@"Can Not Send Email");
  }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
  self.sendEmailDone = TRUE;
  [self.rootViewController dismissModalViewControllerAnimated:NO];
}

- (void)pumpRunLoop
{
  CFRunLoopRef runLoop = CFRunLoopGetCurrent();
	CFArrayRef runLoopModesRef = CFRunLoopCopyAllModes(runLoop);
  NSArray * runLoopModes = (NSArray*)runLoopModesRef;
	
	while (!sendEmailDone)
	{
		for (NSString *mode in runLoopModes)
		{
      CFStringRef modeRef = (CFStringRef)mode;
			CFRunLoopRunInMode(modeRef, 1.0f/120.0f, false);  // Pump the loop at 120 FPS
		}
	}
	
	CFRelease(runLoopModesRef);
}  

@end
