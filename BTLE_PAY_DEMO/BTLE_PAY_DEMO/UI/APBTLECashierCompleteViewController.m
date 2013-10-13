//
//  APBTLECashierCompleteViewController.m
//  BTLE_PAY_DEMO
//
//  Created by Michael Hanyee on 13-9-26.
//  Copyright (c) 2013年 Michael Hanyee. All rights reserved.
//

#import "APBTLECashierCompleteViewController.h"

@interface APBTLECashierCompleteViewController ()

@property (strong, nonatomic) NSString              *payerAccount;
@property (strong, nonatomic) NSString              *paymentState;

@end

@implementation APBTLECashierCompleteViewController

@synthesize payerAccount;
@synthesize paymentState;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Completed";
    }
    return self;
}

- (id)initWithResult:(NSString *) result{
    
    self = [self init];
    
    if (result) {
        NSArray *tempArr = [result componentsSeparatedByString:@"::"];
        self.payerAccount = [tempArr objectAtIndex:0];
        self.paymentState = [tempArr objectAtIndex:1];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    UILabel *completeTipLb = [[UILabel alloc] initWithFrame:CGRectMake(10.f, (CGRectGetHeight(self.view.bounds) - 44.f - 80.f) / 2, 300.f, 80.f)];
    
    completeTipLb.text = [NSString stringWithFormat: @"订单支付 ：%@", self.paymentState];
    [completeTipLb setTextAlignment:NSTextAlignmentCenter];
    completeTipLb.font = [UIFont boldSystemFontOfSize:25.f];
    completeTipLb.textColor = [UIColor greenColor];
    
    UILabel *accountLb = [[UILabel alloc] initWithFrame:CGRectMake(10.f, completeTipLb.frame.origin.y - 50.f, 300.f, 30.f)];
    accountLb.text = [NSString stringWithFormat: @"用户 ：%@", self.payerAccount];
    [accountLb setTextAlignment:NSTextAlignmentCenter];
    
    [self.view addSubview:completeTipLb];
    [self.view addSubview:accountLb];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
