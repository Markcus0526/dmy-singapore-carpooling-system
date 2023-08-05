//
//  UserProfileViewController.m
//  CarPool
//
//  Created by RiKS on 9/12/13.
//  Copyright (c) 2013 RiKS. All rights reserved.
//

#import "UserProfileViewController.h"
#import "CarPoolAppDelegate.h"
#import "Common.h"
#import "CommManager.h"
#import <CoreLocation/CoreLocation.h>
#import "STDataInfo.h"
#import "ImportantNoticeViewController.h"
#import "TaxiStandMapViewController.h"
#import "DejalActivityView.h"

@interface UserProfileViewController()

@end

@implementation UserProfileViewController

@synthesize imgPhoto;
@synthesize labelGender;
@synthesize labelBirthYear;
@synthesize labelEmail;
@synthesize labelPhoneNum;
@synthesize btnNext;
@synthesize loggedInUser = _loggedIUnUser;
@synthesize asGender;
@synthesize genderPicker;
@synthesize ll_accessToken;
@synthesize ll_gender;

@synthesize userProfile;

@synthesize ll_client;
@synthesize ll_year;
@synthesize ll_month;
@synthesize ll_day;
@synthesize ll_email;
@synthesize ll_name;
@synthesize ll_phone;
@synthesize ll_photo_url;

@synthesize editable;
@synthesize btnGender;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if ([Common getPhoneType] == IPHONE5)
		nibNameOrNil = [nibNameOrNil stringByAppendingString:@"_ios5"];
	
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

	if (self)
	{
		userProfile = PROFILE_FACEBOOK;
		asGender = nil;
		genderPicker = nil;
		editable = YES;
	}

	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view from its nib.
	if (userProfile == PROFILE_FACEBOOK)
	{
		if ([ll_gender isEqualToString:@"female"])
			[labelGender setText:@"Female"];
		else
			[labelGender setText:@"Male"];
		[labelPhoneNum setText:ll_phone];

		if (ll_year == 0)
			[labelBirthYear setText:@""];
		else
			[labelBirthYear setText:[NSString stringWithFormat:@"%d", ll_year]];
		[labelEmail setText:ll_email];

		NSString *photo_url = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=small", ll_client];
		NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:photo_url]];
		UIImage *photo = [UIImage imageWithData:data];
		[imgPhoto setImage:photo];
	}
	else if (userProfile == PROFILE_LINKEDIN)
	{
		[labelGender setText:ll_gender];
		[labelPhoneNum setText:ll_phone];

		if (ll_year == 0)
			[labelBirthYear setText:@""];
		else
			[labelBirthYear setText:[NSString stringWithFormat:@"%d", ll_year]];
		[labelEmail setText:ll_email];

		NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:ll_photo_url]];
		if (imgData != nil)
		{
			UIImage *photo = [UIImage imageWithData:imgData];
			[imgPhoto setImage:photo];
		}
	}

	CGRect rcPicker = CGRectMake(0, 45, 0, 0);
	genderPicker = [[UIPickerView alloc] initWithFrame:rcPicker];
	genderPicker.delegate = self;
	genderPicker.dataSource = self;
	genderPicker.showsSelectionIndicator = YES;

	labelBirthYear.enabled = editable;
	labelPhoneNum.enabled = editable;
	btnGender.enabled = editable;
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

-(IBAction)onNext:(id)sender
{
	if (![Common isValidBirthYear:labelBirthYear.text])
	{
		[Common showAlert:@"Birth year not valid"];
		return;
	}

	if ([labelPhoneNum.text isEqualToString:@""])
	{
		[Common showAlert:@"Input phone number"];
		return;
	}

	STFLAuthInfo *authInfo = [[STFLAuthInfo alloc] init];
	authInfo.Name = ll_name;
	authInfo.Email = self.labelEmail.text;
	authInfo.Gender = [self.labelGender.text isEqualToString:@"Male"] ? 1 : 0;
	authInfo.BirthYear = [self.labelBirthYear.text intValue];
	authInfo.PhoneNum = self.labelPhoneNum.text;
	authInfo.ImageData = [Common image2String:self.imgPhoto.image];

	if (![Common isReachable:YES])
		return;

	[Common startDejalActivity:self.view];
	
	CommManager* commMgr = [CommManager getCommMgr];
	[commMgr userManage].delegate = self;
	[[commMgr userManage] getRequestFLLogin:authInfo];
}

