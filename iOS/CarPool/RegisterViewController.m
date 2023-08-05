//
//  RegisterViewController.m
//  CarPool
//
//  Created by RiKS on 9/10/13.
//  Copyright (c) 2013 RiKS. All rights reserved.
//

#import "RegisterViewController.h"
#import "SignInViewController.h"
#import "Common.h"
#import "KeyboardHelper.h"
#import "STDataInfo.h"
#import "DejalActivityView.h"
#import "CommManager.h"
#import "LoginViewController.h"
#import "OnBoardViewController.h"
#import "TaxiStandMapViewController.h"

@implementation RegisterViewController

@synthesize scrollView;
@synthesize genderPicker;
@synthesize birthYearPicker;
@synthesize genderDetail;
@synthesize birthYearDetail;
@synthesize mGenderKinds;
@synthesize mBirthYear;
@synthesize genderSheet;
@synthesize birthYearSheet;
@synthesize genderField;
@synthesize birthYearField;
@synthesize nickName;
@synthesize email;
@synthesize phoneNumber;
@synthesize password;
@synthesize rePassword;
@synthesize imgPhoto;

CGRect keyboardBounds;
CGRect applicationFrame;
CGSize scrollViewOriginalSize;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if ([Common getPhoneType] == IPHONE5)
		nibNameOrNil = [nibNameOrNil stringByAppendingString:@"_ios5"];
	
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

	
	return self;
}

- (void)viewDidLoad
{
	scrollViewOriginalSize = scrollView.contentSize;
	applicationFrame = [[UIScreen mainScreen] applicationFrame];
	
	[super viewDidLoad];

	mGenderKinds = [Common getGenderKinds];
	mBirthYear = [Common getBirthYear];
	[birthYearField setText:(NSString*)[mBirthYear objectAtIndex:mBirthYear.count - 1]];

	nickName.delegate = self;
	email.delegate = self;
	phoneNumber.delegate = self;
	password.delegate = self;
	rePassword.delegate = self;

	keyboardVisible = false;
	curTextField = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
}

- (BOOL)shouldAutorotate {
	return NO;
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

- (IBAction)onRegisterButton:(id)sender
{
	if ([nickName text].length == 0) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ride2Gather" message:@"Please insert your nickname." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		alert.tag = 0;
		[alert show];
		return;
	}
	
	if ([email text].length == 0) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ride2Gather" message:@"Please insert your email address." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		alert.tag = 1;
		[alert show];
		return;
	}

	if (![Common isValidEmail:email.text])
	{
		[Common showAlert:@"Email format invalid."];
		return;
	}

	if ([phoneNumber text].length == 0) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ride2Gather" message:@"Please insert your phone number." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		alert.tag = 2;
		[alert show];
		return;
	}

	if (![Common isValidPhoneNum:phoneNumber.text])
	{
		[Common showAlert:@"Phone number format invalid."];
		return;
	}

	if ([password text].length == 0) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ride2Gather" message:@"Please insert your password." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		alert.tag = 3;
		[alert show];
		return;
	}

	if ([rePassword text].length == 0) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ride2Gather" message:@"Please insert your re-password." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		alert.tag = 4;
		[alert show];
		return;
	}

	if ([[password text] isEqualToString:[rePassword text]] == NO)
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ride2Gather" message:@"Your inserted password is invalid." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		alert.tag = 5;
		[alert show];
		return;
	}

	strNickName = [nickName text];
	nGender = [genderPicker selectedRowInComponent:0];
	nBirtyYear =  [[birthYearField text] intValue];
	strEmail = [email text];
	strPhoneNum = [phoneNumber text];
	strPassword = [password text];

	nickName.enabled = NO;
	email.enabled = NO;
	phoneNumber.enabled = NO;
	password.enabled = NO;
	rePassword.enabled = NO;

	if (![Common isReachable:YES])
		return;
	
	[Common startDejalActivity:self.view];
	
	if ([CommManager hasConnectivity] == NO)
	{
		[Common endDejalActivity];
		nickName.enabled = YES;
		email.enabled = YES;
		phoneNumber.enabled = YES;
		password.enabled = YES;
		rePassword.enabled = YES;
		
		return;
	}
		
	STUserReg *regInfo = [[STUserReg alloc] init];
	regInfo.UserName = strNickName;
	regInfo.PhoneNum = strPhoneNum;
	regInfo.Password = strPassword;
	regInfo.Gender = nGender;
	regInfo.BirthYear = nBirtyYear;
	regInfo.Email = strEmail;
	regInfo.IndGender = 0;
	regInfo.GrpGender = 0;
	regInfo.DelayTime = 10;
	regInfo.ImageData = [Common image2String:imgPhoto.image];

	CommManager* commMgr = [CommManager getCommMgr];
	[commMgr userManage].delegate = self;
    [[commMgr userManage] getRequestRegister:regInfo];
}

