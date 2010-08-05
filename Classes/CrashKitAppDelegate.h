//
//  CrashKitAppDelegate.h
//  CrashKit
//
//  Created by Parveen Kaler on 10-08-02.
//  Copyright Smartful Studios Inc 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CrashController.h"

@interface CrashKitAppDelegate : NSObject <UIApplicationDelegate, CrashSaveDelegate> 
{
  UIWindow *window;
  UINavigationController *navigationController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@end

