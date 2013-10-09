//
//  APBTLECashierViewController.m
//  BTLE_PAY_DEMO
//
//  Created by Michael Hanyee on 13-9-26.
//  Copyright (c) 2013年 Michael Hanyee. All rights reserved.
//

#define PROD_ID             @"208802387236128912937"
#define PROD_NAME           @"精选水果披萨        X 1"
#define PROD_PRICE          @"33.00  元"

#import "APBTLECashierViewController.h"
#import "APBTLECashierCompleteViewController.h"
#import "APBTLECoreTunnel.h"



@interface APBTLECashierViewController () <APBTLECoreTunnelDelegate>

@property CGFloat mt;
@property (strong, nonatomic) UIButton          *dealBtn;
@property (strong, nonatomic) APBTLECoreTunnel  *tunnel;
@property (strong, nonatomic) NSString          *secretTunnelId;
@property BOOL                                  tunnelBuilded;


@property (strong, nonatomic) UITextView        *receivedText;
@end

@implementation APBTLECashierViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.tunnel = [[APBTLECoreTunnel alloc] init];
        self.tunnel.delegate = self;
        
        self.title = @"Cashier";
        if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
            self.mt = 10.f;
        }else{
            self.mt = 74.f;
        }
    }
    return self;
}

- (void) viewWillAppear:(BOOL)animated{
    [self.dealBtn setTitle:@"收 款" forState:UIControlStateNormal];
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

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    UILabel *prodIdLb = [[UILabel alloc] initWithFrame:CGRectMake(10.f, self.mt + 10.f, 300.f, 30.f)];
    UILabel *prodNameLb = [[UILabel alloc] initWithFrame:CGRectMake(10.f, prodIdLb.frame.origin.y + prodIdLb.frame.size.height +10.f, 300.f, 30.f)];
    UILabel *priceTagLb = [[UILabel alloc] initWithFrame:CGRectMake(10.f, prodNameLb.frame.origin.y + prodNameLb.frame.size.height + 30.f, 300.f, 30.f)];
    prodIdLb.text = PROD_ID;
    prodNameLb.text = PROD_NAME;
    priceTagLb.text = PROD_PRICE;
    
    
    self.dealBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.dealBtn setTitle:@"收 款" forState:UIControlStateNormal];
    self.dealBtn.frame = CGRectMake(10.f, self.view.frame.size.height - 104.f, 300.f, 40.f);
    [self.dealBtn addTarget:self action:@selector(dealPayment) forControlEvents:UIControlEventTouchUpInside];
    
    
    self.receivedText = [[UITextView alloc] initWithFrame:CGRectMake(10.f, priceTagLb.frame.origin.y + 40.f , 300.f, 80.f)];
//    self.receivedText.text = @"test";
    
    [self.view addSubview:prodIdLb];
    [self.view addSubview:prodNameLb];
    [self.view addSubview:priceTagLb];
    [self.view addSubview:self.dealBtn];
    [self.view addSubview:self.receivedText];
}

- (void) dealPayment{
    [self.dealBtn setTitle:@"等待付款 ....." forState:UIControlStateNormal];
//    [self.tunnel createCentralManager];
//    [self.tunnel scanWithUUID:@[DEFAULT_TRANSFER_SERVICE_UUID]];
    [self.tunnel createCentralManagerWithUUIDStrings:@[DEFAULT_TRANSFER_SERVICE_UUID]];
    
//    [self.navigationController pushViewController:[[APBTLECashierCompleteViewController alloc] init] animated:YES];
}

- (void) centralManagerPoweredOn{
//    [self.tunnel scanWithUUID:@[DEFAULT_TRANSFER_SERVICE_UUID]];
    [self.tunnel scan];
}

- (void) dataReceived:(NSData *) data{
    if (data) {
        
        if (self.tunnelBuilded){
            
            NSString *tempReceivedString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"payment result is : %@", tempReceivedString);
            // push view with tempReceivedString
        }else{
            self.secretTunnelId = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            self.receivedText.text = self.secretTunnelId;
            
            [self.tunnel disConnectPeripheral];
            [self.tunnel destroyCentralManager];
        }

    }
}

- (void) centralManagerDidDestroyed{
    
    if (self.tunnelBuilded) {
        self.tunnelBuilded = NO;
    }else{
        self.tunnelBuilded = YES;
        [self startTunnel];
    }
}

- (void) peripheralManagerPoweredOn{
    [self.tunnel startAdvertising];
}

- (void) isReadyToSendData{
    NSString *formatedString = [PROD_NAME stringByAppendingFormat:@"::%@",PROD_PRICE];
    [self.tunnel setDataToSend:[[NSMutableData alloc] initWithData:[formatedString dataUsingEncoding:NSUTF8StringEncoding]]];
    [self.tunnel sendData];
}

- (void) peripheralManagerDidDestroyed{
    
}

- (void) startTunnel{
    [self.tunnel startTunnelWithUUID:self.secretTunnelId];

}




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
