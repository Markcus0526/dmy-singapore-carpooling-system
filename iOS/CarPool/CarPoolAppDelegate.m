//
//  CarPoolAppDelegate.m
//  CarPool
//
//  Created by RiKS on 9/9/13.
//  Copyright (c) 2013 RiKS. All rights reserved.
//

#import "CarPoolAppDelegate.h"
#import "LoginViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import <GoogleMaps/GoogleMaps.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "Common.h"
#import "TaxiStandMapViewController.h"
#import "RegisterViewController.h"
#import "UserProfileViewController.h"
#import "MainIAPHelper.h"
#import "BuyCreditsViewController.h"
#import "CommManager.h"
#import "LogoViewController.h"
#import "BuyCreditsViewController.h"
#import "MatchFoundViewController.h"

@implementation CarPoolAppDelegate

@synthesize window = _window;
@synthesize rootViewController = _rootViewController;

@synthesize stop_backtask;
@synthesize stop_foretask;
@synthesize pairing_result;
@synthesize oppo_agree;

@synthesize bgTask;
@synthesize thrIsNext;
@synthesize notif_fromWhere;
@synthesize matching_ctrl;
@synthesize waitreply_ctrl;
@synthesize pairres;


- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
	return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
	[GMSServices provideAPIKey:[Common getGoogleMapKey]];

	stop_backtask = stop_foretask = YES;
	notif_fromWhere = -1;

	pairres = nil;
	pairing_result = -1;
	oppo_agree = -1;

	matching_ctrl = nil;
	waitreply_ctrl = nil;

	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	long nUid = [Common readUserIdFromFile];

	if (nUid <= 0)
	{
		self.window.rootViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
	}
	else
	{
		self.window.rootViewController = [[LogoViewController alloc] initWithNibName:@"LogoViewController" bundle:nil];
	}

	[self.window makeKeyAndVisible];


	return YES;

}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
	[FBAppCall handleDidBecomeActive];

	notif_fromWhere = -1;

	pairing_result = 0;
	oppo_agree = 0;

	if (!stop_backtask)
	{
		stop_backtask = YES;
		[self startNotificationThreadInForeground];
	}
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
	if (notif_fromWhere == FROM_PAIRING)
	{
		pairing_result = -1;
		bgTask = [application beginBackgroundTaskWithExpirationHandler:^{
			[application endBackgroundTask:bgTask];
			bgTask = UIBackgroundTaskInvalid;
		}];

		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			[self onIsPaired];
			[application endBackgroundTask:bgTask];
			bgTask = UIBackgroundTaskInvalid;
		});
	}
	else if (notif_fromWhere == FROM_OTHER_AGREE)
	{
		oppo_agree = -1;
		bgTask = [application beginBackgroundTaskWithExpirationHandler:^{
			[application endBackgroundTask:bgTask];
			bgTask = UIBackgroundTaskInvalid;
		}];

		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			[self onOppoAgree];
			[application endBackgroundTask:bgTask];
			bgTask = UIBackgroundTaskInvalid;
		});
	}
	else if (!stop_foretask)
	{
		bgTask = [application beginBackgroundTaskWithExpirationHandler:^{
			NSLog(@"\n\n\n\n\nexpired\n\n\n\n\n\n");
			[application endBackgroundTask:bgTask];
			bgTask = UIBackgroundTaskInvalid;
		}];

		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
			stop_backtask = NO;
			[self onIsNextBoardInBG];

			[application endBackgroundTask:bgTask];
			bgTask = UIBackgroundTaskInvalid;
		});
	}
}


- (void)applicationWillTerminate:(UIApplication *)application {}


- (void)startNotificationThreadInForeground
{
	stop_foretask = NO;

	if (thrIsNext != nil)
	{
		[thrIsNext cancel];
		thrIsNext = nil;
	}

	thrIsNext = [[NSThread alloc] initWithTarget:self selector:@selector(onIsNextBoard) object:nil];
	[thrIsNext start];
}

- (void)stopNotificationThreadInForground
{
	stop_foretask = YES;
	thrIsNext = nil;
}

- (void)onIsNextBoard
{
	while (true)
	{
		if (stop_foretask)
			return;

		NSLog(@"\n\nForeground task\n\n");

		CommManager* commMgr = [CommManager getCommMgr];
		UserManage* userManage = [commMgr userManage];
		userManage.delegate = self;
		[userManage getPairIsNext];

		[NSThread sleepForTimeInterval:SEND_INTERVAL];

		NSLog(@"time : %f", [NSDate timeIntervalSinceReferenceDate]);
	}
}

- (void)onIsNextBoardInBG
{
	while (true)
	{
		if (stop_backtask)
			return;

		NSLog(@"\n\nBackground task\n\n");

		CommManager* commMgr = [CommManager getCommMgr];
		UserManage* userManage = [commMgr userManage];
		userManage.delegate = self;
		[userManage getPairIsNext];

		[NSThread sleepForTimeInterval:SEND_INTERVAL];

		NSLog(@"time : %f", [NSDate timeIntervalSinceReferenceDate]);
	}
}

