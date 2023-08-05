//
//  ProfileViewController.m
//  CarPool
//
//  Created by KimHakMin on 10/6/13.
//  Copyright (c) 2013 RiKS. All rights reserved.
//

#import "ProfileViewController.h"
#import "Common.h"
#import "CommManager.h"
#import "LoginViewController.h"
#import "KeyboardHelper.h"
#import "DejalActivityView.h"


@interface ProfileViewController ()

@end

@implementation ProfileViewController

@synthesize txtEmail;
@synthesize txtPhone;
@synthesize txtYear;
@synthesize btnEdit;
@synthesize btnLogOut;
@synthesize btnSelectPhoto;
@synthesize imageChanged;
@synthesize gotProfile;

@synthesize imgStar1;
@synthesize imgStar2;
@synthesize imgStar3;
@synthesize imgStar4;
@synthesize imgStar5;
@synthesize scrollview;
@synthesize imgView;
@synthesize pickerController;
@synthesize ratingView;

@synthesize profile;
@synthesize lblName;

#define CONFIRM_ALERT			999

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if ( [Common getPhoneType] == IPHONE5 )
	{
		NSMutableString *nibName = [NSMutableString string];
		[nibName appendString:@"ProfileViewController_ios5"];
		self = [super initWithNibName:nibName bundle:nibBundleOrNil];
	}
	else
		self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

	if (self)
	{
		profile = nil;
		imageChanged = NO;
		gotProfile = NO;
	}

	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view from its nib.		
	keyboardVisible = false;
	curTextField = nil;

	[ratingView setCanEdit:NO];
	[ratingView setSelectedStar:[UIImage imageNamed:@"selected_star.png"]];
	[ratingView setHalfSelectedStar:[UIImage imageNamed:@"half_selected_star.png"]];
	[ratingView setNotSelectedStar:[UIImage imageNamed:@"not_selected_star.png"]];
	[ratingView setBackgroundColor:[UIColor clearColor]];

	if ([Common loadLoginType] != LOGIN_NORMAL)
		btnEdit.hidden = YES;

}

- (void)viewDidAppear:(BOOL)animated
{
	if (!gotProfile)
	{
		if (![Common isReachable:YES])
			return;

		[Common startDejalActivity:self.view];
		
		gotProfile = YES;

		CommManager* commMgr = [CommManager getCommMgr];
		[commMgr userManage].delegate = self;
		[[commMgr userManage] getRequestUserProfile];
	}
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

-(IBAction) onClickEdit:(id)sender
{
	[txtEmail setEnabled:NO];
	[txtPhone setEnabled:YES];
	[txtYear setEnabled:YES];

	[txtPhone becomeFirstResponder];
}

-(IBAction) onClickLogOut:(id)sender
{
	int nLoginType = [Common loadLoginType];

	if (profile != nil && profile.ErrCode > 0)
	{
		bool bNeedUpdate = false;
		/*
		if (![[txtEmail text] isEqualToString:profile.Email])
		{
			if (![Common isValidEmail:[txtEmail text]])
			{
				[Common showAlert:@"Email format invalid."];
				return;
			}

			bNeedUpdate = true;
			profile.Email = txtEmail.text;
		}
		 */

		/*
		if ([txtPhone.text isEqualToString:@""])
		{
			[Common showAlert:@"Please insert your phone number"];
			return;
		}
		 */

		if (![[txtPhone text] isEqualToString:profile.PhoneNum])
		{
			if (![Common isValidPhoneNum:txtPhone.text])
			{
				[Common showAlert:@"Phone number format invalid."];
				return;
			}

			bNeedUpdate = true;
			profile.PhoneNum = txtPhone.text;
		}

		if (![Common isValidBirthYear:txtYear.text])
		{
			[Common showAlert:@"Please insert valid year of birthday."];
			return;
		}

		if ([txtYear.text intValue] != profile.BirthYear)
		{
			bNeedUpdate = true;
			profile.BirthYear = [txtYear.text intValue];
		}

		if (imageChanged)
		{
			bNeedUpdate = true;
			profile.ImageData = [Common image2String:imgView.image];
		}

		if (bNeedUpdate)
		{
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Ride2Gather" message:@"Your profile is changed. Do you want to save?" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Cancel", nil];
			alertView.tag = CONFIRM_ALERT;
			[alertView show];
		}
		else
		{
			if (nLoginType == LOGIN_LINKEDIN)
				[Common clearLinkedinInfo];
			else if (nLoginType == LOGIN_FACEBOOK)
				[Common clearFacebookInfo];
			else
				[Common deleteUserInfoFile];

			LoginViewController *ctrl = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
			SHOW_VIEW(ctrl);
		}
	}
	else
	{
		if (nLoginType == LOGIN_LINKEDIN)
			[Common clearLinkedinInfo];
		else if (nLoginType == LOGIN_FACEBOOK)
			[Common clearFacebookInfo];
		else
			[Common deleteUserInfoFile];

		LoginViewController *ctrl = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
		SHOW_VIEW(ctrl);

	}
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (buttonIndex == 0 && alertView.tag == CONFIRM_ALERT)
	{
		if (![Common isReachable:YES])
			return;
		[Common startDejalActivity:self.view];
		CommManager* commMgr = [CommManager getCommMgr];
		[commMgr userManage].delegate = self;
		[[commMgr userManage] getRequestUserProfileUpdate:profile];
	}
	else
	{
		[Common endDejalActivity];
		[Common deleteUserInfoFile];
		LoginViewController *ctrl = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
		SHOW_VIEW(ctrl);
	}
}

