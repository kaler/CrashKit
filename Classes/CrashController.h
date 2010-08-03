//
//  CrashController.h
//  CrashKit
//
//  Created by Parveen Kaler on 10-08-02.
//  Copyright 2010 Smartful Studios Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CrashController : NSObject {

}

+ (CrashController*)sharedInstance;

- (NSArray*)callstackAsArray;
@end
