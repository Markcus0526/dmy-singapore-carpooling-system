//
//  SignInViewController.m
//  CarPool
//
//  Created by RiKS on 9/10/13.
//  Copyright (c) 2013 RiKS. All rights reserved.
//

#import "SignInViewController.h"
#import "ImportantNoticeViewController.h"
#import "ForgotPasswordViewController.h"
#import "KeyboardHelper.h"
#import "DejalActivityView.h"
#import "CommManager.h"
#import "Common.h"
#import "TaxiStandMapViewController.h"
#import "LoginViewController.h"

@interface SignInViewController ()

@end

@implementation SignInViewController

@synthesize btnSignIn;
@synthesize btnForgot;
@synthesize txtEmail;
@synthesize txtPassword;


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
	keyboardVisible = false;
	curTextField = nil;

	userID = 0;
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

-(IBAction)onSignIn:(id)sender
{
	if ([txtEmail text].length == 0)
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ride2Gather" message:@"Please insert your email address." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		alert.tag = 0;
		[alert show];
		return;
	}

	if ([txtPassword text].length == 0)
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ride2Gather" message:@"Please insert your password." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		alert.tag = 1;
		[alert show];
		return;
	}
	
	if ([Common isValidEmail:[txtEmail text]] == false)
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ride2Gather" message:@"Please insert your valid email address." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		alert.tag = 2;
		[alert show];
		return;
	}

	[Common startDejalActivity:self.view];
	
	if (![Common isReachable:YES])
	{
		[Common endDejalActivity];
		txtEmail.enabled = YES;
		txtPassword.enabled = YES;
		return;
	}

	STAuthUser *authUser = [[STAuthUser alloc] init];
	authUser.Email = (NSString *)[txtEmail text];
	authUser.Password = (NSString *)[txtPassword text];

	CommManager* commMgr = [CommManager getCommMgr];
	[commMgr userManage].delegate = self;
    [[commMgr userManage] getRequestLogin:authUser];
}

- (IBAction)onForgotPasswordClicked:(id)sender
{
	ForgotPasswordViewController *controller = [[ForgotPasswordViewController alloc] initWithNibName:@"ForgotPasswordViewController" bundle:nil];
	controller.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	SHOW_VIEW(controller);

	return;
}

- (void)getRequestLoginResult:(STLoginResult*)result
{
	[Common endDejalActivity];

	if (result == nil || result.Message == nil)
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ride2Gather" message:@"Service Failure" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		alert.tag = 3;
		[alert show];
		
		return;
	}
	
	if (result.ResultCode <= 0)
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ride2Gather" message:result.Message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		alert.tag = 4;
		[alert show];

		return;
	}

	txtEmail.enabled = YES;
	txtPassword.enabled = YES;

	userID = result.ResultCode;
	[Common saveLoginType:LOGIN_NORMAL];

	[Common writeUserIDToFile:userID];
	[Common writeUserNameToFile:result.Name];
	[Common writeUserEmailToFile:[txtEmail text]];
	[Common writePasswordToFile:txtPassword.text];

	[Common saveUserInfo:txtEmail.text password:txtPassword.text];

	if (result.firstLogin)
	{
		ImportantNoticeViewController *controller = [[ImportantNoticeViewController alloc] initWithNibName:@"ImportantNoticeViewController" bundle:nil];
		SHOW_VIEW(controller);
	}
	else
	{
		TaxiStandMapViewController *controller = [[TaxiStandMapViewController alloc] initWithNibName:@"TaxiStandMapViewController" bundle:nil];
		SHOW_VIEW(controller);
	}
}


- (BOOL)shouldAutorotate {
	return NO;
}

///////////////////////////////////////////////////////////////////
#pragma mark - Scroll When Keyboard Focus
- (IBAction)BeginEditing:(UITextField *)sender
{
	curTextField = sender;
	if (keyboardVisible)
		[KeyboardHelper moveScrollView:curTextField scrollView:(UIScrollView*)self.view];
}

- (IBAction)EndEditing:(UITextField *)sender
{
	curTextField = nil;
	[sender resignFirstResponder];
}


- (void)keyboardWillShow:(NSNotification *)notification {
	//---gets the size of the keyboard---
	NSDictionary *userInfo = [notification userInfo];
	NSValue *keyboardValue = [userInfo objectForKey:UIKeyboardBoundsUserInfoKey];
	[keyboardValue getValue:&keyboardBounds];

	[KeyboardHelper moveScrollView:curTextField scrollView:(UIScrollView*)self.view];

	keyboardVisible = true;
}

- (void)keyboardWillHide:(NSNotification *)notification {
	//---gets the size of the keyboard---
	NSDictionary *userInfo = [notification userInfo];
	NSValue *keyboardValue = [userInfo objectForKey:UIKeyboardBoundsUserInfoKey];
	[keyboardValue getValue:&keyboardBounds];

	[KeyboardHelper moveScrollView:nil scrollView:(UIScrollView*)self.view];
	
	keyboardVisible = false;
	
	curTextField = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:self.view.window];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:self.view.window];

	[txtEmail setText:[Common getNormalEmail]];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (IBAction)btnBackgroundClicked:(id)sender
{
	if (curTextField != nil)
		[curTextField resignFirstResponder];
}

- (IBAction)onClickBack:(id)sender
{
//	[self dismissViewControllerAnimated:YES completion:nil];
	LoginViewController *controller = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
	SHOW_VIEW(controller);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if (textField == txtEmail)
	{
		[txtPassword becomeFirstResponder];
		return NO;
	}
	else
	{
		[self onSignIn:nil];
		return YES;
	}
}

@end
