//
//  SignInViewController.h
//  CarPool
//
//  Created by RiKS on 9/10/13.
//  Copyright (c) 2013 RiKS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LIALinkedInApplication.h"
#import "LIALinkedInHttpClient.h"
#import "LIALinkedInAuthorizationViewController.h"
#import "Utils/CommManager.h"

@interface SignInViewController : UIViewController<UITextFieldDelegate, UserManageDelegate>
{
	IBOutlet UIButton *btnSignIn;
	IBOutlet UIButton *btnForgot;
	IBOutlet UITextField *txtEmail;
	IBOutlet UITextField *txtPassword;
	
	BOOL keyboardVisible;
	long userID;
}


@property(nonatomic, retain) IBOutlet UIButton *btnSignIn;
@property(nonatomic, retain) IBOutlet UIButton *btnForgot;
@property(nonatomic, retain) IBOutlet UITextField *txtEmail;
@property(nonatomic, retain) IBOutlet UITextField *txtPassword;

-(IBAction)onSignIn:(id)sender;
-(IBAction)onForgotPasswordClicked:(id)sender;
//-(IBAction)textEmail:(id)sender;
//-(IBAction)textPassword:(id)sender;
//- (IBAction)BeginEditing:(UITextField *)sender;
//- (IBAction)EndEditing:(UITextField *)sender;
//- (void)setViewMoveUp:(BOOL)moveUp height:(float)height;
//- (void)keyboardWillShow:(NSNotification *)notification;
//- (void)keyboardWillHide:(NSNotification *)notification;
//- (void)viewWillAppear:(BOOL)animated;
//- (void)viewWillDisappear:(BOOL)animated;
//- (IBAction)textFieldHideKeyboard:(id)sender;
- (IBAction)btnBackgroundClicked:(id)sender;
- (IBAction)onClickBack:(id)sender;

//- (BOOL)textFieldShouldReturn:(UITextField *)textField;

@end
