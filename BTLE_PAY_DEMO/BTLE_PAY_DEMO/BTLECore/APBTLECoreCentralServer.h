//
//  APBTLECoreCentralServer.h
//  BTLE_PAY_DEMO
//
//  Created by Michael Hanyee on 13-10-13.
//  Copyright (c) 2013年 Michael Hanyee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "APBTLECoreDelegate.h"

@interface APBTLECoreCentralServer : NSObject

@property (nonatomic) id <APBTLECoreDelegate>            delegate;

- (void) createCentralManagerWithUUIDStrings:(NSArray *) uuidStrings;
- (void) scan;
- (void) stopScan;

@end