//
//  APBTLECashierCompleteViewController.m
//  BTLE_PAY_DEMO
//
//  Created by Michael Hanyee on 13-9-26.
//  Copyright (c) 2013年 Michael Hanyee. All rights reserved.
//

#import "APBTLECashierCompleteViewController.h"

@interface APBTLECashierCompleteViewController ()

@end

@implementation APBTLECashierCompleteViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Completed";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    UILabel *completeTipLb = [[UILabel alloc] initWithFrame:CGRectMake(10.f, (CGRectGetHeight(self.view.bounds) - 44.f - 80.f) / 2, 300.f, 80.f)];
    
    completeTipLb.text = @"订单支付完成！";
    [completeTipLb setTextAlignment:NSTextAlignmentCenter];
    completeTipLb.font = [UIFont boldSystemFontOfSize:30.f];
    completeTipLb.textColor = [UIColor greenColor];

    
    [self.view addSubview:completeTipLb];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
