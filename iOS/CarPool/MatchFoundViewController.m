//
//  MatchFoundViewController.m
//  CarPool
//
//  Created by KimHakMin on 10/15/13.
//  Copyright (c) 2013 RiKS. All rights reserved.
//

#import "MatchFoundViewController.h"
#import "Common.h"
#import "CommManager.h"
#import "TaxiStandMapViewController.h"
#import "DejalActivityView.h"
#import "MatchingViewController.h"
#import "RouteViewController.h"
#import "LoginViewController.h"
#import "CarPoolAppDelegate.h"

@interface MatchFoundViewController ()

@end

@implementation MatchFoundViewController

@synthesize lblResult;
@synthesize pairResp;
@synthesize start_coord;
@synthesize dst_coord;
@synthesize parentController;
@synthesize timer;
@synthesize curCount;

#define TIMER_INTERVAL		1
#define TIMER_LIMIT			120

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if ([Common getPhoneType] == IPHONE5)
		nibNameOrNil = [nibNameOrNil stringByAppendingString:@"_ios5"];

	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

	if (self)
	{
		// Custom initialization
		pairResp = nil;
		timer = nil;
		curCount = 0;
	}

	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view from its nib.

	if (pairResp != nil)
		[self showResult];

}

- (void)viewDidAppear:(BOOL)animated
{
	timer = [NSTimer scheduledTimerWithTimeInterval:TIMER_INTERVAL target:self selector:@selector(onTimer) userInfo:nil repeats:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[timer invalidate];
	timer = nil;
}

- (void)showResult
{
	NSString *szResult = nil;
		
	szResult = [NSString stringWithFormat:@"The other party is \"%@\"\nNumber of people is %d\n", pairResp.Name, pairResp.Count];
	
	NSString *strBuf = @"";
	if (pairResp.Count == 1)
	{
		if (pairResp.GrpGender == 0)
			strBuf = @"His destination is ";
		if (pairResp.GrpGender == 1)
			strBuf = @"Her destination is ";
		if (pairResp.GrpGender == 2)
			strBuf = @"Their destination is ";
	}
	else
		strBuf = @"Their destination is ";
	szResult = [NSString stringWithFormat:@"%@%@%@\n", szResult, strBuf, pairResp.Destination];
	
	if (pairResp.OffOrder == 0)
		strBuf = @"You are first to alight";
	else
		strBuf = @"You are second to alight";
	
	szResult = [NSString stringWithFormat:@"%@%@\nSaving for this trip : S$%.2f\nPossible slight delay : %.2f", szResult, strBuf, pairResp.SaveMoney, pairResp.LostTime];

	lblResult.numberOfLines = 0;
	[lblResult setText:szResult];
	[lblResult sizeToFit];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (IBAction)onViewRoute:(id)sender
{
	RouteViewController *controller = [[RouteViewController alloc] initWithNibName:@"RouteViewController" bundle:nil];

	controller.start_coord = start_coord;
	if (pairResp.OffOrder == 0)
	{
		controller.dst_coord1 = dst_coord;
		controller.dst_coord2 = CLLocationCoordinate2DMake(pairResp.DstLat, pairResp.DstLon);
	}
	else
	{
		controller.dst_coord1 = CLLocationCoordinate2DMake(pairResp.DstLat, pairResp.DstLon);
		controller.dst_coord2 = dst_coord;
	}

	controller.curCount = curCount;
	controller.matchingFoundController = self;
	controller.matchingController = parentController;

	SHOW_VIEW(controller);
}

- (IBAction)onReject:(id)sender
{
	[timer invalidate];

	if (![Common isReachable:YES])
		return;

	[Common startDejalActivity:self.view];
	STPairAgree *pairAgree = [[STPairAgree alloc] init];
	pairAgree.Uid = [Common readUserIdFromFile];
	pairAgree.IsAgree = NO;

	CommManager* commMgr = [CommManager getCommMgr];
	[commMgr userManage].delegate = self;
	[[commMgr userManage] getRequestPairAgree:pairAgree];
}

-(IBAction)onCheckOut:(id)sender
{
	if (![Common isReachable:YES])
		return;

	[Common startDejalActivity:self.view];

	CommManager* commMgr = [CommManager getCommMgr];
	[commMgr userManage].delegate = self;
	[[commMgr userManage] getRequestLogOut];
}

- (void)getRequestPairAgreeResult:(StringContainer*)res
{
	[Common endDejalActivity];

	BACK_VIEW(self);

	if (parentController != nil)
	{
		MatchingViewController *controller = (MatchingViewController*)parentController;
		[controller startTimer];
	}
}

- (void)getRequestPairOffResult:(StringContainer *)szRes
{
	[Common endDejalActivity];
	TaxiStandMapViewController *controller = [[TaxiStandMapViewController alloc] initWithNibName:@"TaxiStandMapViewController" bundle:nil];
	SHOW_VIEW(controller);
}

- (void)onTimer
{
	if (curCount >= TIMER_LIMIT)
	{
		[self onReject:nil];
	}
	else
	{
		curCount += TIMER_INTERVAL;
	}
}

@end







