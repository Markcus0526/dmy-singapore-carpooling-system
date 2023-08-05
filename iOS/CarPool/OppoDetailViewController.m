//
//  OppoDetailViewController.m
//  CarPool
//
//  Created by KimHakMin on 10/17/13.
//  Copyright (c) 2013 RiKS. All rights reserved.
//

#import "OppoDetailViewController.h"
#import "Common.h"
#import "CommManager.h"
#import "RatingViewController.h"

@interface OppoDetailViewController ()

@end

@implementation OppoDetailViewController

@synthesize lblPairInfo;
@synthesize timer;

#define TIMER_INTERVAL		20

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if ([Common getPhoneType] == IPHONE5)
		nibNameOrNil = [nibNameOrNil stringByAppendingString:@"_ios5"];
	
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

	if (self) {
		timer = nil;
	}
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view from its nib.

	NSString *szResult = nil;
	STPairResponse *pairRes = [CommManager getGlobalCommMgr].g_pairResp;

	szResult = [NSString stringWithFormat:@"Your party is \"%@\"\n\nDestination is %@\n\nColor of ", pairRes.Name, pairRes.Destination];

	if (pairRes.Count == 1)
	{
		if (pairRes.GrpGender == 0)
			szResult = [szResult stringByAppendingFormat:@"his top is %@", pairRes.Color];
		else if (pairRes.GrpGender == 1)
			szResult = [szResult stringByAppendingFormat:@"her top is %@", pairRes.Color];
		else
			szResult = [szResult stringByAppendingFormat:@"their top is %@", pairRes.Color];
	}
	else
	{
		szResult = [szResult stringByAppendingFormat:@"their top is %@", pairRes.Color];
	}

	if (pairRes.OtherFeature != nil && pairRes.OtherFeature.length > 0)
		szResult = [szResult stringByAppendingFormat:@"\n\nOther identifiable feature is %@", pairRes.OtherFeature];

	szResult = [szResult stringByAppendingFormat:@"\n\nSaving for this trip : S$%.2f\n\nPossible slight delay : %.2fminutes", pairRes.SaveMoney, pairRes.LostTime];

	[lblPairInfo setText:szResult];
	[lblPairInfo sizeToFit];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (IBAction)onClickNextBoard:(id)sender
{
	CommManager* g_commMgr = [CommManager getGlobalCommMgr];
	if (g_commMgr.g_pairResp.QueueOrder == 0)
	{
		[Common startDejalActivity:self.view];
		CommManager* commMgr = [CommManager getCommMgr];
		UserManage* userManage = [commMgr userManage];
		userManage.delegate = self;
		[userManage getSetNext];
	}
	else
	{
		RatingViewController *controller = [[RatingViewController alloc] initWithNibName:@"RatingViewController" bundle:nil];

		STPairHistory *pairHistory = [[STPairHistory alloc] init];

		CommManager *commMgr = [CommManager getGlobalCommMgr];
		STPairResponse *response = commMgr.g_pairResp;
		
		pairHistory.Uid1 = [Common readUserIdFromFile];
		pairHistory.Uid2 = response.Uid;
		pairHistory.Name2 = response.Name;
		pairHistory.SrcAddr = commMgr.strSrcAddress;
		pairHistory.DstAddr2 = response.Destination;
		pairHistory.PairingTime = commMgr.strPairedTime;
		controller.pairHistory = pairHistory;

		SHOW_VIEW(controller);

		if (timer != nil)
			[timer invalidate];
		timer = nil;
	}
}

- (void)getSetNextResult:(StringContainer *)result
{
	[Common endDejalActivity];
	
	if (result == nil)
	{
		[Common showAlert:@"Service Failure"];
		return;
	}

	[timer invalidate];
	timer = nil;

	RatingViewController *controller = [[RatingViewController alloc] initWithNibName:@"RatingViewController" bundle:nil];

	STPairHistory *pairHistory = [[STPairHistory alloc] init];

	CommManager *commMgr = [CommManager getGlobalCommMgr];
	STPairResponse *response = commMgr.g_pairResp;

	pairHistory.Uid1 = [Common readUserIdFromFile];
	pairHistory.Uid2 = response.Uid;
	pairHistory.Name2 = response.Name;
	pairHistory.SrcAddr = commMgr.strSrcAddress;
	pairHistory.DstAddr2 = response.Destination;
	pairHistory.PairingTime = commMgr.strPairedTime;
	controller.pairHistory = pairHistory;

	SHOW_VIEW(controller);

	if (timer != nil)
		[timer invalidate];
	timer = nil;
}


@end
