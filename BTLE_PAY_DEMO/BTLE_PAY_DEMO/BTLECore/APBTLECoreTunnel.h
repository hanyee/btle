//
//  APBTLECoreTunnel.h
//  BTLE_PAY_DEMO
//
//  Created by Michael Hanyee on 13-9-26.
//  Copyright (c) 2013年 Michael Hanyee. All rights reserved.
//

#define DEFAULT_TRANSFER_SERVICE_UUID           @"E20A39F4-73F5-4BC4-A12F-17D1AD07A961"
#define DEFAULT_TRANSFER_CHARACTERISTIC_UUID    @"08590F7E-DB05-467E-8757-72F6FAEB13D4"
#define ALIPAY_BTLE_END_OF_SIGNAL               @"EOAPS"
#define NOTIFY_MTU                              20

#import <CoreBluetooth/CoreBluetooth.h>
#import <Foundation/Foundation.h>


@protocol APBTLECoreTunnelDelegate <NSObject>

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










@interface APBTLECoreTunnel : NSObject

@property (nonatomic) id <APBTLECoreTunnelDelegate>            delegate;

@property (strong, nonatomic) NSMutableData                    *dataToSend;




//- (void) createCentralManager;
- (void) createCentralManagerWithUUIDStrings:(NSArray *) uuidStrings;
- (void) scan;
- (void) scanWithUUID:(NSArray *)uuidStrings;
- (void) stopScan;
- (void) cleanup;
- (void) disConnectPeripheral;
- (void) destroyCentralManager;


//- (void) createPeripheralManager;
- (void) createPeripheralManagerWithUUIDStrings:(NSArray *) uuidStrings;
- (void) startAdvertising;
- (void) startAdvertisingWithUUID:(NSArray *) uuidStrings;
- (void) stopAdvertising;
- (void) addPeripheralServiceWithUUID:(NSArray *) uuidStrings;
- (void) sendData;
- (void) destroyPeripheralManager;


// TUNNEL
- (void) startTunnelWithUUID:(NSString *) uuidString;
@end