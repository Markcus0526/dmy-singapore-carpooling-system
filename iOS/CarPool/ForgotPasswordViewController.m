//
//  ForgotPasswordViewController.m
//  CarPool
//
//  Created by RiKS on 10/13/13.
//  Copyright (c) 2013 RiKS. All rights reserved.
//

#import "ForgotPasswordViewController.h"
#import "KeyboardHelper.h"
#import "DejalActivityView.h"
#import "Common.h"
#import "STDataInfo.h"
#import "CommManager.h"
#import "LoginViewController.h"
#import "SignInViewController.h"

@interface ForgotPasswordViewController ()

@end

@implementation ForgotPasswordViewController

@synthesize txtEmail;

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
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
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


- (void)keyboardWillShow:(NSNotification *)notification
{
	//---gets the size of the keyboard---
	NSDictionary *userInfo = [notification userInfo];
	NSValue *keyboardValue = [userInfo objectForKey:UIKeyboardBoundsUserInfoKey];
	[keyboardValue getValue:&keyboardBounds];
	
	[KeyboardHelper moveScrollView:curTextField scrollView:(UIScrollView*)self.view];
	
	keyboardVisible = true;
}

- (void)keyboardWillHide:(NSNotification *)notification
{
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

- (IBAction)onClickSend:(id)sender
{
	if ([txtEmail.text isEqualToString:@""])
	{
		[Common showAlert:@"Please insert email address."];
		return;
	}

	if (![Common isValidEmail:txtEmail.text])
	{
		[Common showAlert:@"Email format invalid."];
		return;
	}

	STReqResetPassword *reqReset = [[STReqResetPassword alloc] init];
	reqReset.email = txtEmail.text;

	if (![Common isReachable:YES])
		return;

	[Common startDejalActivity:self.view];

	CommManager* commMgr = [CommManager getCommMgr];
	[commMgr userManage].delegate = self;
	[[commMgr userManage] getRequestResetPassword:reqReset];
}

- (void)getRequestResetPasswordResult:(StringContainer *)szRes
{
	[Common endDejalActivity];

	if (szRes == nil)
	{
		[Common showAlert:@"Service failure"];
		[self onClickBack:nil];
	}
	else
	{
		if (szRes.Result == 1)
		{
			[Common showAlert:@"Message is already sent to your Email."];
			[self onClickBack:nil];
		}
		else
		{
			[Common showAlert:@"Message send failed."];
			[self onClickBack:nil];
		}
	}
}

- (IBAction)onClickBack:(id)sender
{
	SignInViewController *controller = [[SignInViewController alloc] initWithNibName:@"SignInViewController" bundle:nil];
	SHOW_VIEW(controller);
}

@end















