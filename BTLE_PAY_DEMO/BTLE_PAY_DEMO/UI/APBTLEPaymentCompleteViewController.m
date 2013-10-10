//
//  APBTLEPaymentViewController.m
//  BTLE_PAY_DEMO
//
//  Created by Michael Hanyee on 13-9-26.
//  Copyright (c) 2013年 Michael Hanyee. All rights reserved.
//

#import "APBTLEPaymentCompleteViewController.h"

@interface APBTLEPaymentCompleteViewController ()

@property CGFloat mt;

@property (strong, nonatomic) UILabel               *prodNameLb;
@property (strong, nonatomic) UILabel               *priceTagLb;
@property (strong, nonatomic) NSString              *prodName;
@property (strong, nonatomic) NSString              *prodPrice;

@end

@implementation APBTLEPaymentCompleteViewController

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

- (id)initWithResult:(NSString *) result{
    
    self = [self init];
    
    if (result) {
        NSArray *tempArr = [result componentsSeparatedByString:@"::"];
        self.prodName = [tempArr objectAtIndex:0];
        self.prodPrice = [tempArr objectAtIndex:1];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.prodNameLb = [[UILabel alloc] initWithFrame:CGRectMake(10.f, _mt + 20.f, 300.f, 30.f)];
    self.prodNameLb.text = self.prodName;
    [self.prodNameLb setTextAlignment:NSTextAlignmentCenter];
    
    self.priceTagLb = [[UILabel alloc] initWithFrame:CGRectMake(10.f, (CGRectGetHeight(self.view.bounds) - 44.f - 30.f) / 2 + 20.f, 300.f, 20.f)];
    self.priceTagLb.text = self.prodPrice;
    [self.priceTagLb setTextAlignment:NSTextAlignmentCenter];
    self.priceTagLb.font = [UIFont systemFontOfSize:16.f];
    
    
    UILabel *completeTipLb = [[UILabel alloc] initWithFrame:CGRectMake(10.f, self.priceTagLb.frame.origin.y + 20.f, 300.f, 40.f)];
    completeTipLb.text = @"付款成功！";
    [completeTipLb setTextAlignment:NSTextAlignmentCenter];
    completeTipLb.font = [UIFont systemFontOfSize:20.f];
    completeTipLb.textColor = [UIColor greenColor];
    
    
    [self.view addSubview:self.prodNameLb];
    [self.view addSubview:self.priceTagLb];
    [self.view addSubview:completeTipLb];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
