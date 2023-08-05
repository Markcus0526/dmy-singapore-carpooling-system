//
//  FriendViewController.m
//  CarPool
//
//  Created by KimHakMin on 10/6/13.
//  Copyright (c) 2013 RiKS. All rights reserved.
//

#import "FriendViewController.h"
#import "KeyboardHelper.h"
#import "Common.h"
#import "DejalActivityView.h"
#import "CommManager.h"

@interface FriendViewController ()

@end

@implementation FriendViewController

@synthesize txtPhoneNum;
@synthesize btnPhoneNum;
@synthesize txtView;
@synthesize scrollView;

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

	[Common showAlert:@"Statndard mobile carrier SMS rates may apply."];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)sendLogMsg:(NSString*)phoneNum
{
	UserManage *userManage = [[CommManager getCommMgr] userManage];
	STSendSMS *sendSms = [[STSendSMS alloc] init];
	sendSms.Uid = [Common readUserIdFromFile];
	sendSms.PhoneNum = phoneNum;
	[userManage getRequestSendSMS:sendSms];
	[self performSelectorOnMainThread:@selector(sendFinished) withObject:nil waitUntilDone:NO];
}

- (void)sendFinished
{
	[Common endDejalActivity];
}

- (IBAction)onClickSend:(id)sender
{
	NSString *szData = @"";
	szData = [NSString stringWithString:txtPhoneNum.text];
	if (szData.length == 0)
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ride2Gather" message:@"Please select phone number to send SMS." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		return;
	}

	szData = [NSString stringWithString:txtView.text];
	if (szData.length == 0)
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ride2Gather" message:@"Please insert message content." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		return;
	}

	message = [[MFMessageComposeViewController alloc] init];
	if ([MFMessageComposeViewController canSendText])
	{
		message.body = [NSString stringWithString:txtView.text];
		message.recipients = [NSArray arrayWithObjects:[NSString stringWithString:txtPhoneNum.text], nil];
		message.messageComposeDelegate = self;
		SHOW_VIEW(message);
	}

}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
//	[controller dismissViewControllerAnimated:YES completion:nil];
	BACK_VIEW(self);

	NSString *szResult = @"";
	if (result == MessageComposeResultSent)
	{
		szResult = @"SMS send success";

		if (![Common isReachable:YES])
			return;

		[Common startDejalActivity:self.view];
		[NSThread detachNewThreadSelector:@selector(sendLogMsg:) toTarget:self withObject:[message.recipients objectAtIndex:0]];
	}
	else if(result == MessageComposeResultFailed)
	{
		szResult = @"SMS send fail";
	}

	if (result != MessageComposeResultCancelled)
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ride2Gather" message:szResult delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
	}
}

- (IBAction)onClickPhoneNum:(id)sender
{
	people_Picker = [[ABPeoplePickerNavigationController alloc] init];
	people_Picker.peoplePickerDelegate = self;
	NSArray *displayedItems = [NSArray arrayWithObjects:[NSNumber numberWithInt:kABPersonPhoneProperty],
							  [NSNumber numberWithInt:kABPersonEmailProperty],
							  [NSNumber numberWithInt:kABPersonBirthdayProperty], nil];
	people_Picker.displayedProperties = displayedItems;
	SHOW_VIEW(people_Picker);

	return;
}

- (BOOL) peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
//	[peoplePicker dismissViewControllerAnimated:YES completion:nil];
	BACK_VIEW(self);
	ABMultiValueRef value = (ABMultiValueRef)ABRecordCopyValue(person, kABPersonPhoneProperty);
	
	if (ABMultiValueGetCount(value) > 0)
	{
		CFStringRef phoneNumRef = (CFStringRef)ABMultiValueCopyValueAtIndex(value, 0);
		NSString *szPhoneNum = @"";
		if (phoneNumRef != nil)
		{
			szPhoneNum = [NSString stringWithString:(__bridge NSString *)phoneNumRef];
			szPhoneNum = [szPhoneNum stringByReplacingOccurrencesOfString:@"-" withString:@""];
			[txtPhoneNum setText:szPhoneNum];
		}
	}

	return true;
}

- (void) peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
//	[peoplePicker dismissViewControllerAnimated:YES completion:nil];
	BACK_VIEW(people_Picker);
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
	return YES;
}

///////////////////////////////////////////////////////////////////
#pragma mark - Scroll When Keyboard Focus
- (IBAction)BeginEditing:(UITextField *)sender
{
	curTextField = sender;
	if (keyboardVisible)
		[KeyboardHelper moveScrollView:curTextField scrollView:scrollView];
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
	
	[KeyboardHelper moveScrollView:curTextField scrollView:scrollView];
	
	keyboardVisible = true;
}

- (void)keyboardWillHide:(NSNotification *)notification
{
	//---gets the size of the keyboard---
	NSDictionary *userInfo = [notification userInfo];
	NSValue *keyboardValue = [userInfo objectForKey:UIKeyboardBoundsUserInfoKey];
	[keyboardValue getValue:&keyboardBounds];
	
	[KeyboardHelper moveScrollView:nil scrollView:scrollView];
	
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
	[txtView resignFirstResponder];
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
	return YES;
}

@end