- (void)getRequestRegisterResult:(StringContainer *)result
{
	[Common endDejalActivity];

	if (result == nil)
	{
		nickName.enabled = YES;
		email.enabled = YES;
		phoneNumber.enabled = YES;
		password.enabled = YES;
		rePassword.enabled = YES;
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ride2Gather" message:@"Service Failure" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		alert.tag = 6;
		[alert show];

		return;
	}

	if (result.Result < 0)
	{
		nickName.enabled = YES;
		email.enabled = YES;
		phoneNumber.enabled = YES;
		password.enabled = YES;
		rePassword.enabled = YES;

		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ride2Gather" message:result.Value delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		alert.tag = 7;
		[alert show];

		return;
	}

	nickName.enabled = YES;
	email.enabled = YES;
	phoneNumber.enabled = YES;
	password.enabled = YES;
	rePassword.enabled = YES;

	[Common startDejalActivity:self.view];

	STAuthUser* user = [[STAuthUser alloc] init];
	user.Email = email.text;
	user.Password = password.text;

	CommManager* commMgr = [CommManager getCommMgr];
	UserManage* userMgr = [commMgr userManage];
	userMgr.delegate = self;
	[userMgr getRequestLogin:user];
}

- (void)getRequestLoginResult:(STLoginResult *)result
{
	[Common endDejalActivity];

	if (result == nil)
	{
		nickName.enabled = YES;
		email.enabled = YES;
		phoneNumber.enabled = YES;
		password.enabled = YES;
		rePassword.enabled = YES;
		
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ride2Gather" message:@"Service Failure" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		alert.tag = 6;
		[alert show];
		
		return;
	}

	if (result.ResultCode <= 0)
	{
		nickName.enabled = YES;
		email.enabled = YES;
		phoneNumber.enabled = YES;
		password.enabled = YES;
		rePassword.enabled = YES;

		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ride2Gather" message:result.Message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		alert.tag = 7;
		[alert show];

		return;
	}

	[Common saveUserInfo:email.text password:password.text];
	[Common saveLoginType:LOGIN_NORMAL];
	[Common writePasswordToFile:password.text];
	[Common writeUserEmailToFile:email.text];
	[Common writeUserNameToFile:nickName.text];
	[Common writeUserIDToFile:result.ResultCode];

	OnBoardViewController* controller = [[OnBoardViewController alloc] initWithNibName:@"OnBoardViewController" bundle:nil];
	SHOW_VIEW(controller);

}

- (IBAction)onGenderDetail:(id)sender
{
	[self createGenderSheet];
	genderPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0.0, 45.0, 0.0, 0.0)];
	genderPicker.dataSource = self;
	genderPicker.delegate = self;
	genderPicker.showsSelectionIndicator = YES;
	[genderSheet addSubview:genderPicker];
	
	if ([genderField text].length > 0) {
		NSString *gender = [genderField text];
		
		for (int i = 0; i < mGenderKinds.count; i++) {
			NSString *strData = [mGenderKinds objectAtIndex:i];
			if ( [gender isEqualToString:strData] == YES) {
				[genderPicker selectRow:i inComponent:0 animated :YES];
				break;
			}
		}
	}
	
}

- (IBAction)onBirthYearDetail:(id)sender
{
	[self createBirthYearSheet];
	birthYearPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0.0, 45.0, 0.0, 0.0)];
	birthYearPicker.dataSource = self;
	birthYearPicker.delegate = self;
	birthYearPicker.showsSelectionIndicator = YES;
	[birthYearSheet addSubview:birthYearPicker];

	if ([birthYearField text].length > 0) {
		NSString *birthYear = [birthYearField text];

//		[birthYearPicker selectRow:[mBirthYear count] - 1 inComponent:0 animated :YES];
		for (int i = 0; i < mBirthYear.count; i++) {
			NSString *strData = [mBirthYear objectAtIndex:i];

			if ([birthYear isEqualToString:strData] == YES) {
				[birthYearPicker selectRow:i inComponent:0 animated:NO];
				break;
			}
		}
	}
	
}

- (void)createGenderSheet
{
	if (genderSheet == nil) {
		// setup actionsheet to contain the UIPicker
		genderSheet = [[UIActionSheet alloc] initWithTitle:@"Select a Gender"
												  delegate:self
										 cancelButtonTitle:nil
									destructiveButtonTitle:nil
										 otherButtonTitles:nil];
		
		UISegmentedControl *closeButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"OK"]];
		closeButton.momentary = YES;
		closeButton.frame = CGRectMake(260, 7, 50, 30);
		closeButton.segmentedControlStyle = UISegmentedControlStyleBar;
		closeButton.tintColor = [UIColor blueColor];
		[closeButton addTarget:self action:@selector(onGenderSelected:) forControlEvents:UIControlEventValueChanged];
		
		UISegmentedControl *cancelButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"Cancel"]];
		cancelButton.momentary = YES;
		cancelButton.frame = CGRectMake(10, 7, 50, 30);
		cancelButton.segmentedControlStyle = UISegmentedControlStyleBar;
		cancelButton.tintColor = [UIColor lightGrayColor];
		[cancelButton addTarget:self action:@selector(onGenderCanceled:) forControlEvents:UIControlEventValueChanged];

		[genderSheet addSubview:closeButton];
		[genderSheet addSubview:cancelButton];
		[genderSheet showInView:self.view];
		[genderSheet setBounds:CGRectMake(0,0,320, 464)];
		
	}
}

