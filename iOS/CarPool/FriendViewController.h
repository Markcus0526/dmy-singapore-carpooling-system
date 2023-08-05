//
//  FriendViewController.h
//  CarPool
//
//  Created by KimHakMin on 10/6/13.
//  Copyright (c) 2013 RiKS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <AddressBookUI/AddressBookUI.h>
#import "SuperViewController.h"
#import <MessageUI/MessageUI.h>
#import "Utils/CommManager.h"

@interface FriendViewController : SuperViewController <UIScrollViewDelegate,ABPeoplePickerNavigationControllerDelegate, MFMessageComposeViewControllerDelegate, UINavigationBarDelegate, UITextViewDelegate, UserManageDelegate>
{
	IBOutlet UITextField *txtPhoneNum;
	IBOutlet UITextView *txtView;
	IBOutlet UIButton *btnPhoneNum;
	IBOutlet UIScrollView *scrollView;

	ABPeoplePickerNavigationController *people_Picker;
	MFMessageComposeViewController *message;

	BOOL keyboardVisible;
}

@property (nonatomic, retain) IBOutlet UITextField *txtPhoneNum;
@property (nonatomic, retain) IBOutlet UITextView *txtView;
@property (nonatomic, retain) IBOutlet UIButton *btnPhoneNum;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;

-(IBAction) onClickSend:(id)sender;
-(IBAction)onClickPhoneNum:(id)sender;

- (IBAction)BeginEditing:(UITextField *)sender;
- (IBAction)EndEditing:(UITextField *)sender;
- (void)setViewMoveUp:(BOOL)moveUp height:(float)height;
- (void)keyboardWillShow:(NSNotification *)notification;
- (void)keyboardWillHide:(NSNotification *)notification;
- (void)viewWillAppear:(BOOL)animated;
- (void)viewWillDisappear:(BOOL)animated;
- (IBAction)textFieldHideKeyboard:(id)sender;
- (IBAction)btnBackgroundClicked:(id)sender;

@end
