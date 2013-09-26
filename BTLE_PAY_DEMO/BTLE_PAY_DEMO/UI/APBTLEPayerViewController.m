//
//  APBTLEPayerViewController.m
//  BTLE_PAY_DEMO
//
//  Created by Michael Hanyee on 13-9-26.
//  Copyright (c) 2013年 Michael Hanyee. All rights reserved.
//

#import "APBTLEPayerViewController.h"
#import "APBTLEPaymentCompleteViewController.h"

@interface APBTLEPayerViewController ()

@end

@implementation APBTLEPayerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Pay";
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


- (void) pay {

}

- (void) directPay{
    [self.navigationController pushViewController:[[APBTLEPaymentCompleteViewController alloc] init] animated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
