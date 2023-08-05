//
//  RatingViewController.m
//  CarPool
//
//  Created by KimHakMin on 10/18/13.
//  Copyright (c) 2013 RiKS. All rights reserved.
//

#import "RatingViewController.h"
#import "Common.h"
#import "CommManager.h"
#import "DejalActivityView.h"
#import "HistoryViewController.h"
#import "TaxiStandMapViewController.h"

@interface RatingViewController ()

@end

@implementation RatingViewController

@synthesize lblInfo;
@synthesize rateView;
@synthesize pairHistory;
@synthesize bRated;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if ([Common getPhoneType] == IPHONE5)
		nibNameOrNil = [nibNameOrNil stringByAppendingString:@"_ios5"];
	
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		// Custom initialization
		bRated = NO;
	}
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view from its nib.

	[rateView setRating:5];
	[rateView setBackgroundColor:[UIColor clearColor]];

	int nIndex = 0;
	if (pairHistory.Uid1 == [Common readUserIdFromFile])
		nIndex = 1;
	else
		nIndex = 2;

	NSString *szResult = [NSString stringWithFormat:@"Name : %@\nStart Address : %@\nDest Address : %@\nPaired Time : %@", nIndex == 1 ? pairHistory.Name2 : pairHistory.Name1, pairHistory.SrcAddr, nIndex == 1 ? pairHistory.DstAddr2 : pairHistory.DstAddr1, pairHistory.PairingTime];
	[lblInfo setText:szResult];
	[lblInfo sizeToFit];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (IBAction)onClickOK:(id)sender
{
	if (bRated)
	{
		TaxiStandMapViewController *controller = [[TaxiStandMapViewController alloc] initWithNibName:@"TaxiStandMapViewController" bundle:nil];
		SHOW_VIEW(controller);

		return;
	}

	STEvaluate *evaluate = [[STEvaluate alloc] init];

	evaluate.Uid = [Common readUserIdFromFile];

	if (evaluate.Uid == pairHistory.Uid1)
		evaluate.OppoID = pairHistory.Uid2;
	else
		evaluate.OppoID = pairHistory.Uid1;
	
	evaluate.Score = [rateView rating];
	evaluate.ServeTime = pairHistory.PairingTime;

	if (![Common isReachable:YES])
		return;

	[Common startDejalActivity:self.view];

	CommManager* commMgr = [CommManager getCommMgr];
	[commMgr userManage].delegate = self;
	[[commMgr userManage] getRequestEvaluate:evaluate];
}

- (IBAction)onClickCancel:(id)sender
{
	TaxiStandMapViewController *controller = [[TaxiStandMapViewController alloc] initWithNibName:@"TaxiStandMapViewController" bundle:nil];
	SHOW_VIEW(controller);
}

- (void)getRequestEvaluateResult:(StringContainer *)szRes
{
	[Common endDejalActivity];

	if (szRes.Result == 1)
	{
		[Common showAlert:@"Rating succeeded"];
		HistoryViewController *controller = [[HistoryViewController alloc] initWithNibName:@"HistoryViewController" bundle:nil];
		bRated = YES;
		SHOW_VIEW(controller);
	}
	else if (szRes.Result == -106)
	{
		[Common showAlert:@"Already rated."];
		TaxiStandMapViewController *controller = [[TaxiStandMapViewController alloc] initWithNibName:@"TaxiStandMapViewController" bundle:nil];
		SHOW_VIEW(controller);
	}
	else
	{
		[Common showAlert:@"Rating failed."];
		NSLog(@"Rating failed. %@", szRes.Value);
	}
}

@end









