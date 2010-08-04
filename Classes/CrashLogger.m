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
  }
  else
  {
    NSLog(@"Can Not Send Email");
  }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
  [self.rootViewController dismissModalViewControllerAnimated:NO];
}

@end
