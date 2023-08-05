//
//  UserProfileViewController.h
//  CarPool
//
//  Created by RiKS on 9/12/13.
//  Copyright (c) 2013 RiKS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

#import "LIALinkedInAuthorizationViewController.h"
#import "LIALinkedInHttpClient.h"
#import "Utils/CommManager.h"

enum UserProfile
{
	PROFILE_FACEBOOK,
	PROFILE_LINKEDIN,
};

@interface UserProfileViewController : UIViewController<FBLoginViewDelegate, UIActionSheetDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UserManageDelegate>
{
	IBOutlet UIImageView *imgPhoto;
	IBOutlet UITextField *labelGender;
	IBOutlet UITextField *labelBirthYear;
	IBOutlet UITextField *labelEmail;
	IBOutlet UITextField *labelPhoneNum;
	IBOutlet UIButton *btnGender;
	IBOutlet UIButton *btnNext;
	id<FBGraphUser> loggedInUser;

	enum UserProfile	userProfile;

	UIActionSheet *asGender;
	UIPickerView *genderPicker;

	/***************************************************************/
	/********  Facebook and Linkedin information variables  ********/
	/***************************************************************/
	int ll_year, ll_month, ll_day;
	NSString *ll_client;
	NSString *ll_email;
	NSString *ll_name;
	NSString *ll_phone;
	NSString *ll_photo_url;
	NSString *ll_accessToken;
	NSString *ll_gender;
	/***************************************************************/
	/***************************************************************/
	/***************************************************************/

	BOOL editable;
}

@property(nonatomic, retain) IBOutlet UIImageView *imgPhoto;
@property(nonatomic, retain) IBOutlet UITextField *labelGender;
@property(nonatomic, retain) IBOutlet UITextField *labelBirthYear;
@property(nonatomic, retain) IBOutlet UITextField *labelEmail;
@property(nonatomic, retain) IBOutlet UITextField *labelPhoneNum;
@property(nonatomic, retain) IBOutlet UIButton *btnNext;
@property(strong, nonatomic) id<FBGraphUser> loggedInUser;

@property(nonatomic, nonatomic) enum UserProfile userProfile;

@property(nonatomic, retain) UIActionSheet *asGender;
@property(nonatomic, retain) UIPickerView *genderPicker;

/***************************************************************/
/***************  Linkedin information properties  *************/
/***************************************************************/
@property (nonatomic, nonatomic) int ll_year;
@property (nonatomic, nonatomic) int ll_month;
@property (nonatomic, nonatomic) int ll_day;

@property (nonatomic, retain) NSString *ll_client;
@property (nonatomic, retain) NSString *ll_email;
@property (nonatomic, retain) NSString *ll_name;
@property (nonatomic, retain) NSString *ll_phone;
@property (nonatomic, retain) NSString *ll_photo_url;
@property (nonatomic, retain) NSString *ll_accessToken;
@property (nonatomic, retain) NSString *ll_gender;
/***************************************************************/
/***************************************************************/
/***************************************************************/

@property (nonatomic, retain) UIButton *btnGender;

@property (nonatomic, nonatomic) BOOL editable;

- (IBAction)onNext:(id)sender;
- (IBAction)onClickgender:(id)sender;
- (IBAction)onClickBack:(id)sender;
- (void)showAlert:(NSString *)message result:(id)result error:(NSError *)error;

- (void)selectedGender:(id)sender;
- (void)cancelledGender:(id)sender;

@end
