//
//  APBTLECoreTunnel.m
//  BTLE_PAY_DEMO
//
//  Created by Michael Hanyee on 13-9-26.
//  Copyright (c) 2013年 Michael Hanyee. All rights reserved.
//

//#import <CoreBluetooth/CoreBluetooth.h>
#import "APBTLECoreTunnel.h"

@interface APBTLECoreTunnel () <CBCentralManagerDelegate, CBPeripheralManagerDelegate, CBPeripheralDelegate>{
    dispatch_queue_t centralManagerQueue;
    dispatch_queue_t peripheralManagerQueue;
}



@property (strong, nonatomic) CBCentralManager      *centralManager;
@property (strong, nonatomic) CBPeripheral          *discoveredPeripheral;
@property (strong, nonatomic) CBPeripheral          *connectedPeripheral;
@property (strong, nonatomic) CBUUID                *defaultCharacteristicUUID;
@property (strong, nonatomic) NSArray               *serviceUUIDs;
@property (strong, nonatomic) NSArray               *serviceUUIDStrings;
@property (strong, nonatomic) NSMutableData         *receivedData;
@property (strong, nonatomic) NSString              *receivedDataString;
//@property BOOL                                      transferCompleted;



@property (strong, nonatomic) CBPeripheralManager       *peripheralManager;
@property (nonatomic, readwrite) NSInteger              sendDataIndex;
@property (strong, nonatomic) NSArray                   *advertisingServiceUUIDs;
@property (strong, nonatomic) NSArray                   *advertisingServiceUUIDStrings;
@property (strong, nonatomic) CBMutableCharacteristic   *transferCharacteristic;


@property (strong, nonatomic) NSString                  *deviceUID;

@end



@implementation APBTLECoreTunnel

@synthesize delegate;
@synthesize discoveredPeripheral;
@synthesize peripheralManager;
@synthesize centralManager;
@synthesize dataToSend = _dataToSend;

- (void) setDataToSend:(NSMutableData *)dataToSend{
//    _dataToSend = [[NSMutableData alloc] initWithData:dataToSend];
    _dataToSend = dataToSend;
    self.sendDataIndex = 0;
}

- (NSArray *) stringToUUID:(NSArray *) uuidStrings{
    NSMutableArray *uuidArr = [[NSMutableArray alloc] init];
    
    for (NSString *uuid in uuidStrings) {
        [uuidArr addObject:[CBUUID UUIDWithString:uuid]];
    }

    return uuidArr;
}

- (id) init {
    self = [super init];
    
    if (self) {
        centralManagerQueue = nil;
//        peripheralManagerQueue = nil;
        peripheralManagerQueue = dispatch_queue_create("com.alipay.btle.pm.queue", DISPATCH_QUEUE_SERIAL);
        self.deviceUID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        self.defaultCharacteristicUUID = [CBUUID UUIDWithString:DEFAULT_TRANSFER_CHARACTERISTIC_UUID];
    }
    
    return self;
}



// central mode
#pragma mark - central mode
- (void) createCentralManager {
    self.receivedData = [[NSMutableData alloc] init];
//    [self.receivedData setLength:0];
    self.serviceUUIDs = nil;
    self.serviceUUIDStrings = nil;
    
    self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:centralManagerQueue];
    NSLog(@"central manager created!");
}

- (void) createCentralManagerWithUUIDStrings:(NSArray *) uuidStrings{
    if (!self.centralManager) {
        [self createCentralManager];
    }
    self.serviceUUIDStrings = uuidStrings;
    self.serviceUUIDs = [self stringToUUID:uuidStrings];
}

