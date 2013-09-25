//
//  ModeViewController.m
//  BTLE_PAY_DEMO
//
//  Created by Michael Hanyee on 13-9-25.
//  Copyright (c) 2013年 Michael Hanyee. All rights reserved.
//

#import "ModeViewController.h"

@interface ModeViewController ()

@end

@implementation ModeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"select mode";
    UITextView *t = [[UITextView alloc] initWithFrame:CGRectMake(10.f, 70.f, 200.f, 50.f)];
    t.backgroundColor = [UIColor redColor];
    [self.view addSubview:t];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
