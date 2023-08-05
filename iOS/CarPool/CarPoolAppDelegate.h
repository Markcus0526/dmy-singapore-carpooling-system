//
//  CarPoolAppDelegate.h
//  CarPool
//
//  Created by RiKS on 9/9/13.
//  Copyright (c) 2013 RiKS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

#import "LoginViewController.h"
#import "MatchingViewController.h"
#import "WaitReplyViewController.h"
#import "CommManager.h"

#define FROM_PAIRING			0
#define FROM_FROM_AGREEMENT		1
#define FROM_OTHER_AGREE		2

@interface CarPoolAppDelegate : UIResponder <UIApplicationDelegate, UserManageDelegate>
{
	bool						stop_backtask, stop_foretask;
	UIBackgroundTaskIdentifier	bgTask;
	NSThread*					thrIsNext;

	int							notif_fromWhere;
	int							pairing_result;
	int							oppo_agree;

	STPairResponse*				pairres;

	MatchingViewController*		matching_ctrl;
	WaitReplyViewController*	waitreply_ctrl;
}

@property (strong, nonatomic) UIWindow*						window;
@property (strong, nonatomic) LoginViewController*			rootViewController;

@property (strong, nonatomic) NSThread* thrIsNext;

@property (atomic, readwrite) UIBackgroundTaskIdentifier bgTask;
@property (atomic, readwrite) bool stop_backtask;
@property (atomic, readwrite) bool stop_foretask;

@property (atomic, readwrite) int notif_fromWhere;
@property (atomic, readwrite) int pairing_result;
@property (atomic, readwrite) int oppo_agree;

@property (strong, retain) STPairResponse* pairres;

@property (nonatomic, retain) MatchingViewController*		matching_ctrl;
@property (strong, nonatomic) WaitReplyViewController*		waitreply_ctrl;

- (void)startNotificationThreadInForeground;
- (void)stopNotificationThreadInForground;


@end