- (void)getPairIsNextResult:(StringContainer *)result
{
	if (result != nil && result.Result == 1)
	{
		stop_foretask = YES;
		stop_backtask = YES;

		NSString* szMsg = @"Your party is in the taxi stand";
		NSDictionary* dict = [[NSBundle mainBundle] infoDictionary];
		NSString* szAppName = [dict objectForKey:@"CFBundleDisplayName"];

		if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive)
		{
			UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:szAppName message:szMsg delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil, nil];
			[alertView show];
		}
		else
		{
//			UILocalNotification* notif = [[UILocalNotification alloc] init];
//
//			[notif setAlertBody:szMsg];
//			[notif setFireDate:nil];			// Start notification immediately
//			[notif setHasAction:NO];			// No alert button or slider
//			[notif setRepeatCalendar:nil];		// User current calendar for notification
//			[notif setRepeatInterval:0];		// No repeat
//			[notif setSoundName:@"notify.caf"];
//
//			[[UIApplication sharedApplication] scheduleLocalNotification:notif];
			[Common showNotification:szMsg];
		}

//		AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
//		[Common playsound];
	}
}

- (void)onIsPaired
{
	while (true)
	{
		if (pairing_result >= 0)
			return;

		if (matching_ctrl.nRequestCurCount * SEND_INTERVAL >= SEND_LIMIT)
		{
			[NSThread detachNewThreadSelector:@selector(logoutThread) toTarget:self withObject:nil];
			return;
		}

		matching_ctrl.nRequestCurCount++;

		CommManager* commMgr = [CommManager getCommMgr];
		[commMgr pairManage].delegate = (id<PairManageDelegate>)self;
		[[commMgr pairManage] getRequestIsPaired];

		[NSThread sleepForTimeInterval:SEND_INTERVAL];
	}
}

- (void)onOppoAgree
{
	while (true)
	{
		if (oppo_agree >= 0)
			return;

		CommManager* commMgr = [CommManager getCommMgr];
		[commMgr userManage].delegate = self;
		[[commMgr userManage] getRequestOppoAgree:[NSString stringWithFormat:@"%ld", [Common readUserIdFromFile]]];

		[NSThread sleepForTimeInterval:SEND_INTERVAL];
	}
}

-(void) getRequestOppoAgreeResult:(STAgreeResponse *)result
{
	if (result == NULL)
		return;

	if (result.ErrCode != STATE_NOREPLY)
	{
		oppo_agree = 0;

		if (result.ErrCode == STATE_AGREE)
		{
			[CommManager getGlobalCommMgr].strPairedTime = result.PairedTime;
			[Common showNotification:OPPO_AGREED];
		}
		else
		{
			[Common showNotification:OPPO_DISAGREED];
		}
	}
}

-(void) getRequestIsPairedResult:(STPairResponse*)res
{
	if (res == nil)
		return;

	CommManager *commMgr = [CommManager getGlobalCommMgr];

	if (res.ErrCode == 1)
	{
		pairing_result = 0;

		UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:STR_APPNAME message:PAIR_SUCCESS delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil, nil];
		[alertView show];

		pairres = res;
		commMgr.g_pairResp = pairres;

		[Common showNotification:PAIR_SUCCESS];
	}
	else if (res.ErrCode == ERR_INVALID_USER)
	{
		pairing_result = 1;
	};
}


- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
	if (pairing_result == 0 && pairres != nil)
	{
		MatchFoundViewController *controller = [[MatchFoundViewController alloc] initWithNibName:@"MatchFoundViewController" bundle:nil];

		CommManager* commMgr = [CommManager getGlobalCommMgr];

		controller.start_coord = CLLocationCoordinate2DMake(commMgr.fSrcLat, commMgr.fSrcLon);
		controller.dst_coord = CLLocationCoordinate2DMake(commMgr.fDstLat, commMgr.fDstLon);
		controller.pairResp = pairres;
		controller.parentController = matching_ctrl;

		CATransition *animation = [CATransition animation];
		[animation setDuration:0.3];
		[animation setType:kCATransitionPush];
		[animation setSubtype:kCATransitionFromLeft];
		[animation setTimingFunction:[CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut]];
		[[matching_ctrl.view.superview layer] addAnimation:animation forKey:@"SwitchToView"];
		[matching_ctrl presentViewController:controller animated:NO completion:nil];
	}
	else if (pairing_result == 1)
	{
		TaxiStandMapViewController* controller = [[TaxiStandMapViewController alloc] initWithNibName:@"TaxiStandMapViewController" bundle:nil];

		CATransition *animation = [CATransition animation];
		[animation setDuration:0.3];
		[animation setType:kCATransitionPush];
		[animation setSubtype:kCATransitionFromLeft];
		[animation setTimingFunction:[CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut]];
		[[matching_ctrl.view.superview layer] addAnimation:animation forKey:@"SwitchToView"];
		[matching_ctrl presentViewController:controller animated:NO completion:nil];
	}
}


@end






