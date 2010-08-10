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

@interface CrashBugzScoutLogger()
@property (nonatomic, retain) NSXMLParser *parser;
@end

@implementation CrashBugzScoutLogger
@synthesize token, urlString, project, area;
@synthesize parser;

- (id)initWithURL:(NSString*)aUrl user:(NSString *)aUser password:aPassword project:(NSString *)aProject area:(NSString *)aArea
{
  if ((self = [super init]))
  {
    token = [@"" copy];
    urlString = [aUrl copy];
    project = [aProject copy];
    area = [aArea copy];
    
    NSString *fmt = @"%@?cmd=logon&email=%@&password=%@";
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:fmt, aUrl, aUser, aPassword]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
    [connection start];
  }
  
  return self;
}

- (void)dealloc
{
  [token release];
  [urlString release];
  [project release];
  [area release];
  [parser release];
  
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
  NSString *fmt = @"cmd=new&sScoutDescription=%@&sProject=%@&sArea=%@&sScoutMessage=%@&token=%@";
  NSString *str = [NSString stringWithFormat:fmt, description, self.project, self.area, extra, token];
  
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
  if ([token compare:@""] == NSOrderedSame) // gonna assume it's a logon request
  {
    NSLog(@"Parse token");
    parser = [[NSXMLParser alloc] initWithData:data];
    parser.delegate = self;
    [parser parse];
  }
  else
  {
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"Response: %@", str);
    [str release];
  }
  
}

#pragma mark NSXMLParserDelegate
- (void)parser:(NSXMLParser *)parser foundCDATA:(NSData *)CDATABlock
{
  NSString *str = [[NSString alloc] initWithData:CDATABlock encoding:NSUTF8StringEncoding];
  self.token = str;
  NSLog(@"Token: %@", self.token);
  [self.parser abortParsing];
}

@end

