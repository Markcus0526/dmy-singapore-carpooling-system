//
//  BuyCreditViewController.m
//  CarPool
//
//  Created by RiKS on 10/4/13.
//  Copyright (c) 2013 RiKS. All rights reserved.
//

#import "BuyCreditViewController.h"
#import "BuyCreditsViewController.h"
#import "Common.h"

@interface BuyCreditViewController ()

@end

@implementation BuyCreditViewController

@synthesize lblData;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if ([Common getPhoneType] == IPHONE5)
		nibNameOrNil = [nibNameOrNil stringByAppendingString:@"_ios5"];

	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	NSString *strData = @"";
	strData = @"Oops, your credit balance is zero! \n\n Simply click \"Buy Credits\" and start saving again!";
	
	lblData.text= [strData stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (IBAction)onClickMaybeLater:(id)sender
{
	BACK_VIEW(self);
}

- (IBAction)onClickBuyNow:(id)sender
{
	BuyCreditsViewController *controller = [[BuyCreditsViewController alloc] initWithNibName:@"BuyCreditsViewController" bundle:nil];
	SHOW_VIEW(controller);
}


@end




