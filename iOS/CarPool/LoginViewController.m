//
//  LoginViewCotroller.m
//  CarPool
//
//  Created by RiKS on 9/10/13.
//  Copyright (c) 2013 RiKS. All rights reserved.
//

#import "LoginViewController.h"
#import "Common.h"
#import "SignInViewController.h"
#import "RegisterViewController.h"
#import "UserProfileViewController.h"
#import "DejalActivityView.h"
#import "ASIHTTPRequest.h"
#import "SBJson.h"
#import "CommManager.h"
#import "TaxiStandMapViewController.h"
#import "OnBoardViewController.h"

@interface LoginViewController()
@end

@implementation LoginViewController

int loginType = LOGIN_NORMAL;

@synthesize btnFacebookLogin;
@synthesize btnSignIn;
@synthesize btnRegister;

@synthesize ll_app;
@synthesize ll_client;
@synthesize ll_id;
@synthesize ll_accessToken;
@synthesize ll_year;
@synthesize ll_month;
@synthesize ll_day;
@synthesize ll_email;
@synthesize ll_name;
@synthesize ll_phone;
@synthesize ll_photo_url;
@synthesize ll_gender;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if ([Common getPhoneType] == IPHONE5)
		nibNameOrNil = [nibNameOrNil stringByAppendingString:@"_ios5"];
	
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

	if (self)
	{
		ll_year = ll_month = ll_day = 0;
	}

	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view from its nib.	
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

-(IBAction) btnSignInClick:(id)sender
{
	SignInViewController *controller = [[SignInViewController alloc] initWithNibName:@"SignInViewController" bundle:nil];
	controller.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	SHOW_VIEW(controller);
}

-(IBAction) btnRegisterClick:(id)sender
{
	RegisterViewController *controller = [[RegisterViewController alloc] initWithNibName:@"RegisterViewController" bundle:nil];
	controller.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	SHOW_VIEW(controller);
}

-(IBAction)btnFacebookLoginClick:(id)sender
{
	loginType = LOGIN_FACEBOOK;

	if (![self loadFaceBookInfo])
	{
		[Common startDejalActivity:self.view];
		FBSessionState state = [FBSession activeSession].state;
		if (state == FBSessionStateOpen || state == FBSessionStateCreatedTokenLoaded)
		{
			FBSession* session = [FBSession activeSession];
			[session closeAndClearTokenInformation];
			[session close];
			[FBSession setActiveSession:nil];
		}

		NSArray* permission = [NSArray arrayWithObjects:@"publish_actions", nil];
		[FBSession openActiveSessionWithPublishPermissions:permission defaultAudience:FBSessionDefaultAudienceOnlyMe allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
			[Common endDejalActivity];
			if (session.state == FBSessionStateOpen)
			{
				[Common startDejalActivity:self.view];
				[[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection, NSDictionary<FBGraphUser>* result, NSError *error) {
					[Common endDejalActivity];
/*
 birthday = "09/01/1985";
 email = "bill19850901@hotmail.com";
 "first_name" = Bill;
 gender = male;
 id = 100005884837280;
 "last_name" = Luo;
 link = "https://www.facebook.com/bill.luo.167";
 locale = "en_US";
 name = "Bill Luo";
 timezone = 8;
 "updated_time" = "2013-11-08T06:42:00+0000";
 username = "bill.luo.167";
 verified = 1;
*/
					if (!error)
					{
						NSString* birth = [result objectForKey:@"birthday"];
						if (birth.length >= 4)
						{
							NSString* year = [birth substringFromIndex:birth.length - 4];
							ll_month = 0;
							ll_day = 0;
							ll_year = [year intValue];
						}
						else
						{
							ll_month = 0;
							ll_day = 0;
							ll_year = 0;
						}

						ll_id = [result objectForKey:@"id"];
						ll_email = [result objectForKey:@"email"];
						ll_name = [result objectForKey:@"name"];
						ll_phone = @"";
						ll_gender = [result objectForKey:@"gender"];
						ll_photo_url = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large", ll_id];

						[Common startDejalActivity:self.view];
						[Common saveFacebookInfo:ll_email phone:ll_phone name:ll_name year:ll_year month:ll_month day:ll_day token:ll_accessToken photo:ll_photo_url];

						UserManage* usermanage = [[CommManager getCommMgr] userManage];
						usermanage.delegate = self;
						[usermanage getRequestIsRegistedUser:ll_email];
					}
					else
					{
						[Common showAlert:@"Getting user info failed."];
					}
				}];
			}
			else
			{
				NSLog(@"Failed to login facebook");
			}
		}];
		

	}
}