- (void)getRequestUserProfileUpdateResult:(StringContainer *)szRes
{
	[Common endDejalActivity];

	int nLoginType = [Common loadLoginType];
	if (nLoginType == LOGIN_NORMAL)
		[Common clearUserInfo];
	else if (nLoginType == LOGIN_FACEBOOK)
		[Common clearFacebookInfo];
	else
		[Common clearLinkedinInfo];

	[Common deleteUserInfoFile];

	if (szRes != nil)
	{
		if (szRes.Result == 1)
		{
			NSLog(@"Update succeeded!");

			LoginViewController *ctrl = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
			SHOW_VIEW(ctrl);
		}
		else
		{
			NSLog(@"Update failed.");
		}
	}
	else
	{
		LoginViewController *ctrl = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
		SHOW_VIEW(ctrl);
//		[self presentViewController:ctrl animated:YES completion:nil];
	}
}

- (IBAction)onClickSelectPhoto:(id)sender
{
	pickerController = [[UIImagePickerController alloc]init];
	[pickerController setDelegate:self];
	
	[pickerController setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
	[pickerController setAllowsEditing:NO];
	SHOW_VIEW(pickerController);
//	[self presentViewController:pickerController animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	UIImage *orgImage = [info objectForKey:UIImagePickerControllerOriginalImage];

	NSData *data = UIImageJPEGRepresentation(orgImage, 1.0f);
	UIImage *imgNew = [UIImage imageWithData:data];
	[imgView setImage:imgNew];
	imageChanged = YES;

//	[picker dismissViewControllerAnimated:YES completion:nil];
	BACK_VIEW(picker);
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
//	[pickerController dismissViewControllerAnimated:YES completion:nil];
	BACK_VIEW(pickerController);
}

///////////////////////////////////////////////////////////////////
#pragma mark - Scroll When Keyboard Focus
- (IBAction)BeginEditing:(UITextField *)sender
{
	curTextField = sender;
	if (keyboardVisible)
		[KeyboardHelper moveScrollView:curTextField scrollView:scrollview];
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
	[KeyboardHelper moveScrollView:curTextField scrollView:scrollview];
	keyboardVisible = true;
}

- (void)keyboardWillHide:(NSNotification *)notification
{
	//---gets the size of the keyboard---
	NSDictionary *userInfo = [notification userInfo];
	NSValue *keyboardValue = [userInfo objectForKey:UIKeyboardBoundsUserInfoKey];
	[keyboardValue getValue:&keyboardBounds];
	[KeyboardHelper moveScrollView:nil scrollView:scrollview];
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

- (void)getRequestUserProfileResult:(STUserProfile *)result
{
	[Common endDejalActivity];

	profile = result;
	
	if (profile == nil)
	{
		[Common showAlert:@"Service failure"];
		BACK_VIEW(self);
	}

	if (profile != NULL && profile.ErrCode == ERR_INVALID_USER)
	{
		[Common showAlert:@"This user is not valid"];
		return;
	}

	[txtEmail setText:profile.Email];
	[txtPhone setText:profile.PhoneNum];
	[txtYear setText:[NSString stringWithFormat:@"%d", profile.BirthYear]];
	[lblName setText:profile.UserName];

	[imgView setImage:[Common string2Image:profile.ImageData]];

	[ratingView setRating:(float)profile.StarCount];
}

@end