- (void)createBirthYearSheet
{
	if (birthYearSheet == nil) {
		// setup actionsheet to contain the UIPicker
		birthYearSheet = [[UIActionSheet alloc] initWithTitle:@"Select a year of birthday"
												  delegate:self
										 cancelButtonTitle:nil
									destructiveButtonTitle:nil
										 otherButtonTitles:nil];

		UISegmentedControl *closeButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"OK"]];
		closeButton.momentary = YES;
		closeButton.frame = CGRectMake(260, 7, 50, 30);
		closeButton.segmentedControlStyle = UISegmentedControlStyleBar;
		closeButton.tintColor = [UIColor blueColor];
		[closeButton addTarget:self action:@selector(onBirthYearSelected:) forControlEvents:UIControlEventValueChanged];

		UISegmentedControl *cancelButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"Cancel"]];
		cancelButton.momentary = YES;
		cancelButton.frame = CGRectMake(10, 7, 50, 30);
		cancelButton.segmentedControlStyle = UISegmentedControlStyleBar;
		cancelButton.tintColor = [UIColor lightGrayColor];
		[cancelButton addTarget:self action:@selector(onBirthYearCanceled:) forControlEvents:UIControlEventValueChanged];

		[birthYearSheet addSubview:closeButton];
		[birthYearSheet addSubview:cancelButton];
		[birthYearSheet showInView:self.view];
		[birthYearSheet setBounds:CGRectMake(0,0,320, 464)];
	}
}

- (IBAction)onGenderSelected:(id)sender
{
	NSMutableString *gender = [NSMutableString string];
	
	int idx = [genderPicker selectedRowInComponent:0];
	[gender appendFormat:@"%@", [mGenderKinds objectAtIndex:idx]];
	[genderSheet dismissWithClickedButtonIndex:0 animated:YES];
	genderSheet = nil;
	
	[genderField setText:gender];
}

- (IBAction)onGenderCanceled:(id)sender
{
	[genderSheet dismissWithClickedButtonIndex:0 animated:YES];
	genderSheet = nil;
}

- (IBAction)onBirthYearSelected:(id)sender
{
	NSMutableString *birthYear = [NSMutableString string];

	int idx = [birthYearPicker selectedRowInComponent:0];
	[birthYear appendFormat:@"%@", [mBirthYear objectAtIndex:idx]];
	[birthYearSheet dismissWithClickedButtonIndex:0 animated:YES];
	birthYearSheet = nil;

	[birthYearField setText:birthYear];
}

- (IBAction)onBirthYearCanceled:(id)sender
{
	[birthYearSheet dismissWithClickedButtonIndex:0 animated:YES];
	birthYearSheet = nil;
}

#pragma mark PickerView DataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	if ([pickerView isEqual:genderPicker])
		return mGenderKinds.count;
	else if ([pickerView isEqual:birthYearPicker])
		return mBirthYear.count;

	return 0;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
	UILabel* label = (UILabel*)view;
	if (view == nil)
	{
		label= [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
		[label setTextAlignment:NSTextAlignmentCenter];
		label.opaque= YES;
		label.backgroundColor=[UIColor clearColor];
		label.textColor = [UIColor blackColor];
		UIFont *font = [UIFont boldSystemFontOfSize:20];
		label.font = font;
	}

	if ([pickerView isEqual:genderPicker])
	{
		[label setText:[mGenderKinds objectAtIndex:row]];
	}
	else if ([pickerView isEqual:birthYearPicker])
	{
		[label setText:[mBirthYear objectAtIndex:row]];
	}

	return label;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row
	  inComponent:(NSInteger)component
{
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (alertView.tag == 7)
	{
		if (buttonIndex == 0)
		{
//			SignInViewController *controller = [[SignInViewController alloc] initWithNibName:@"SignInViewController" bundle:nil];
//			SHOW_VIEW(controller);
		}
	}
}

- (IBAction)btnSelectPhoto:(id)sender
{
	UIImagePickerController *controller = [[UIImagePickerController alloc] init];
	controller.delegate = self;
	[controller setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
	SHOW_VIEW(controller);
//	[self presentViewController:controller animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	UIImage *orgImage = [info objectForKey:UIImagePickerControllerOriginalImage];
	
	NSData *data = UIImageJPEGRepresentation(orgImage, 1.0f);
	UIImage *imgNew = [UIImage imageWithData:data];
	[imgPhoto setImage:imgNew];

//	[picker dismissViewControllerAnimated:YES completion:nil];
	BACK_VIEW(picker);
}

- (IBAction)onClickBack:(id)sender
{
	LoginViewController *controller = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
	SHOW_VIEW(controller);
}


@end