- (BOOL) loadFaceBookInfo
{
	BOOL is_success = YES;
	
	NSDictionary *resultDict = [NSDictionary dictionaryWithContentsOfFile:[Common fbFilePath]];
	if (resultDict == nil)
	{
		is_success = NO;
	}
	else
	{
		NSString *szYear;
		ll_id = [resultDict objectForKey:KEY_CLIENT];
		ll_email = [resultDict objectForKey:KEY_EMAIL];
		ll_phone = [resultDict objectForKey:KEY_PHONE];
		ll_name = [resultDict objectForKey:KEY_NAME];
		szYear = [resultDict valueForKey:KEY_YEAR];
		ll_gender = [resultDict objectForKey:KEY_GENDER];

		if (ll_id == nil ||
			ll_email == nil ||
			ll_phone == nil ||
			ll_name == nil ||
			ll_gender == nil ||
			szYear == nil)
		{
			is_success = false;
		}

		ll_year = [szYear intValue];

		if (is_success)
		{
			[Common startDejalActivity:self.view];

			CommManager* commMgr = [CommManager getCommMgr];
			[commMgr userManage].delegate = self;
			loginType = LOGIN_FACEBOOK;
			[[commMgr userManage] getRequestIsRegistedUser:ll_email];
		}
	}

	return is_success;
}


-(BOOL) loadLinkedinInfo
{
	BOOL is_success = YES;

	NSDictionary *resultDict = [NSDictionary dictionaryWithContentsOfFile:[Common llFilePath]];
	if (resultDict == nil)
	{
		is_success = NO;
	}
	else
	{
		NSString *szYear = nil, *szMonth = nil, *szDay = nil;
		ll_email = [resultDict objectForKey:KEY_EMAIL];
		ll_phone = [resultDict objectForKey:KEY_PHONE];
		ll_name = [resultDict objectForKey:KEY_NAME];
		szYear = [resultDict valueForKey:KEY_YEAR];
		szMonth = [resultDict valueForKey:KEY_MONTH];
		szDay = [resultDict valueForKey:KEY_DAY];
		ll_accessToken = [resultDict objectForKey:KEY_TOKEN];
		ll_photo_url = [resultDict objectForKey:KEY_PHOTO];
		ll_gender = [resultDict objectForKey:KEY_GENDER];

		if (ll_email == nil || ll_phone == nil || ll_name == nil || szYear == nil || szMonth == nil || szDay == nil)
		{
			is_success = false;
		}

		ll_year = [szYear intValue];
		ll_month = [szMonth intValue];
		ll_day = [szDay intValue];

		if (is_success)
		{
			[Common startDejalActivity:self.view];
			loginType = LOGIN_LINKEDIN;

			CommManager* commMgr = [CommManager getCommMgr];
			[commMgr userManage].delegate = self;
			[[commMgr userManage] getRequestIsRegistedUser:ll_email];
		}
	}

	return is_success;
}


-(IBAction) btnLinkedinLoginClick:(id)sender
{
	loginType = LOGIN_LINKEDIN;

	[self loadllINfo];
}


- (void) showLinkedinViewController:(BOOL)editing
{
	[Common endDejalActivity];

	UserProfileViewController *controller = [[UserProfileViewController alloc] initWithNibName:@"UserProfileViewController" bundle:nil];
	controller.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	controller.userProfile = PROFILE_LINKEDIN;
	controller.ll_year = self.ll_year;
	controller.ll_month = self.ll_month;
	controller.ll_day = self.ll_day;
	controller.ll_email = self.ll_email;
	controller.ll_phone = self.ll_phone;
	controller.ll_name = self.ll_name;
	controller.ll_photo_url = self.ll_photo_url;
	controller.ll_accessToken = self.ll_accessToken;
	controller.ll_gender = self.ll_gender;
	controller.editing = editing;

	SHOW_VIEW(controller);
//	[self presentViewController:controller animated:YES completion:nil];
}

/***********************************************************************/
/***************   Linkedin information functions   ********************/
/***********************************************************************/
- (void) loadllINfo
{
	ll_app = [LIALinkedInApplication applicationWithRedirectURL:@"http://www.ancientprogramming.com"
													   clientId:@"m9mb1adrvg5q"
												   clientSecret:@"KpMWorvxigMhKjkk"
														  state:@"DCEEFWF45453sdffef424"
												  grantedAccess:@[@"r_fullprofile", @"r_basicprofile", @"r_emailaddress", @"r_contactinfo"]];

	ll_client = [LIALinkedInHttpClient clientForApplication:ll_app presentingViewController:self];

	[Common startDejalActivity:self.view];
	if ([self loadLinkedinInfo] == NO)
	{
		[ll_client getAuthorizationCode:^(NSString* code)
		 {
			 [self.ll_client getAccessToken:code success:^(NSDictionary *accessTokenData)
			 {
				 self.ll_accessToken = [accessTokenData objectForKey:@"access_token"];

				 [self getLinkedinInfo];
			 }
			 failure:^(NSError *error)
			 {
				 [Common endDejalActivity];
				 NSLog(@"Quering accessToken failed %@", error);
				 [Common showAlert:@"Quering accessToken failed"];

			 }];
		 }
		 cancel:^{
			 [Common endDejalActivity];
			 NSLog(@"Authorization was cancelled by user");
			 [Common showAlert:@"Authorization was cancelled by user"];
		 }
		 failure:^(NSError *error)
		 {
			 [Common endDejalActivity];
			 NSString *szErr = [NSString stringWithFormat:@"Authorization failed %@", error];
			 NSLog(@"%@", szErr);
			 [Common showAlert:@"Authorization failed"];
		 }];
	}
}

