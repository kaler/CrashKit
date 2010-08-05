//
//  SelectCrashViewController.m
//  CrashKit
//
//  Created by Parveen Kaler on 10-08-04.
//  Copyright 2010 Smartful Studios Inc. All rights reserved.
//

#import "SelectCrashViewController.h"
#include <unistd.h>

@implementation SelectCrashViewController

#pragma mark -
#pragma mark Test Methods

- (void)sigabrt
{
  abort();
}

- (void)sigbus
{
  void (*func)() = 0;
  func();
}

- (void)sigfpe
{
  int zero = 0;  // LLVM is smart and actually catches divide by zero if it is constant
  int i = 10/zero;
  NSLog(@"Int: %i", i);
}

- (void)sigill
{
  typedef void(*FUNC)(void);
  const static unsigned char insn[4] = { 0xff, 0xff, 0xff, 0xff };
  void (*func)() = (FUNC)insn;
  func();
}

- (void)sigpipe
{
  // Hmm, can't actually generate a SIGPIPE.
  FILE *f = popen("ls", "r");
  const char *buf[128];
  pwrite(fileno(f), buf, 128, 0);
}

- (void)sigsegv
{
  // This actually raises a SIGBUS.
  NSString *str = [[NSString alloc] initWithUTF8String:"SIGSEGV STRING"];
  [str release];
  NSLog(@"String %@", str);
}

- (void)throwNSException
{
  NSException *e = [NSException exceptionWithName:@"TestException" reason:@"Testing CrashKit" userInfo:nil];
  @throw e;
}  

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
  return 7;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
  static NSString *CellIdentifier = @"Cell";
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
  }
  
  static NSString* labels[] =
  {
    @"SIGABRT",
    @"SIGBUS",
    @"SIGFPE",
    @"SIGILL",
    @"SIGPIPE",
    @"SIGSEGV",
    @"NSException"
  };
  
  cell.textLabel.text = labels[indexPath.row];
  
  return cell;
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
  switch (indexPath.row) 
  {
    case 0:
      [self sigabrt];
      break;
    case 1:
      [self sigbus];
      break;
    case 2:
      [self sigfpe];
      break;
    case 3:
      [self sigill];
      break;
    case 4:
      [self sigpipe];
      break;
    case 5:
      [self sigsegv];
      break;
    case 6:
      [self throwNSException];
      break;
    default:
      NSLog(@"WTF?  Unhandled case.");
      break;
  }
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc 
{
  [super dealloc];
}

@end

