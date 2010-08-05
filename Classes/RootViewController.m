//
//  RootViewController.m
//  CrashKit
//
//  Created by Parveen Kaler on 10-08-04.
//  Copyright 2010 Smartful Studios Inc. All rights reserved.
//

#import "RootViewController.h"
#import "SelectCrashViewController.h"
#import "CrashController.h"
#import "CrashKitAppDelegate.h"


@implementation RootViewController

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
  return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
  static NSString *CellIdentifier = @"Cell";
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) 
  {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
  }
  
  if (indexPath.row == 0)
    cell.textLabel.text = @"Send To Email";
  else if (indexPath.row == 1)
    cell.textLabel.text = @"Send To BugzScout";
  
  return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
  CrashController *crash = [CrashController sharedInstance];
  CrashKitAppDelegate *appDelegate = (CrashKitAppDelegate*)[UIApplication sharedApplication].delegate;
  if (indexPath.row == 0)
  {
    [crash sendCrashReportsToEmail:@"crash@smartfulstudios.com"
                withViewController:appDelegate.navigationController];
  }
  else
  {
    [crash sendCrashReportsToBugzScoutURL:@"https://smartfulstudios.fogbugz.com/scoutsubmit.asp"
                                 withUser:@"Parveen Kaler"
                               forProject:@"Inbox"
                                 withArea:@"Misc"];
  }
  
  SelectCrashViewController *c = [[SelectCrashViewController alloc] initWithStyle:UITableViewStylePlain];
  [self.navigationController pushViewController:c animated:YES];
  [c release];
}

- (void)dealloc 
{
  [super dealloc];
}


@end

