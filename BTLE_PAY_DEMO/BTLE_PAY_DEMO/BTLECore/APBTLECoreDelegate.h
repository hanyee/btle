//
//  APBTLECoreDelegate.h
//  BTLE_PAY_DEMO
//
//  Created by Michael Hanyee on 13-10-14.
//  Copyright (c) 2013年 Michael Hanyee. All rights reserved.
//

#define DEFAULT_TRANSFER_SERVICE_UUID           @"E20A39F4-73F5-4BC4-A12F-17D1AD07A961"
#define DEFAULT_TRANSFER_CHARACTERISTIC_UUID    @"08590F7E-DB05-467E-8757-72F6FAEB13D4"
#define ALIPAY_BTLE_END_OF_SIGNAL               @"EOAPS"
#define NOTIFY_MTU                              20
#define DEFAULT_CHARACTERISTIC_UUID             [CBUUID UUIDWithString:DEFAULT_TRANSFER_CHARACTERISTIC_UUID]

#import <CoreBluetooth/CoreBluetooth.h>
#import <Foundation/Foundation.h>

@protocol APBTLECoreDelegate <NSObject>

@required

@optional

- (void) centralManagerPoweredOn;
- (void) dataReceived:(NSData *) data;
- (void) centralManagerDidDestroyed;



- (void) peripheralManagerPoweredOn;
- (void) isReadyToSendData;
- (void) dataDidSend;
- (void) peripheralManagerDidDestroyed;

@end
