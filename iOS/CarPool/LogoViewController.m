//
//  LoginViewCotroller.m
//  CarPool
//
//  Created by RiKS on 9/10/13.
//  Copyright (c) 2013 RiKS. All rights reserved.
//

#import "LogoViewController.h"
#import "Common.h"
#import "SignInViewController.h"
#import "RegisterViewController.h"
#import "UserProfileViewController.h"
#import "DejalActivityView.h"
#import "LoginViewController.h"
#import "STDataInfo.h"
#import "TaxiStandMapViewController.h"
#import "CommManager.h"
#import "OnBoardViewController.h"


@interface LogoViewController ()

@end

@implementation LogoViewController

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
}

int gcode = 0;
- (void)presentNextView:(STLoginResult*)result
{
	UIViewController *ctrl = nil;
	if (gcode > 0)
	{
		if (result.firstLogin == 0)
			ctrl = [[TaxiStandMapViewController alloc] initWithNibName:@"TaxiStandMapViewController" bundle:nil];
		else
			ctrl = [[OnBoardViewController alloc] initWithNibName:@"OnBoardViewController" bundle:nil];
	}
	else
		ctrl = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];

	[self presentViewController:ctrl animated:NO completion:nil];
}

- (void)getLogin
{
	NSString *email = [Common readUserEmailFromFile];
	NSString *password = [Common readPasswordFromFile];

	STAuthUser *authUser = nil;
	STFLAuthInfo *fl_authInfo = nil;

	int nLoginType = [Common loadLoginType];

	if (nLoginType < 0)
	{
		UIViewController *ctrl = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
		[self presentViewController:ctrl animated:NO completion:nil];
	}
	else if (nLoginType == LOGIN_NORMAL)
	{
		authUser = [[STAuthUser alloc] init];
		authUser.Email = email;
		authUser.Password = password;

		if (authUser.Email == nil || authUser.Password == nil)
		{
			UIViewController *ctrl = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
			[self presentViewController:ctrl animated:NO completion:nil];
		}
		else
		{
			if (![Common isReachable:NO])
			{
				UIViewController *ctrl = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
				[self presentViewController:ctrl animated:NO completion:nil];
			}

			CommManager* commMgr = [CommManager getCommMgr];
			[commMgr userManage].delegate = self;
			[[commMgr userManage] getRequestLogin:authUser];
		}
	}
	else
	{
		fl_authInfo = [[STFLAuthInfo alloc] init];

		if (email == nil)
		{
			UIViewController *ctrl = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
			[self presentViewController:ctrl animated:NO completion:nil];
		}
		else
		{
			fl_authInfo.Email = email;
			fl_authInfo.Name = @"";
			fl_authInfo.Gender = 0;
			fl_authInfo.BirthYear = 0;
			fl_authInfo.PhoneNum = @"";
			fl_authInfo.ImageData = @"";

			if (![Common isReachable:NO])
			{
				UIViewController *ctrl = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
				[self presentViewController:ctrl animated:NO completion:nil];
			}

			CommManager* commMgr = [CommManager getCommMgr];
			
			[commMgr userManage].delegate = self;
			[[commMgr userManage] getRequestIsRegistedUser:fl_authInfo.Email];
		}
	}
}

- (void)getRequestIsRegistedUserResult:(STLoginResult *)result
{
	gcode = 0;

	if (result != nil && result.ResultCode > 0)
	{
		[Common writeUserIDToFile:result.ResultCode];
		[Common writeUserNameToFile:result.Name];

		gcode = 1;
	}
	else
		gcode = 0;

	[self performSelectorOnMainThread:@selector(presentNextView:) withObject:result waitUntilDone:NO];
}

- (void)getRequestLoginResult:(STLoginResult*)result
{
	gcode = 0;
	
	if (result != nil && result.ResultCode > 0)
	{
		[Common writeUserIDToFile:result.ResultCode];
		[Common writeUserNameToFile:result.Name];

		gcode = 1;
	}
	else
		gcode = 0;

	[self performSelectorOnMainThread:@selector(presentNextView:) withObject:result waitUntilDone:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[self getLogin];
}

@end
