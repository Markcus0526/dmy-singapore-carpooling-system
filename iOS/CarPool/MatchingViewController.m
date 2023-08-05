//
//  MatchingViewController.m
//  CarPool
//
//  Created by RiKS on 10/5/13.
//  Copyright (c) 2013 RiKS. All rights reserved.
//

#import "MatchingViewController.h"
#import "MatchFoundViewController.h"
#import "STDataInfo.h"
#import "CommManager.h"
#import "DejalActivityView.h"
#import "Common.h"
#import "LoginViewController.h"
#import "TaxiStandMapViewController.h"
#import "CheckInViewController.h"
#import "CarPoolAppDelegate.h"

@interface MatchingViewController ()
{
	NSTimer *timerRequest;
}

@end

@implementation MatchingViewController

@synthesize pairResponse;
@synthesize nRequestCurCount;

@synthesize btnCheckOut;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if ([Common getPhoneType] == IPHONE5)
		nibNameOrNil = [nibNameOrNil stringByAppendingString:@"_ios5"];

	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

	if (self)
	{
		// Custom initialization
		timerRequest = nil;
		nRequestCurCount = 0;
	}

	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view from its nib.
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];

	CarPoolAppDelegate* appDelegate = (CarPoolAppDelegate*)[UIApplication sharedApplication].delegate;
	appDelegate.matching_ctrl = self;

	[self startTimer];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	[self stopTimer];
}

-(void) onTimer:(NSTimer *)timer
{
	if (nRequestCurCount * SEND_INTERVAL >= SEND_LIMIT)
	{
		[self stopTimer];

		if (![Common isReachable:YES])
			return;

		[Common startDejalActivity:self.view];
		[NSThread detachNewThreadSelector:@selector(logoutThread) toTarget:self withObject:nil];
	}

	nRequestCurCount++;

	NSLog(@"The value of count is %i", nRequestCurCount);

	CommManager* commMgr = [CommManager getCommMgr];
	[commMgr pairManage].delegate = (id<PairManageDelegate>)self;
	[[commMgr pairManage] getRequestIsPaired];
}

-(void) getRequestIsPairedResult:(STPairResponse*)res
{
	CommManager *commMgr = [CommManager getGlobalCommMgr];

	if (res.ErrCode == 1)
	{
		[self stopTimer];

		MatchFoundViewController *controller = [[MatchFoundViewController alloc] initWithNibName:@"MatchFoundViewController" bundle:nil];

		controller.start_coord = CLLocationCoordinate2DMake(commMgr.fSrcLat, commMgr.fSrcLon);
		controller.dst_coord = CLLocationCoordinate2DMake(commMgr.fDstLat, commMgr.fDstLon);
		controller.pairResp = res;
		controller.parentController = self;

		commMgr.g_pairResp = res;

		SHOW_VIEW(controller);
	}
	else if (res.ErrCode == ERR_INVALID_USER)
	{
		[Common showAlert:@"Not valid user."];
		
		[self stopTimer];
		BACK_VIEW(self);
	};
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (IBAction)btnCheckOutClicked:(id)sender
{
	if (![Common isReachable:YES])
		return;

	[Common startDejalActivity:self.view];

	CommManager* commMgr = [CommManager getCommMgr];
	[commMgr userManage].delegate = self;
	[[commMgr userManage] getRequestLogOut];
}

- (void)startTimer
{
	nRequestCurCount = 0;

	if (timerRequest != nil)
		[timerRequest invalidate];

	CarPoolAppDelegate* delegate = (CarPoolAppDelegate*)[UIApplication sharedApplication].delegate;
	delegate.notif_fromWhere = FROM_PAIRING;

	timerRequest = [NSTimer scheduledTimerWithTimeInterval:SEND_INTERVAL target:self selector:@selector(onTimer:) userInfo:nil repeats:YES];
}

- (void)stopTimer
{
	if (timerRequest != nil)
	{
		[timerRequest invalidate];
		timerRequest = nil;
	}
}

- (void)getRequestPairOffResult:(StringContainer *)szRes
{
	[Common endDejalActivity];

	if (nRequestCurCount * SEND_INTERVAL >= SEND_LIMIT)
	{
		[self stopTimer];

		CheckInViewController *controller = [[CheckInViewController alloc] initWithNibName:@"CheckInViewController" bundle:nil];
		CommManager *commMgr = [CommManager getGlobalCommMgr];

		commMgr.fSrcLat = controller.fSrcLat;
		commMgr.fSrcLon = controller.fSrcLon;
		commMgr.fDstLat = controller.fDstLat;
		commMgr.fDstLon = controller.fDstLon;
		commMgr.strDstAddress = controller.strDstAddress;
		commMgr.nPax = controller.nPax;
		commMgr.nGrpGender = controller.nGrpGender;
		commMgr.strColor = controller.strColor;
		commMgr.strOtherFeature = controller.strOtherFeature;

		SHOW_VIEW(controller);
	}
	else
	{
		TaxiStandMapViewController *controller = [[TaxiStandMapViewController alloc] initWithNibName:@"TaxiStandMapViewController" bundle:nil];
		SHOW_VIEW(controller);
	}
}

@end







