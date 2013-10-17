//
//  APBTLECoreCentralServer.m
//  BTLE_PAY_DEMO
//
//  Created by Michael Hanyee on 13-10-13.
//  Copyright (c) 2013年 Michael Hanyee. All rights reserved.
//

#import "APBTLECoreCentralServer.h"

@interface APBTLECoreCentralServer() <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (strong, nonatomic) CBCentralManager          *centralManager;
@property dispatch_queue_t                              centralManagerQueue;
@property (strong, nonatomic) NSString                  *deviceUID;
@property (strong, nonatomic) NSArray                   *serviceUUIDs;
@property (strong, nonatomic) NSArray                   *serviceUUIDStrings;
@property (strong, nonatomic) CBPeripheral              *discoveredPeripheral;
@property (strong, nonatomic) CBPeripheral              *connectedPeripheral;
@property (strong, nonatomic) NSMutableData             *receivedData;
@property (strong, nonatomic) NSString                  *receivedDataString;


@end




@implementation APBTLECoreCentralServer


- (id) init {
    self = [super init];
    
    if (self) {
        self.centralManagerQueue = nil;
        self.deviceUID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    }
    
    return self;
}

- (NSArray *) stringToUUID:(NSArray *) uuidStrings{
    NSMutableArray *uuidArr = [[NSMutableArray alloc] init];
    
    for (NSString *uuid in uuidStrings) {
        [uuidArr addObject:[CBUUID UUIDWithString:uuid]];
    }
    
    return uuidArr;
}



// central mode
#pragma mark - central mode
- (void) createCentralManager {
    self.receivedData = [[NSMutableData alloc] init];
    [self.receivedData setLength:0];
    self.serviceUUIDs = nil;
    self.serviceUUIDStrings = nil;
    
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:self.centralManagerQueue];
    NSLog(@"central manager created!");
}

- (void) createCentralManagerWithUUIDStrings:(NSArray *) uuidStrings{
    if (!self.centralManager) {
        [self createCentralManager];
    }
    self.serviceUUIDStrings = uuidStrings;
    self.serviceUUIDs = [self stringToUUID:uuidStrings];
}


- (void) scan {
    
    if (self.centralManager.state != CBCentralManagerStatePoweredOn) {
        return ;
    }
    
    [self.centralManager scanForPeripheralsWithServices:self.serviceUUIDs
                                                options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
    
    NSLog(@"central manager started scanning with uuids: %@", self.serviceUUIDStrings);
}

- (void) stopScan {
    if (self.centralManager && self.centralManager.state == CBCentralManagerStatePoweredOn) {
        [self.centralManager stopScan];
        NSLog(@"Scanning stopped");
    }
}


// centralManagerDidUpdateState is a required protocol method.
- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    NSLog(@"centralManagerDidUpdateState : %d", central.state);
    
    if (central.state != CBCentralManagerStatePoweredOn) {
        // In a real app, you'd deal with all the states correctly
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(centralManagerPoweredOn)]) {
        [self.delegate centralManagerPoweredOn];
    }else{
        // do scan
        [self scan];
    }
    
    //    if (self.serviceUUIDStrings) {
    //        [self scanWithUUID:self.serviceUUIDStrings];
    //    }
    //    [self scanWithUUID:nil];
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSLog(@"Discovered %@ at %@", peripheral.name, RSSI);
    
    // TODO: detect the closest device
    
    //    self.discoveredPeripheral = peripheral;
    
    // end TODO:
    
    
    if (self.discoveredPeripheral != peripheral) {
        
        // Save a local copy of the peripheral, so CoreBluetooth doesn't get rid of it
        self.discoveredPeripheral = peripheral;
        
        // And connect
        // connect the closest peripheral device
        NSLog(@"Connecting to peripheral %@", peripheral.name);
        [self.centralManager connectPeripheral:peripheral options:@{CBConnectPeripheralOptionNotifyOnConnectionKey: @YES}];
    }
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"Failed to connect to %@. (%@)", peripheral, [error localizedDescription]);
    [self cleanup];
}

/** We've connected to the peripheral, now we need to discover the services and characteristics to find the 'transfer' characteristic.
 */
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    NSLog(@"Peripheral Connected");
    
    // Stop scanning
    [self stopScan];
    
    self.connectedPeripheral = peripheral;
    
    // release the discoveredPeripheral
    self.discoveredPeripheral = nil;
    
    // Clear the data that we may already have
    //    [self.receivedData setLength:0];
    
    // Make sure we get the discovery callbacks
    self.connectedPeripheral.delegate = self;
    //    peripheral.delegate = self;
    
    // Search only for services that match our UUID
    if (self.serviceUUIDs.count > 0) {
        [peripheral discoverServices:self.serviceUUIDs];
    }else{
        [peripheral discoverServices:nil];
    }
}


- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    NSLog(@"Services discovered!");
    if (error) {
        NSLog(@"Error discovering services: %@", [error localizedDescription]);
        [self cleanup];
        return;
    }
    
    // Discover the characteristic we want...
    NSLog(@"Discover the characteristic we want...");
    // Loop through the newly filled peripheral.services array, just in case there's more than one.
    for (CBService *service in peripheral.services) {
//        [peripheral discoverCharacteristics:@[self.defaultCharacteristicUUID] forService:service];
        [peripheral discoverCharacteristics:@[DEFAULT_CHARACTERISTIC_UUID] forService:service];
    }
}

/** The Transfer characteristic was discovered.
 *  Once this has been found, we want to subscribe to it, which lets the peripheral know we want the data it contains
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    NSLog(@"Characteristics For Service discovered!");
    // Deal with errors (if any)
    if (error) {
        NSLog(@"Error discovering characteristics: %@", [error localizedDescription]);
        [self cleanup];
        return;
    }
    
    // Clear the data that we may already have
    //    [self.receivedData setLength:0];
    
    // Again, we loop through the array, just in case.
    for (CBCharacteristic *characteristic in service.characteristics) {
        // And check if it's the right one
//        if ([characteristic.UUID isEqual:self.defaultCharacteristicUUID]) {
        if ([characteristic.UUID isEqual:DEFAULT_CHARACTERISTIC_UUID]) {
            // If it is, subscribe to it
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
    }
    
    // Once this is complete, we just need to wait for the data to come in.
}


/** This callback lets us know more data has arrived via notification on the characteristic
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"Updating Value For Characteristic...");
    if (error) {
        NSLog(@"Error discovering characteristics: %@", [error localizedDescription]);
        return;
    }
    
    NSString *stringFromData = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
    
    // Have we got everything we need?
    if ([stringFromData isEqualToString:ALIPAY_BTLE_END_OF_SIGNAL]) {
        
        // save the key
        
        self.receivedDataString = [[NSString alloc] initWithData:self.receivedData encoding:NSUTF8StringEncoding];
        NSLog(@"final received data is receivedDataString : %@", self.receivedDataString);
        
        [self.delegate dataReceived:self.receivedData];
        
        // Clear the data that we may already have
        [self.receivedData setLength:0];
        
        // disconnect
        //        [self disConnectPeripheral:peripheral];
        
        // Cancel our subscription to the characteristic
        //        [peripheral setNotifyValue:NO forCharacteristic:characteristic];
        
        // and disconnect from the peripehral
        //        [self.centralManager cancelPeripheralConnection:peripheral];
    }else{
        // Otherwise, just add the data on to what we already have
        [self.receivedData appendData:characteristic.value];
    }
    
    // Log it
    NSLog(@"Received: %@", stringFromData);
}


/** The peripheral letting us know whether our subscribe/unsubscribe happened or not
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"peripheral Updating Notification State For Characteristic....");
    if (error) {
        NSLog(@"Error changing notification state: %@", error.localizedDescription);
    }
    
    // Exit if it's not the transfer characteristic
    
//    if (![characteristic.UUID isEqual:self.defaultCharacteristicUUID]) {
    if (![characteristic.UUID isEqual:DEFAULT_CHARACTERISTIC_UUID]) {
        return;
    }
    
    // Notification has started
    if (characteristic.isNotifying) {
        NSLog(@"Notification began on %@", characteristic.value);
    }
    
    // Notification has stopped
    else {
        // so disconnect from the peripheral
        NSLog(@"Notification stopped on %@.  Disconnecting", characteristic);
        [self.centralManager cancelPeripheralConnection:peripheral];
    }
}


/** Once the disconnection happens, we need to clean up our local copy of the peripheral
 */
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"Peripheral Disconnected");
    
    [self disConnectPeripheral];
}


- (void) disConnectPeripheral {
    [self cleanup];
    self.connectedPeripheral = nil;
}

- (void)cleanup
{
    // Don't do anything if we're not connected
    if (!self.connectedPeripheral.isConnected) {
        return;
    }
    
    // See if we are subscribed to a characteristic on the peripheral
    if (self.connectedPeripheral.services != nil) {
        for (CBService *service in self.connectedPeripheral.services) {
            if (service.characteristics != nil) {
                for (CBCharacteristic *characteristic in service.characteristics) {
                    //                    if (characteristic.isNotifying) {
                    // It is notifying, so unsubscribe
                    [self.connectedPeripheral setNotifyValue:NO forCharacteristic:characteristic];
                    // And we're done.
                    //                        return;
                    //                    }
                }
            }
        }
    }
    
    // If we've got this far, we're connected, but we're not subscribed, so we just disconnect
    [self.centralManager cancelPeripheralConnection:self.connectedPeripheral];
}


@end
