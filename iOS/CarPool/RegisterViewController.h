//
//  RegisterViewController.h
//  CarPool
//
//  Created by RiKS on 9/10/13.
//  Copyright (c) 2013 RiKS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Utils/CommManager.h"

@interface RegisterViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource, UIAlertViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate, UserManageDelegate, UIActionSheetDelegate>
{
	IBOutlet UIScrollView *scrollView;
	IBOutlet UIPickerView *genderPicker;
	IBOutlet UIPickerView *birthYearPicker;
	IBOutlet UIButton *genderDetail;
	IBOutlet UIButton *birthYearDetail;
//	IBOutlet UIButton *btnRegister;
	IBOutlet UIActionSheet *genderSheet;
	IBOutlet UIActionSheet *birthYearSheet;
	IBOutlet UITextField *genderField;
	IBOutlet UITextField *birthYearField;
	IBOutlet UITextField *nickName;
	IBOutlet UITextField *email;
	IBOutlet UITextField *phoneNumber;
	IBOutlet UITextField *password;
	IBOutlet UITextField *rePassword;
	IBOutlet UIImageView *imgPhoto;

	NSArray *mGenderKinds;
	NSMutableArray *mBirthYear;
	BOOL keyboardVisible;

	NSString *strNickName;
	NSInteger nGender;
	NSInteger nBirtyYear;
	NSString *strPhoneNum;
	NSString *strEmail;
	NSString *strPassword;
	NSString *strRePassword;
}

@property(nonatomic, retain) IBOutlet UIScrollView *scrollView;
@property(nonatomic, retain) IBOutlet UIPickerView *genderPicker;
@property(nonatomic, retain) IBOutlet UIPickerView *birthYearPicker;
@property(nonatomic, retain) IBOutlet UIButton *genderDetail;
@property(nonatomic, retain) IBOutlet UIButton *birthYearDetail;
//@property(nonatomic, retain) IBOutlet UIButton *btnRegister;
@property(nonatomic, retain) IBOutlet UIActionSheet *genderSheet;
@property(nonatomic, retain) IBOutlet UIActionSheet *birthYearSheet;
@property(nonatomic, retain) IBOutlet UITextField *genderField;
@property(nonatomic, retain) IBOutlet UITextField *birthYearField;
@property(nonatomic, retain) IBOutlet UITextField *nickName;
@property(nonatomic, retain) IBOutlet UITextField *email;
@property(nonatomic, retain) IBOutlet UITextField *phoneNumber;
@property(nonatomic, retain) IBOutlet UITextField *password;
@property(nonatomic, retain) IBOutlet UITextField *rePassword;
@property(nonatomic, retain) IBOutlet UIImageView *imgPhoto;

@property(nonatomic, readwrite) NSArray *mGenderKinds;
@property(nonatomic, readwrite) NSMutableArray *mBirthYear;

-(IBAction)onGenderDetail:(id)sender;
-(IBAction)onBirthYearDetail:(id)sender;
//-(IBAction)textNickName:(id)sender;
//-(IBAction)textEmail:(id)sender;
//-(IBAction)textPhoneNumber:(id)sender;
//-(IBAction)textPassword:(id)sender;
//-(IBAction)textRePassword:(id)sender;
-(IBAction)onRegisterButton:(id)sender;

//- (IBAction)BeginEditing:(UITextField *)sender;
//- (IBAction)EndEditing:(UITextField *)sender;
//- (void)setViewMoveUp:(BOOL)moveUp height:(float)height;
//- (void)keyboardWillShow:(NSNotification *)notification;
//- (void)keyboardWillHide:(NSNotification *)notification;
//- (void)viewWillAppear:(BOOL)animated;
//- (void)viewWillDisappear:(BOOL)animated;
//- (IBAction)textFieldHideKeyboard:(id)sender;

- (IBAction)btnBackgroundClicked:(id)sender;
- (IBAction)btnSelectPhoto:(id)sender;
- (IBAction)onClickBack:(id)sender;

//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

@end
