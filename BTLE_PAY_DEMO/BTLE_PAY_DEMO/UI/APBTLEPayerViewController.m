//
//  APBTLEPayerViewController.m
//  BTLE_PAY_DEMO
//
//  Created by Michael Hanyee on 13-9-26.
//  Copyright (c) 2013年 Michael Hanyee. All rights reserved.
//

#define SECRET_ID @"19610FAE-DB05-467E-8757-72F6FAEB13D4"

#import <CoreBluetooth/CoreBluetooth.h>

#import "APBTLEPayerViewController.h"
#import "APBTLEPaymentCompleteViewController.h"
#import "APBTLECoreTunnel.h"



@interface APBTLEPayerViewController () <APBTLECoreTunnelDelegate>

@property (strong, nonatomic) APBTLECoreTunnel  *tunnel;

@property BOOL                                  tunnelBuilded;

@end

@implementation APBTLEPayerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Pay";
        self.tunnel = [[APBTLECoreTunnel alloc] init];
        self.tunnel.delegate = self;
        self.tunnelBuilded = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    UIButton *payBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [payBtn setTitle:@"付 款" forState:UIControlStateNormal];
    payBtn.frame = CGRectMake(10.f, CGRectGetHeight(self.view.bounds) - 104.f, 300.f, 40.f);
    [payBtn addTarget:self action:@selector(pay) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *directPayBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [directPayBtn setTitle:@"直 接 付 款" forState:UIControlStateNormal];
    directPayBtn.frame = CGRectMake(10.f, payBtn.frame.origin.y - 70.f, 300.f, 40.f);
    [directPayBtn addTarget:self action:@selector(directPay) forControlEvents:UIControlEventTouchUpInside];
    
    
    [self.view addSubview:payBtn];
    [self.view addSubview:directPayBtn];
    
}


- (void)viewWillDisappear:(BOOL)animated
{
    // Don't keep it going while we're not showing.
//    [self.tunnel stopAdvertising];
//    [self.tunnel stopScan];
//    [self.tunnel cleanup];
    
    [self.tunnel destroyPeripheralManager];
    [self.tunnel destroyCentralManager];
    
    [super viewWillDisappear:animated];
}

- (void) pay {

}

- (void) directPay{
    
    [self.tunnel createPeripheralManagerWithUUIDStrings:@[DEFAULT_TRANSFER_SERVICE_UUID]];
//    [self.tunnel updatePeripheralServiceWithUUID:nil];
//    [self.navigationController pushViewController:[[APBTLEPaymentCompleteViewController alloc] init] animated:YES];
}


- (void) peripheralManagerPoweredOn{
    [self.tunnel startAdvertising];
}


- (void) isReadyToSendData{

    if (self.tunnelBuilded) {
        // exchange data
        
        
    }else{
        [self.tunnel setDataToSend:[[NSMutableData alloc] initWithData:[SECRET_ID dataUsingEncoding:NSUTF8StringEncoding]]];
        [self.tunnel sendData];
    }
    
//    dispatch_sync(dispatch_get_main_queue(), ^{
//        [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(timertodo) userInfo:nil repeats:YES];
//    });
}


- (void) peripheralManagerDidDestroyed{
    
    if (self.tunnelBuilded) {
        self.tunnelBuilded = NO;
    }else{
        self.tunnelBuilded = YES;
        [self startTunnel];
    }

}

- (void) centralManagerPoweredOn{
    [self.tunnel scan];
}

- (void) dataReceived:(NSData *) data{
    NSString *tempReceivedString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"porduct to pay is : %@", tempReceivedString);
    
    // send account and finished flag
    [self.tunnel setDataToSend:[[NSMutableData alloc] initWithData:[@"myalipay@alipay.com::成功！" dataUsingEncoding:NSUTF8StringEncoding]]];
    [self.tunnel sendData];
    // push view with tempReceivedString
}

- (void) centralManagerDidDestroyed{

}


- (void) startTunnel{
    [self.tunnel startTunnelWithUUID:SECRET_ID];
    
}


- (void) timertodo{
    NSLog(@"timer excuted!!!! ");
    
    [self.tunnel setDataToSend:[[NSMutableData alloc] initWithData:[@"34567898765jkskldj" dataUsingEncoding:NSUTF8StringEncoding]]];
    [self.tunnel sendData];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end