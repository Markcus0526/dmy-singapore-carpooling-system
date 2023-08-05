//
//  CreditViewController.m
//  CarPool
//
//  Created by KimHakMin on 10/6/13.
//  Copyright (c) 2013 RiKS. All rights reserved.
//

#import "CreditViewController.h"
#import "BuyCreditsViewController.h"
#import "Common.h"
#import "CommManager.h"
#import "STDataInfo.h"
#import "DejalActivityView.h"

@interface CreditViewController ()

@end

@implementation CreditViewController

#define TEXTCOLOR_NORMAL		[UIColor colorWithRed:130/255.0 green:130/255.0 blue:130/255.0 alpha:1]
#define TEXTCOLOR_RED			[UIColor redColor]

@synthesize lblCredits;
@synthesize lblTotalSaving;
@synthesize lblCreditRemain;

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

	[lblCredits setTextColor:TEXTCOLOR_NORMAL];
	[lblTotalSaving setTextColor:TEXTCOLOR_NORMAL];
	[lblCreditRemain setTextColor:TEXTCOLOR_NORMAL];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated
{
	if (![Common isReachable:YES])
		return;

	[Common startDejalActivity:self.view];

	CommManager* commMgr = [CommManager getCommMgr];
	[commMgr userManage].delegate = self;
	[[commMgr userManage] getRequestUserProfile];
}

- (void)getRequestUserProfileResult:(STUserProfile *)userProfile
{
	[Common endDejalActivity];

	[lblCredits setText:[NSString stringWithFormat:@"%d", userProfile.Credit]];
	if (userProfile.Credit == 0)
	{
		[lblCredits setTextColor:TEXTCOLOR_RED];
		[lblCreditRemain setTextColor:TEXTCOLOR_RED];
	}

	[lblTotalSaving setText:[NSString stringWithFormat:@"SGD %.2f", userProfile.TotalSaving]];
}

- (IBAction) onClickBuy:(id)sender
{
	BuyCreditsViewController *controller = [[BuyCreditsViewController alloc] initWithNibName:@"BuyCreditsViewController" bundle:nil];
	SHOW_VIEW(controller);
}

@end