- (void) scanWithUUID:(NSArray *)uuidStrings {
    
    if (self.centralManager.state != CBCentralManagerStatePoweredOn) {
        return ;
    }
    
    if (nil == uuidStrings) {
        self.serviceUUIDs = nil;
        self.serviceUUIDStrings = nil;
    }else{
        self.serviceUUIDStrings = uuidStrings;
        self.serviceUUIDs = [self stringToUUID:uuidStrings];
    }
    
    [self.centralManager scanForPeripheralsWithServices:self.serviceUUIDs
                                                options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
    
    NSLog(@"central manager started scanning with uuids: %@", uuidStrings);
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
    if (self.centralManager) {
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
    
    [self.delegate centralManagerPoweredOn];
//    if (self.serviceUUIDStrings) {
//        [self scanWithUUID:self.serviceUUIDStrings];
//    }
//    [self scanWithUUID:nil];
}

/** This callback comes whenever a peripheral that is advertising the TRANSFER_SERVICE_UUID is discovered.
 *  We check the RSSI, to make sure it's close enough that we're interested in it, and if it is,
 *  we start the connection process
 */
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
        NSLog(@"Connecting to peripheral %@", peripheral);
        [self.centralManager connectPeripheral:peripheral options:nil];
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
        [peripheral discoverCharacteristics:@[self.defaultCharacteristicUUID] forService:service];
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
        if ([characteristic.UUID isEqual:self.defaultCharacteristicUUID]) {
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
    if (![characteristic.UUID isEqual:self.defaultCharacteristicUUID]) {
        return;
    }
    
    // Notification has started
    if (characteristic.isNotifying) {
        NSLog(@"Notification began on %@", characteristic);
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

- (void) disConnectPeripheral:(CBPeripheral *)peripheral{
    if (nil == peripheral) {
        peripheral = self.connectedPeripheral;
    }
    
    // Cancel our subscription to the characteristic
    for (CBService *service in peripheral.services) {
        for (CBCharacteristic *characteristic in service.characteristics) {
            [peripheral setNotifyValue:NO forCharacteristic:characteristic];
        }
    }
    
    // disconnect from the peripehral
    [self.centralManager cancelPeripheralConnection:peripheral];
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

- (void) destroyCentralManager {
    [self stopScan];
    self.serviceUUIDStrings = nil;
    self.serviceUUIDs = nil;
    self.discoveredPeripheral = nil;
    self.connectedPeripheral = nil;
    [self.receivedData setLength:0];
    self.receivedDataString = nil;
    self.centralManager = nil;
}














// peripheral mode
#pragma mark - peripheral mode

- (void) createPeripheralManager {
    self.advertisingServiceUUIDStrings = nil;
    self.advertisingServiceUUIDs = nil;
    
    self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:peripheralManagerQueue];
    NSLog(@"peripheralManager created!");
}

- (void) createPeripheralManagerWithUUIDStrings:(NSArray *) uuidStrings {
    if (!self.peripheralManager) {
        [self createPeripheralManager];
    }
    
    self.advertisingServiceUUIDStrings = uuidStrings;
    self.advertisingServiceUUIDs = [self stringToUUID:uuidStrings];
}

- (void) startAdvertisingWithUUID:(NSArray *)uuidStrings {
    if (self.peripheralManager.state != CBPeripheralManagerStatePoweredOn) {
        return ;
    }
    
    if (!self.peripheralManager.isAdvertising) {
        
        if (nil == uuidStrings) {
            self.advertisingServiceUUIDs = nil;
            self.advertisingServiceUUIDStrings = nil;
        }else{
            self.advertisingServiceUUIDStrings = uuidStrings;
            self.advertisingServiceUUIDs = [self stringToUUID:uuidStrings];
        }
        
        NSDictionary *advertisingData = @{CBAdvertisementDataLocalNameKey : self.deviceUID, CBAdvertisementDataServiceUUIDsKey : self.advertisingServiceUUIDs};
        
        [self.peripheralManager startAdvertising:advertisingData];
        
        clock_t s_pairTime =  clock();
        NSLog(@"Start advertising at %lu", s_pairTime);
    }else{
        NSLog(@"peripheralManager already exist!");
    }
}

- (void) startAdvertising {
    if (self.peripheralManager.state != CBPeripheralManagerStatePoweredOn) {
        return ;
    }
    
    if (!self.peripheralManager.isAdvertising) {
        
        NSDictionary *advertisingData = @{CBAdvertisementDataLocalNameKey : self.deviceUID, CBAdvertisementDataServiceUUIDsKey : self.advertisingServiceUUIDs};
        
        [self.peripheralManager startAdvertising:advertisingData];
        
        clock_t s_pairTime =  clock();
        NSLog(@"Start advertising at %lu", s_pairTime);
    }else{
        NSLog(@"peripheralManager already exist!");
    }
}


- (void) stopAdvertising {
    if (self.peripheralManager) {
        [self.peripheralManager stopAdvertising];
        NSLog(@"stop advertising");
    }
}

- (void) addPeripheralServiceWithUUID:(NSArray *) uuidStrings {

    self.transferCharacteristic = [[CBMutableCharacteristic alloc] initWithType:self.defaultCharacteristicUUID
                                                                     properties:CBCharacteristicPropertyNotify
                                                                          value:nil
                                                                    permissions:CBAttributePermissionsReadable];
    NSArray *uuids;
    
    if (nil == uuidStrings) {
        uuids = self.advertisingServiceUUIDs;
    }else{
        uuids = [self stringToUUID:uuidStrings];
    }
    
    for (CBUUID *uuid in uuids) {
        // Then the service
        CBMutableService *transferService = [[CBMutableService alloc] initWithType:uuid primary:YES];
        
        // Add the characteristic to the service
        transferService.characteristics = @[self.transferCharacteristic];
        
        // And add it to the peripheral manager
        [self.peripheralManager addService:transferService];
    }
    
    NSLog(@"characteristic is : %@", self.transferCharacteristic);
}


/** Required protocol method.  A full app should take care of all the possible states,
 *  but we're just waiting for  to know when the CBPeripheralManager is ready
 */
- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    NSLog(@"peripheralManagerDidUpdateState : %d", peripheral.state);
    // Opt out from any other state
    if (peripheral.state != CBPeripheralManagerStatePoweredOn) {
        return;
    }
    
    [self addPeripheralServiceWithUUID:nil];
    
    [self.delegate peripheralManagerPoweredOn];
    
//    if (self.advertisingServiceUUIDStrings) {
//        [self startAdvertisingWithUUID:self.advertisingServiceUUIDStrings];
//    }
}

/** Catch when someone subscribes to our characteristic, then start sending them data
 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic
{
    NSLog(@"Central subscribed to characteristic");
    
//    // Reset the index
//    self.sendDataIndex = 0;
//
//    // Start sending
    
//    [self.delegate peripheralManager:peripheral central:central didSubscribeToCharacteristic:characteristic];
    [self.delegate isReadyToSendData];
    
//    if (self.dataToSend.length > 0) {
//        [self sendData];
//    }
}


/** Recognise when the central unsubscribes
 */
- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic
{
    NSLog(@"Central unsubscribed from characteristic");

    [self destroyPeripheralManager];
}


/** This callback comes in when the PeripheralManager is ready to send the next chunk of data.
 *  This is to ensure that packets will arrive in the order they are sent
 */
- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral
{
    NSLog(@"sending........ again");
    // Start sending again
    [self sendData];
}



- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error{
    if (error) {
        NSLog(@"Error adding service: %@", error.localizedDescription);
    }
    
    NSLog(@"services added !! : service : %@", service);
}


- (void) destroyPeripheralManager {
    [self stopAdvertising];
    [self.peripheralManager removeAllServices];
    self.transferCharacteristic = nil;
    self.advertisingServiceUUIDs = nil;
    self.advertisingServiceUUIDStrings = nil;
    self.sendDataIndex = 0;
    [self.dataToSend setLength:0];
    self.peripheralManager = nil;
    
    NSLog(@"peripheralManager destroyed!");
}

- (void) sendData
{
    NSLog(@"doing sending!");
    // First up, check if we're meant to be sending an EOM
    static BOOL sendingEOM = NO;
    
    if (sendingEOM) {
        
        // send it
        BOOL didSend = [self.peripheralManager updateValue:[ALIPAY_BTLE_END_OF_SIGNAL dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:self.transferCharacteristic onSubscribedCentrals:nil];
        
        // Did it send?
        if (didSend) {
            
            // It did, so mark it as sent
            sendingEOM = NO;
            
            NSLog(@"Sent: 'EOM' : %@", ALIPAY_BTLE_END_OF_SIGNAL);
        }
        
        // It didn't send, so we'll exit and wait for peripheralManagerIsReadyToUpdateSubscribers to call sendData again
        return;
    }
    
    // We're not sending an EOM, so we're sending data
    
    // Is there any left to send?
    
    if (self.sendDataIndex >= self.dataToSend.length) {
        // No data left.  Do nothing
        NSLog(@"nothing bo be sended!");
        return;
    }
    
    // There's data left, so send until the callback fails, or we're done.
    
    BOOL didSend = YES;
    
    while (didSend) {
        
        // Make the next chunk
        
        // Work out how big it should be
        NSInteger amountToSend = self.dataToSend.length - self.sendDataIndex;
        
        // Can't be longer than 20 bytes
        if (amountToSend > NOTIFY_MTU) amountToSend = NOTIFY_MTU;
        
        // Copy out the data we want
        NSData *chunk = [NSData dataWithBytes:self.dataToSend.bytes + self.sendDataIndex length:amountToSend];
        
        // Send it
        didSend = [self.peripheralManager updateValue:chunk forCharacteristic:self.transferCharacteristic onSubscribedCentrals:nil];
        
        // If it didn't work, drop out and wait for the callback
        if (!didSend) {
//            self.retryTimes ++;
//            if (self.retryTimes > 3) {
//                return;
//            }
//            return [self sendData];
            return;
        }
        
        
        // It did send, so update our index
        self.sendDataIndex += amountToSend;
        
        // Was it the last one?
        if (self.sendDataIndex >= self.dataToSend.length) {
            
            // It was - send an EOM
            
            // Set this so if the send fails, we'll send it next time
            sendingEOM = YES;
            
            // Send it
            BOOL eomSent = [self.peripheralManager updateValue:[ALIPAY_BTLE_END_OF_SIGNAL dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:self.transferCharacteristic onSubscribedCentrals:nil];
            
            if (eomSent) {
                // It sent, we're all done
                sendingEOM = NO;
                
                NSLog(@"Last Sent: 'EOM' : %@", ALIPAY_BTLE_END_OF_SIGNAL);
            }
            
            return;
        }
    }
}


@end
