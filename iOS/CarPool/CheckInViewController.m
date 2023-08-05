//
//  CheckInViewController.m
//  CarPool
//
//  Created by RiKS on 10/4/13.
//  Copyright (c) 2013 RiKS. All rights reserved.
//

#import "CheckInViewController.h"
#import "MatchingViewController.h"
#import "Common.h"
#import "CommManager.h"
#import "DejalActivityView.h"
#import "TaxiStandMapViewController.h"

@interface CheckInViewController ()

@end

@implementation CheckInViewController

@synthesize nPax;
@synthesize nGrpGender;
@synthesize fSrcLat;
@synthesize fSrcLon;
@synthesize fDstLat;
@synthesize fDstLon;
@synthesize strDstAddress;
@synthesize strColor;
@synthesize strOtherFeature;

@synthesize btnAmend;
@synthesize btnConfirm;
@synthesize txtConfirmData;

@synthesize pairInfo;
@synthesize pairResponse;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if ([Common getPhoneType] == IPHONE5)
		nibNameOrNil = [nibNameOrNil stringByAppendingString:@"_ios5"];
	
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

	if (self) {
		// Custom initialization
	}
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
	
	NSString *data;
	if (self.nPax == 1)
	{
		data = [NSString stringWithFormat:@"Your destination :\n\t%@\n\nYou are %d person.\n\nColour of your top is %@", self.strDstAddress, self.nPax, self.strColor];
	}
	else
	{
		data = [NSString stringWithFormat:@"Your destination :\n\t%@\n\nYou are %d persons.\n\nColour of your top is %@", self.strDstAddress, self.nPax, self.strColor];
	}

	if (self.strOtherFeature != nil && ![self.strOtherFeature isEqualToString:@""])
	{
		NSString* szOtherFeature = [NSString stringWithFormat:@"\n\nYour Other feature is %@", self.strOtherFeature];
		data = [data stringByAppendingString:szOtherFeature];
	}

	[txtConfirmData setText:data];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (IBAction)onAmend:(id)sender
{
	TaxiStandMapViewController *controller = [[TaxiStandMapViewController alloc] initWithNibName:@"TaxiStandMapViewController" bundle:nil];
	SHOW_VIEW(controller);
}

- (IBAction)onConfirm:(id)sender
{
	CommManager *g_commMgr = [CommManager getGlobalCommMgr];

	g_commMgr.fSrcLat = self.fSrcLat;
	g_commMgr.fSrcLon = self.fSrcLon;
	g_commMgr.fDstLat = self.fDstLat;
	g_commMgr.fDstLon = self.fDstLon;
	g_commMgr.strDstAddress = self.strDstAddress;
	g_commMgr.nPax = self.nPax;
	g_commMgr.nGrpGender = self.nGrpGender;
	g_commMgr.strColor = self.strColor;
	g_commMgr.strOtherFeature = self.strOtherFeature;

	pairInfo = [[STPairInfo alloc] init];
	pairResponse = nil;
	pairInfo.Uid = [Common readUserIdFromFile];
	pairInfo.SrcLat = g_commMgr.fSrcLat;
	pairInfo.SrcLon = g_commMgr.fSrcLon;
	pairInfo.DstLat = g_commMgr.fDstLat;
	pairInfo.DstLon = g_commMgr.fDstLon;
	pairInfo.Destination = g_commMgr.strDstAddress;
	pairInfo.Count = g_commMgr.nPax;
	pairInfo.GrpGender = g_commMgr.nGrpGender;
	pairInfo.Color = g_commMgr.strColor;
	pairInfo.OtherFeature = g_commMgr.strOtherFeature;

	if ([Common isReachable:YES])
	{
		[Common startDejalActivity:self.view];
		CommManager* commMgr = [CommManager getCommMgr];
		[commMgr pairManage].delegate = (id<PairManageDelegate>)self;
		[[commMgr pairManage] getRequestPair:pairInfo];
	}
}

- (void)getRequestPairResult:(StringContainer*)szRes
{
	[Common endDejalActivity];

	if (szRes.Result == 1)
	{
		MatchingViewController *controller = [[MatchingViewController alloc] initWithNibName:@"MatchingViewController" bundle:nil];
		SHOW_VIEW(controller);
	}
	else
	{
		[Common showAlert:@"Add on queue failed."];
	}
}

@end
