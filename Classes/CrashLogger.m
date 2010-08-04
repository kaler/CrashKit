//
//  CrashLogger.m
//  CrashKit
//
//  Created by Parveen Kaler on 10-08-03.
//  Copyright 2010 Smartful Studios Inc. All rights reserved.
//

#import "CrashLogger.h"

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -

@implementation CrashLogger
@synthesize finishPump;

- (id)init
{
  if ((self = [super init]))
  {
    finishPump = NO;
  }
  
  return self;
}

- (void)sendCrash:(NSDictionary*)crash
{
  // Do nothing
}

- (void)pumpRunLoop
{
  CFRunLoopRef runLoop = CFRunLoopGetCurrent();
	CFArrayRef runLoopModesRef = CFRunLoopCopyAllModes(runLoop);
  NSArray * runLoopModes = (NSArray*)runLoopModesRef;
	
	while (finishPump == NO)
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

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -

@interface CrashEmailLogger()
@property (nonatomic, copy) NSString *email;
@property (nonatomic, retain) UIViewController *rootViewController;
@end


@implementation CrashEmailLogger
@synthesize email, rootViewController;

- (id)initWithEmail:(NSString*)toEmail viewController:(UIViewController*)aViewController
{
  if ((self = [super init]))
  {
    email = [[NSString alloc] initWithString:toEmail];
    rootViewController = [aViewController retain];
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
    
    self.finishPump = NO;
    [self pumpRunLoop];
  }
  else
  {
    NSLog(@"Can Not Send Email");
  }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
  self.finishPump = YES;
  [self.rootViewController dismissModalViewControllerAnimated:NO];
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -

@implementation CrashBugzScoutLogger
@synthesize url, user, project, area;

- (id)initWithURL:(NSString*)aUrl user:(NSString *)aUser project:(NSString *)aProject area:(NSString *)aArea
{
  if ((self = [super init]))
  {
    url = [aUrl copy];
    user = [aUser copy];
    project = [aProject copy];
    area = [aArea copy];
  }
  
  return self;
}

- (void)dealloc
{
  [url release];
  [user release];
  [project release];
  [area release];
  
  [super dealloc];
}

- (void)sendCrash:(NSDictionary *)crash
{
  NSLog(@"CrashBugzScoutLogger sendCrash: %@, %@, %@, %@", self.url, self.user, self.project, self.area);
  [self pumpRunLoop];
  
  self.finishPump = YES;
}

@end

