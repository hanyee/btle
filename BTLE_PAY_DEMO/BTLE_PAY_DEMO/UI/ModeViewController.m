//
//  ModeViewController.m
//  BTLE_PAY_DEMO
//
//  Created by Michael Hanyee on 13-9-25.
//  Copyright (c) 2013年 Michael Hanyee. All rights reserved.
//

#import "ModeViewController.h"
#import "APBTLECashierViewController.h"
#import "APBTLEPayerViewController.h"

@interface ModeViewController ()

@property CGFloat mt;

@end

@implementation ModeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
            self.mt = 10.f;
        }else{
            self.mt = 74.f;
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"select mode";
    
//    UITextView *t = [[UITextView alloc] initWithFrame:CGRectMake(10.f, 10.f, 200.f, 50.f)];
//    t.backgroundColor = [UIColor redColor];
//    [self.view addSubview:t];
    
    
    UIButton *cashierBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [cashierBtn setTitle:@"the cashier" forState:UIControlStateNormal];
    cashierBtn.frame = CGRectMake(10.f, self.mt + 70.f, 300.f, 40.f);
    
    UIButton *payerBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [payerBtn setTitle:@"the payer" forState:UIControlStateNormal];
    payerBtn.frame = CGRectMake(10.f, 140.f + cashierBtn.frame.origin.y, 300.f, 40.f);
    
    [cashierBtn addTarget:self action:@selector(goToCashier) forControlEvents:UIControlEventTouchUpInside];
    [payerBtn addTarget:self action:@selector(goToPayment) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:cashierBtn];
    [self.view addSubview:payerBtn];
    
    

}

- (void) goToCashier{
    [self.navigationController pushViewController:[[APBTLECashierViewController alloc] init] animated:YES];
}

- (void) goToPayment{
    [self.navigationController pushViewController:[[APBTLEPayerViewController alloc] init] animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