- (void) getLinkedinInfo
{
	NSString *url_request = [NSString stringWithFormat:@"https://api.linkedin.com/v1/people/~:(id,formatted-name,industry,phone-numbers,date-of-birth,email-address,picture-url)?oauth2_access_token=%@&format=json", self.ll_accessToken];

	[self.ll_client getPath:url_request parameters:nil
					success:^(AFHTTPRequestOperation *operation, NSDictionary *result)
	 {
		 NSLog(@"current user %@", result);

		 NSDictionary *phone_value = [result objectForKey:@"phoneNumbers"];
		 NSDictionary *date_value = [result objectForKey:@"dateOfBirth"];
		 NSMutableArray *phone_array = nil;
		 NSString *szTemp = nil;

		 ll_gender = @"Male";
		 ll_email = [result objectForKey:@"emailAddress"];
		 ll_name = [result objectForKey:@"formattedName"];

		 szTemp = [date_value objectForKey:@"year"];
		 ll_year = [szTemp intValue];

		 szTemp = [date_value valueForKey:@"month"];
		 ll_month = [szTemp intValue];

		 szTemp = [date_value valueForKey:@"day"];
		 ll_day = [szTemp intValue];

		 ll_photo_url = [result objectForKey:@"pictureUrl"];

		 phone_array = [phone_value objectForKey:@"values"];

		 int i = 0, nCount = [phone_array count];
		 if (nCount > 0)
		 {
			 for (; i < nCount; i++)
			 {
				 NSDictionary *phone_item = [phone_array objectAtIndex:i];

				 if (i == 0)
					 ll_phone = [phone_item objectForKey:@"phoneNumber"];

				 NSString *phone_type = [phone_item objectForKey:@"phoneType"];
				 if ([phone_type isEqualToString:@"mobile"])
				 {
					 ll_phone = [phone_item objectForKey:@"phoneNumber"];
					 break;
				 }
			 }
		 }

		 [Common saveLinkedinInfo:ll_email phone:ll_phone name:ll_name year:ll_year month:ll_month day:ll_day token:ll_accessToken photo:ll_photo_url];

		 UserManage* usermanage = [[CommManager getCommMgr] userManage];
		 usermanage.delegate = self;
		 [usermanage getRequestIsRegistedUser:ll_email];
	 }
	 failure:^(AFHTTPRequestOperation *operation, NSError *error)
	 {
		 NSLog(@"failed to fetch current user %@", error);
		 [Common endDejalActivity];
		 [Common showAlert:@"Failed to fetch current user"];
	 }];
}

- (void) initVariables
{
	ll_accessToken = nil;
	ll_app = nil;

	ll_year = ll_month = ll_day = 0;
	ll_email = @"";
	ll_name = @"";
	ll_phone = @"";
	ll_photo_url = @"";
}

- (void)showFacebookViewController:(BOOL)editing
{
	UserProfileViewController *profileViewController = [[UserProfileViewController alloc] initWithNibName:@"UserProfileViewController" bundle:nil];

	profileViewController.ll_client = ll_id;
	profileViewController.ll_year = ll_year;
	profileViewController.ll_email = ll_email;
	profileViewController.ll_name = ll_name;
	profileViewController.ll_phone = ll_phone;
	profileViewController.ll_gender = ll_gender;
	profileViewController.editable = editing;

	SHOW_VIEW(profileViewController);
}

- (void)getRequestIsRegistedUserResult:(STLoginResult *)result
{
	if (result.ResultCode > 0)
	{
		[Common writePasswordToFile:@""];
		[Common writeUserEmailToFile:ll_email];
		[Common writeUserIDToFile:result.ResultCode];
		[Common writeUserNameToFile:result.Name];

		[Common saveLoginType:loginType];

		TaxiStandMapViewController* controller = [[TaxiStandMapViewController alloc] initWithNibName:@"TaxiStandMapViewController" bundle:nil];
		SHOW_VIEW(controller);
	}
	else
	{
		if (loginType == LOGIN_FACEBOOK)
		{
			[self showFacebookViewController:YES];
		}
		else
		{
			[self showLinkedinViewController:YES];
		}
	}
}

@end
