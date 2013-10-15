//
//  APBTLECorePeripheralClient.m
//  BTLE_PAY_DEMO
//
//  Created by Michael Hanyee on 13-10-13.
//  Copyright (c) 2013年 Michael Hanyee. All rights reserved.
//

#import "APBTLECorePeripheralClient.h"

@interface APBTLECorePeripheralClient() <CBPeripheralManagerDelegate>

@property (strong, nonatomic) CBPeripheralManager       *peripheralManager;
@property dispatch_queue_t                              peripheralManagerQueue;
@property (strong, nonatomic) NSString                  *deviceUID;
@property (nonatomic, readwrite) NSInteger              sendDataIndex;
@property (strong, nonatomic) NSArray                   *advertisingServiceUUIDs;
@property (strong, nonatomic) NSArray                   *advertisingServiceUUIDStrings;


@end


@implementation APBTLECorePeripheralClient


- (id) init {
    self = [super init];
    
    if (self) {
        self.peripheralManager = nil;
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

- (void) createPeripheralManager {
    self.advertisingServiceUUIDStrings = nil;
    self.advertisingServiceUUIDs = nil;
    
    self.peripheralManager = [[CBPeripheralManager alloc] initWithDelegate:self queue:self.peripheralManagerQueue];
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
    if (self.peripheralManager && self.peripheralManager.state == CBPeripheralManagerStatePoweredOn) {
        [self.peripheralManager stopAdvertising];
        NSLog(@"stop advertising");
    }
}

- (void) addPeripheralServiceWithUUID:(NSArray *) uuidStrings {
    
    self.transferCharacteristic = [[CBMutableCharacteristic alloc] initWithType:DEFAULT_CHARACTERISTIC_UUID
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
    
    NSLog(@"characteristic is : %@", self.transferCharacteristic.value);
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
    if (self.isTunnelStarted) {
        //        [self destroyCentralManager];
    }
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
    
    [self.delegate peripheralManagerDidDestroyed];
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
            
            [self.delegate dataDidSend];
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
