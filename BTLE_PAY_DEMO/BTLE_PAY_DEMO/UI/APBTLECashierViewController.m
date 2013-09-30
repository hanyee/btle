//
//  APBTLECashierViewController.m
//  BTLE_PAY_DEMO
//
//  Created by Michael Hanyee on 13-9-26.
//  Copyright (c) 2013年 Michael Hanyee. All rights reserved.
//

#import "APBTLECashierViewController.h"
#import "APBTLECashierCompleteViewController.h"
#import "APBTLECoreTunnel.h"

@interface APBTLECashierViewController () <APBTLECoreTunnelDelegate>

@property CGFloat mt;
@property (strong, nonatomic) UIButton          *dealBtn;
@property (strong, nonatomic) APBTLECoreTunnel  *tunnel;




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
    [self.tunnel stopScan];
    [self.tunnel cleanup];
    
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    UILabel *prodIdLb = [[UILabel alloc] initWithFrame:CGRectMake(10.f, self.mt + 10.f, 300.f, 30.f)];
    UILabel *prodNameLb = [[UILabel alloc] initWithFrame:CGRectMake(10.f, prodIdLb.frame.origin.y + prodIdLb.frame.size.height +10.f, 300.f, 30.f)];
    UILabel *priceTagLb = [[UILabel alloc] initWithFrame:CGRectMake(10.f, prodNameLb.frame.origin.y + prodNameLb.frame.size.height + 30.f, 300.f, 30.f)];
    prodIdLb.text = @"208802387236128912937";
    prodNameLb.text = @"精选水果披萨        X 1";
    priceTagLb.text = @"33.00  元";
    
    
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
//    [self.tunnel createCentralManager];
    
//    [self.navigationController pushViewController:[[APBTLECashierCompleteViewController alloc] init] animated:YES];
}

- (void) centralManagerPoweredOn{
//    [self.tunnel scanWithUUID:@[DEFAULT_TRANSFER_SERVICE_UUID]];
    [self.tunnel scan];
}

- (void) dataReceived:(NSData *) data{
    if (data) {
        self.receivedText.text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
