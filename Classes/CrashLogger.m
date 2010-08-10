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
@synthesize urlString, user, project, area;

- (id)initWithURL:(NSString*)aUrl user:(NSString *)aUser project:(NSString *)aProject area:(NSString *)aArea
{
  if ((self = [super init]))
  {
    urlString = [aUrl copy];
    user = [aUser copy];
    project = [aProject copy];
    area = [aArea copy];
  }
  
  return self;
}

- (void)dealloc
{
  [urlString release];
  [user release];
  [project release];
  [area release];
  
  [super dealloc];
}


- (NSString*)urlEncodeString:(NSString *)str
{
  NSString * encodedString = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                 (CFStringRef)str,
                                                                                 NULL,
                                                                                 (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                 kCFStringEncodingUTF8 );
  return encodedString;
}

- (NSString*)createPostParametersStringWithDescription:(NSString*)description extra:(NSString*)extra
{
  NSString *fmt = @"cmd=new&sScoutDescription=%@&sProject=%@&sArea=%@&sScoutMessage=%@";
  NSString *str = [NSString stringWithFormat:fmt, description, self.project, self.area, extra];
  
  return [self urlEncodeString:str];
}


- (void)sendCrash:(NSDictionary *)crash
{
  NSString *post = [self createPostParametersStringWithDescription:[crash objectForKey:@"Title"] extra:[crash description]];
  NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@", self.urlString, post]];
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
  [request setHTTPMethod:@"GET"];

  NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
  [connection start];
  
  [self pumpRunLoop];
}



#pragma mark URL Connection Delegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response 
{
//  NSHTTPURLResponse *r = (NSHTTPURLResponse*)response;
//  NSLog(@"Did Receive Response: %@", [NSHTTPURLResponse localizedStringForStatusCode:[r statusCode]]);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
//  NSLog(@"Connection Did Fail");
  self.finishPump = YES;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
//  NSLog(@"Connection Did Finish Loading: %@", connection);
  self.finishPump = YES;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data 
{
  NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
  NSLog(@"Did receive data: %@", str);
  [str release];
}

@end

