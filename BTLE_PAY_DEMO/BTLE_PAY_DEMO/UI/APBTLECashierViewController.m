//
//  APBTLECashierViewController.m
//  BTLE_PAY_DEMO
//
//  Created by Michael Hanyee on 13-9-26.
//  Copyright (c) 2013年 Michael Hanyee. All rights reserved.
//

#import "APBTLECashierViewController.h"
#import "APBTLECashierCompleteViewController.h"

@interface APBTLECashierViewController ()

@property CGFloat mt;
@property (strong, nonatomic) UIButton          *dealBtn;

@end

@implementation APBTLECashierViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
    
    
    [self.view addSubview:prodIdLb];
    [self.view addSubview:prodNameLb];
    [self.view addSubview:priceTagLb];
    [self.view addSubview:self.dealBtn];
}

- (void) dealPayment{
    [self.dealBtn setTitle:@"等待付款 ....." forState:UIControlStateNormal];
    [self.navigationController pushViewController:[[APBTLECashierCompleteViewController alloc] init] animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
