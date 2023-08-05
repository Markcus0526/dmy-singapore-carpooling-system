//
//  WaitReplyViewController.m
//  CarPool
//
//  Created by KimHakMin on 10/16/13.
//  Copyright (c) 2013 RiKS. All rights reserved.
//

#import "WaitReplyViewController.h"
#import "Common.h"
#import "STDataInfo.h"
#import "CommManager.h"
#import "OppoDetailViewController.h"
#import "MatchingViewController.h"
#import "CarPoolAppDelegate.h"

@interface WaitReplyViewController ()

@end

@implementation WaitReplyViewController

@synthesize label;
@synthesize timer;
@synthesize mainButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if ([Common getPhoneType] == IPHONE5)
	{
		self = [super initWithNibName:[NSString stringWithFormat:@"%@_ios5", nibNameOrNil] bundle:nibBundleOrNil];
	}
	else
		self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

	if (self)
	{
		// Custom initialization
		timer = nil;
		agree_state = STATE_NOREPLY;
	}

	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view from its nib.

	[label sizeToFit];
	[label setLineBreakMode:NSLineBreakByWordWrapping];

	CarPoolAppDelegate* appDelegate = (CarPoolAppDelegate*)[UIApplication sharedApplication].delegate;
	appDelegate.notif_fromWhere = FROM_OTHER_AGREE;
	appDelegate.waitreply_ctrl = self;

	timer = [NSTimer scheduledTimerWithTimeInterval:SEND_INTERVAL target:self selector:@selector(onTimer) userInfo:nil repeats:YES];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (IBAction)onClickButton:(id)sender
{
	if (agree_state == STATE_AGREE)
	{
		OppoDetailViewController *controller = [[OppoDetailViewController alloc] initWithNibName:@"OppoDetailViewController" bundle:nil];
		SHOW_VIEW(controller);
	}
	else
	{
		MatchingViewController *controller = [[MatchingViewController alloc] initWithNibName:@"MatchingViewController" bundle:nil];
		SHOW_VIEW(controller);
	}
}

- (void)onTimer
{
	CommManager* commMgr = [CommManager getCommMgr];

	long nUid = [Common readUserIdFromFile];

	[commMgr userManage].delegate = self;
	[[commMgr userManage] getRequestOppoAgree:[NSString stringWithFormat:@"%ld", nUid]];

}

- (void) getRequestOppoAgreeResult:(STAgreeResponse *)result
{
	if (result != nil)
	{
		if (result.ErrCode != STATE_NOREPLY)
		{
			[mainButton setHidden:NO];

			if (result.ErrCode == STATE_AGREE)
			{
				[label setText:@"Congratulations! The other party has also agreed to share a taxi with you!"];
				[mainButton setTitle:@"More about the other party" forState:UIControlStateNormal];

				[CommManager getGlobalCommMgr].strPairedTime = result.PairedTime;

				[timer invalidate];
				timer = nil;

				CommManager* commMgr = [CommManager getGlobalCommMgr];
				if (commMgr.g_pairResp.QueueOrder == 1)				// Off secondarily
				{
					CarPoolAppDelegate* appDelegate = (CarPoolAppDelegate*)[UIApplication sharedApplication].delegate;
					[appDelegate startNotificationThreadInForeground];
				}
			}
			else				// Opponent disagreed or deleted
			{
				[label setText:@"Oops, unfortunately the other party is not agreeable to share a taxi. We will keep searching for another candidate that suits your sharing criteria."];

				[mainButton setTitle:@"Continue Searching" forState:UIControlStateNormal];
				[timer invalidate];
				timer = nil;
			}

			agree_state = result.ErrCode;
			[label sizeToFit];
		}
	}
}

@end
