//
//  RouteViewController.m
//  CarPool
//
//  Created by KimHakMin on 10/15/13.
//  Copyright (c) 2013 RiKS. All rights reserved.
//

#import "RouteViewController.h"
#import "Common.h"
#import "CommManager.h"
#import "DejalActivityView.h"
#import "TaxiStandMapViewController.h"
#import "WaitReplyViewController.h"
#import "MatchingViewController.h"
#import "TaxiStandFindViewController.h"
#import "MatchFoundViewController.h"
#import "CarPoolAppDelegate.h"
#import "OppoDetailViewController.h"
#import "RatingViewController.h"

@interface RouteViewController ()

@end

@implementation RouteViewController

#define TIMER_LIMIT			120
#define TIMER_INTERVAL		1

@synthesize start_coord;
@synthesize dst_coord1;
@synthesize dst_coord2;
@synthesize curCount;
@synthesize timer;
@synthesize mapview;
@synthesize matchingFoundController;
@synthesize matchingController;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if ([Common getPhoneType] == IPHONE5)
		nibNameOrNil = [nibNameOrNil stringByAppendingString:@"_ios5"];
	
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];


	if (self)
	{
		start_coord = CLLocationCoordinate2DMake(0, 0);
		dst_coord1 = CLLocationCoordinate2DMake(0, 0);
		dst_coord2 = CLLocationCoordinate2DMake(0, 0);

		matchingFoundController = nil;
		matchingController = nil;
	}

	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view from its nib.

	mapview.myLocationEnabled = NO;
	mapview.delegate = self;

#if false
	start_coord = CLLocationCoordinate2DMake(41.7293659, 123.3965316);
	dst_coord1= CLLocationCoordinate2DMake(41.7493659, 123.3565316);
	dst_coord2 = CLLocationCoordinate2DMake(41.7493659, 123.346);
#endif

	NSMutableArray *arrFirstPolyLine = [[[CommManager getCommMgr] userManage] getRouteStepsFrom:start_coord to:dst_coord1];

	GMSMutablePath *path1 = [GMSMutablePath path];
	for (int i = 0; i < arrFirstPolyLine.count; i++)
	{
		CLLocation *location = [arrFirstPolyLine objectAtIndex:i];
		[path1 addCoordinate:location.coordinate];
	}

	NSMutableArray *arrSecondPolyLine = [[[CommManager getCommMgr] userManage] getRouteStepsFrom:dst_coord1 to:dst_coord2];
	GMSMutablePath *path2 = [GMSMutablePath path];
	for (int i = 0; i < arrSecondPolyLine.count; i++)
	{
		CLLocation *location = [arrSecondPolyLine objectAtIndex:i];
		[path2 addCoordinate:location.coordinate];
	}

	GMSPolyline *polyline1 = [GMSPolyline polylineWithPath:path1];
	polyline1.strokeWidth = 3;
	polyline1.strokeColor = [UIColor redColor];

	GMSPolyline *polyline2 = [GMSPolyline polylineWithPath:path2];
	polyline2.strokeWidth = 3;
	polyline2.strokeColor = [UIColor blueColor];

	polyline1.map = mapview;
	polyline2.map = mapview;

	GMSMarker *start_marker = [[GMSMarker alloc] init];
	start_marker.position = start_coord;
	start_marker.map = mapview;

	GMSMarker *dst_marker1 = [[GMSMarker alloc] init];
	dst_marker1.position = dst_coord1;
	dst_marker1.map = mapview;

	GMSMarker *dst_marker2 = [[GMSMarker alloc] init];
	dst_marker2.position = dst_coord2;
	dst_marker2.map = mapview;

	GMSCameraPosition *pos = [[GMSCameraPosition alloc] initWithTarget:start_coord zoom:12 bearing:1 viewingAngle:0];
	[mapview setCamera:pos];
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

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (IBAction)onClickAgree:(id)sender
{
	pairAgree = [[STPairAgree alloc] init];
	pairAgree.Uid = [Common readUserIdFromFile];
	pairAgree.IsAgree = YES;

	if (![Common isReachable:YES])
		return;
	[Common startDejalActivity:self.view];

	CommManager* commMgr = [CommManager getCommMgr];
	[commMgr userManage].delegate = self;
	[[commMgr userManage] getRequestPairAgree:pairAgree];
}

- (IBAction)onClickReject:(id)sender
{
	pairAgree = [[STPairAgree alloc] init];
	pairAgree.Uid = [Common readUserIdFromFile];
	pairAgree.IsAgree = NO;

	if (![Common isReachable:YES])
		return;
	[Common startDejalActivity:self.view];
	
	CommManager* commMgr = [CommManager getCommMgr];
	[commMgr userManage].delegate = self;
	[[commMgr userManage] getRequestPairAgree:pairAgree];
}

- (void)getRequestPairAgreeResult:(StringContainer *)res
{
	[Common endDejalActivity];
	
	if (pairAgree.IsAgree)
	{
		MatchFoundViewController* foundViewController = (MatchFoundViewController*)matchingFoundController;
		if (foundViewController.pairResp.QueueOrder == 1)		// Off second
		{
			CommManager* commMgr = [CommManager getCommMgr];

			long nUid = [Common readUserIdFromFile];

			[commMgr userManage].delegate = self;
			[[commMgr userManage] getRequestOppoAgree:[NSString stringWithFormat:@"%ld", nUid]];
		}
		else
		{
			WaitReplyViewController *waitController = [[WaitReplyViewController alloc] initWithNibName:@"WaitReplyViewController" bundle:nil];
			SHOW_VIEW(waitController);
		}
	}
	else
	{
		MatchingViewController *matching_controller = (MatchingViewController *)matchingController;
		MatchFoundViewController *matchfound_controller = (MatchFoundViewController *)matchingFoundController;
		
		{BACK_VIEW(self);}
		{BACK_VIEW(matchfound_controller);}
		[matching_controller startTimer];
	};
}

- (void) getRequestOppoAgreeResult:(STAgreeResponse *)result
{
	if (result != nil && result.ErrCode == STATE_AGREE)
	{
		[CommManager getGlobalCommMgr].strPairedTime = result.PairedTime;

		[timer invalidate];
		timer = nil;

		CarPoolAppDelegate* appDelegate = (CarPoolAppDelegate*)[UIApplication sharedApplication].delegate;
		[appDelegate startNotificationThreadInForeground];

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
	}
	else
	{
		WaitReplyViewController *waitController = [[WaitReplyViewController alloc] initWithNibName:@"WaitReplyViewController" bundle:nil];
		SHOW_VIEW(waitController);
	}
}


- (void) onTimer
{
	if (curCount >= TIMER_LIMIT)
	{
		[self onClickReject:nil];
	}
	else
	{
		curCount += TIMER_INTERVAL;
	}
}

@end