- (void)getRequestFLLoginResult:(STLoginResult *)szRes
{
	[Common endDejalActivity];

	if (szRes == nil)
	{
		[Common showAlert:@"Service failure."];
		NSLog(@"Service error : %@", szRes.Message);
		return;
	}

	if (szRes.ResultCode > 0)
	{
		if (userProfile == PROFILE_LINKEDIN)
			[Common saveLoginType:LOGIN_LINKEDIN];
		else
			[Common saveLoginType:LOGIN_FACEBOOK];

		NSString *szYear = labelBirthYear.text;
		NSString *szMonth = [NSString stringWithFormat:@"%d", ll_month];
		NSString *szDay = [NSString stringWithFormat:@"%d", ll_day];
		NSString *gender = labelGender.text;

		[Common writeUserEmailToFile:labelEmail.text];
		[Common writeUserIDToFile:szRes.ResultCode];
		[Common writeUserNameToFile:szRes.Name];

		if (ll_photo_url == nil)
			ll_photo_url = @"";

		if (userProfile == PROFILE_LINKEDIN)
		{
			NSDictionary *resultDict = [NSDictionary dictionaryWithObjectsAndKeys : ll_email, KEY_EMAIL, labelPhoneNum.text, KEY_PHONE, ll_name, KEY_NAME, szYear, KEY_YEAR, szMonth, KEY_MONTH, szDay, KEY_DAY, ll_accessToken, KEY_TOKEN, ll_photo_url, KEY_PHOTO, gender, KEY_GENDER, nil];

			[resultDict writeToFile:[Common llFilePath] atomically:YES];
		}
		else
		{
			NSDictionary *resultDict = [NSDictionary dictionaryWithObjectsAndKeys : ll_email, KEY_EMAIL, ll_client, KEY_CLIENT, labelPhoneNum.text, KEY_PHONE, ll_name, KEY_NAME, szYear, KEY_YEAR, gender, KEY_GENDER, nil];

			[resultDict writeToFile:[Common llFilePath] atomically:YES];
		}

		if (szRes.firstLogin)
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
	else
	{
		[Common showAlert:@"Service failure."];
		NSLog(@"Service error : %@", szRes.Message);
	}
}

- (void)showAlert:(NSString *)message result:(id)result error:(NSError *)error
{	
	NSString *alertMsg;
	NSString *alertTitle;
	if (error)
	{
		alertTitle = @"Error";
		if (error.fberrorUserMessage && FBSession.activeSession.isOpen)
		{
			alertTitle = nil;
			
		}
		else
		{
			alertMsg = @"Operation failed due to a connection problem, retry later.";
		}
	}
	else
	{
		NSDictionary *resultDict = (NSDictionary *)result;
		alertMsg = [NSString stringWithFormat:@"Successfully posted '%@'.", message];
		NSString *postId = [resultDict valueForKey:@"id"];
		if (!postId)
		{
			postId = [resultDict valueForKey:@"postId"];
		}
		if (postId)
		{
			alertMsg = [NSString stringWithFormat:@"%@\nPost ID: %@", alertMsg, postId];
		}
		alertTitle = @"Success";
	}
	
	if (alertTitle)
	{
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:alertTitle
															message:alertMsg
														   delegate:nil
												  cancelButtonTitle:@"OK"
												  otherButtonTitles:nil];
		[alertView show];
	}
}


- (IBAction)onClickgender:(id)sender
{
	if (asGender == nil)
	{
		asGender = [[UIActionSheet alloc] initWithTitle:@"Select gender"
												  delegate:self
										 cancelButtonTitle:nil
									destructiveButtonTitle:nil
									  otherButtonTitles:nil];

	}

	UISegmentedControl *closeButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"OK"]];
	closeButton.momentary = YES;
	closeButton.frame = CGRectMake(260, 7, 50, 30);
	closeButton.segmentedControlStyle = UISegmentedControlStyleBar;
	closeButton.tintColor = [UIColor blueColor];
	[closeButton addTarget:self action:@selector(selectedGender:) forControlEvents:UIControlEventValueChanged];

	UISegmentedControl *cancelButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"Cancel"]];
	cancelButton.momentary = YES;
	cancelButton.frame = CGRectMake(10, 7, 50, 30);
	cancelButton.segmentedControlStyle = UISegmentedControlStyleBar;
	cancelButton.tintColor = [UIColor lightGrayColor];
	[cancelButton addTarget:self action:@selector(cancelledGender:) forControlEvents:UIControlEventValueChanged];

	[asGender addSubview:closeButton];
	[asGender addSubview:cancelButton];
	[asGender showInView:self.view];

	[asGender setBounds:CGRectMake(0, 0, 320, 480)];

	if ([labelGender.text isEqualToString:@"Male"])
		[genderPicker selectRow:0 inComponent:0 animated:NO];
	else
		[genderPicker selectRow:1 inComponent:0 animated:NO];

	[asGender addSubview:genderPicker];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	return 2;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
	return 40;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
	UILabel *lblItem = (UILabel*)view;
	if (lblItem == nil)
	{
		lblItem = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 40)];
		((UILabel *)lblItem).backgroundColor = [UIColor clearColor];
		lblItem.textColor = [UIColor blackColor];
		[lblItem setFont:[UIFont systemFontOfSize:17]];
		[lblItem setTextAlignment:NSTextAlignmentCenter];
	}

	if (row == 0)
		[lblItem setText:@"Male"];
	else
		[lblItem setText:@"Female"];

	return lblItem;
}

- (IBAction)onClickBack:(id)sender
{
	[labelBirthYear resignFirstResponder];
	[labelPhoneNum resignFirstResponder];
}

- (void)selectedGender:(id)sender
{
	int nRow = [genderPicker selectedRowInComponent:0];
	if (nRow == 0)
		[labelGender setText:@"Male"];
	else
		[labelGender setText:@"Female"];

	[asGender dismissWithClickedButtonIndex:0 animated:YES];
}

- (void)cancelledGender:(id)sender
{
	[asGender dismissWithClickedButtonIndex:0 animated:YES];
}


@end
