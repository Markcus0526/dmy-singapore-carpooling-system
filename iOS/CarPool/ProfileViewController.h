//
//  ProfileViewController.h
//  CarPool
//
//  Created by KimHakMin on 10/6/13.
//  Copyright (c) 2013 RiKS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SuperViewController.h"
#import "STDataInfo.h"
#import "ASStarRatingView.h"
#import "Utils/CommManager.h"

@interface ProfileViewController : SuperViewController<UITextFieldDelegate, UIScrollViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIAlertViewDelegate, UITextViewDelegate, UserManageDelegate>
{
	IBOutlet UITextField *txtEmail;
	IBOutlet UITextField *txtPhone;
	IBOutlet UITextField *txtYear;
	IBOutlet UILabel	*lblName;

	IBOutlet UIButton *btnEdit;
	IBOutlet UIButton *btnLogOut;
	IBOutlet UIButton *btnSelectPhoto;

	IBOutlet UIImageView *imgStar1;
	IBOutlet UIImageView *imgStar2;
	IBOutlet UIImageView *imgStar3;
	IBOutlet UIImageView *imgStar4;
	IBOutlet UIImageView *imgStar5;

	IBOutlet UIImageView *imgView;
	IBOutlet UIScrollView *scrollview;

	IBOutlet UIImagePickerController *pickerController;

	STUserProfile *profile;

	IBOutlet ASStarRatingView *ratingView;

	BOOL keyboardVisible;
	BOOL imageChanged;
	BOOL gotProfile;
}

@property (nonatomic, retain) IBOutlet UITextField				*txtEmail;
@property (nonatomic, retain) IBOutlet UITextField				*txtPhone;
@property (nonatomic, retain) IBOutlet UITextField				*txtYear;
@property (nonatomic, retain) IBOutlet UIButton					*btnEdit;
@property (nonatomic, retain) IBOutlet UIButton					*btnLogOut;
@property (nonatomic, retain) IBOutlet UIButton					*btnSelectPhoto;
@property (nonatomic, retain) IBOutlet UIImageView				*imgStar1;
@property (nonatomic, retain) IBOutlet UIImageView				*imgStar2;
@property (nonatomic, retain) IBOutlet UIImageView				*imgStar3;
@property (nonatomic, retain) IBOutlet UIImageView				*imgStar4;
@property (nonatomic, retain) IBOutlet UIImageView				*imgStar5;
@property (nonatomic, retain) IBOutlet UIImagePickerController	*pickerController;
@property (nonatomic, retain) IBOutlet UIImageView				*imgView;
@property (nonatomic, retain) IBOutlet UIScrollView				*scrollview;
@property (nonatomic, retain) IBOutlet ASStarRatingView			*ratingView;

@property (nonatomic, retain) STUserProfile						*profile;
@property (nonatomic, retain) IBOutlet UILabel					*lblName;

@property (nonatomic, nonatomic) BOOL							imageChanged;
@property (nonatomic, nonatomic) BOOL							gotProfile;

//- (IBAction)onClickEdit:(id)sender;
//- (IBAction)onClickLogOut:(id)sender;
//- (IBAction)onClickSelectPhoto:(id)sender;
//
//- (IBAction)BeginEditing:(UITextField *)sender;
//- (IBAction)EndEditing:(UITextField *)sender;
//- (void)setViewMoveUp:(BOOL)moveUp height:(float)height;
//- (void)keyboardWillShow:(NSNotification *)notification;
//- (void)keyboardWillHide:(NSNotification *)notification;
//- (void)viewWillAppear:(BOOL)animated;
//- (void)viewWillDisappear:(BOOL)animated;
//- (IBAction)textFieldHideKeyboard:(id)sender;
//- (IBAction)btnBackgroundClicked:(id)sender;

@end

