//
//  MyInfoViewController.h
//  CarPool
//
//  Created by RiKS on 10/4/13.
//  Copyright (c) 2013 RiKS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SuperViewController.h"

@interface MyInfoViewController:SuperViewController<UIPickerViewDelegate, UIPickerViewDataSource, UIAlertViewDelegate, UIActionSheetDelegate>
{
	IBOutlet UIPickerView *pickerPax;
	IBOutlet UIPickerView *pickerGrpGender;

	IBOutlet UITextView *txtOtherFeature;
	IBOutlet UITextField *txtColorOfTop;

	IBOutlet UIButton *btnPaxDetail;
	IBOutlet UIButton *btnGrpGenderDetail;

	IBOutlet UITextField *txtPax;
	IBOutlet UITextField *txtGrpGender;

	IBOutlet UIActionSheet* sheetPax;
	IBOutlet UIActionSheet* sheetGrpGender;

	IBOutlet UITextField *txtDest;

	IBOutlet UIButton *btnCheckIn;
	IBOutlet UIButton *btnDest;

	UIActionSheet*			sheetColor;
	UIPickerView*			pickerColor;


	NSArray *mPax;
	NSArray *mGrpGender;

	double fSrcLat;
	double fSrcLon;
	double fDstLat;
	double fDstLon;
	NSString *dest;

	BOOL keyboardVisible;
}

@property(nonatomic, retain) IBOutlet UIPickerView *pickerPax;
@property(nonatomic, retain) IBOutlet UIPickerView *pickerGrpGender;
@property(nonatomic, retain) IBOutlet UITextView *txtOtherFeature;
@property(nonatomic, retain) IBOutlet UITextField *txtColorOfTop;
@property(nonatomic, retain) IBOutlet UIButton *btnPaxDetail;
@property(nonatomic, retain) IBOutlet UIButton *btnGrpGenderDetail;
@property(nonatomic, retain) IBOutlet UITextField *txtPax;
@property(nonatomic, retain) IBOutlet UITextField *txtGrpGender;
@property(nonatomic, retain) IBOutlet UIActionSheet *sheetPax;
@property(nonatomic, retain) IBOutlet UIActionSheet *sheetGrpGender;
@property(nonatomic, retain) IBOutlet UIButton *btnCheckIn;
@property(nonatomic, retain) IBOutlet UIButton *btnDest;
@property(nonatomic, retain) IBOutlet UITextField *txtDest;

@property(nonatomic, retain) UIActionSheet*		sheetColor;
@property(nonatomic, retain) UIPickerView*		pickerColor;

@property(nonatomic, assign) double fSrcLat;
@property(nonatomic, assign) double fSrcLon;
@property(nonatomic, assign) double fDstLat;
@property(nonatomic, assign) double fDstLon;

@property(nonatomic, retain) NSString *dest;

- (IBAction)onPaxDetail:(id)sender;
- (IBAction)onGrpGenderDetail:(id)sender;
- (IBAction)onColorDetail:(id)sender;

//- (IBAction)BeginEditing:(UITextField *)sender;
//- (IBAction)EndEditing:(UITextField *)sender;
//
//- (void)textViewDidBeginEditing:(UITextView *)textView;
//- (void)textViewDidEndEditing:(UITextView *)textView;
//- (void)setViewMoveUp:(BOOL)moveUp height:(float)height;
//- (void)keyboardWillShow:(NSNotification *)notification;
//- (void)keyboardWillHide:(NSNotification *)notification;
//- (void)viewWillAppear:(BOOL)animated;
//- (void)viewWillDisappear:(BOOL)animated;
//
//- (IBAction)textFieldHideKeyboard:(id)sender;
- (IBAction)btnBackgroundClicked:(id)sender;
- (IBAction)btnCheckInClicked:(id)sender;

- (IBAction)onDestClicked:(id)sender;
- (IBAction)onClickBack:(id)sender;

@end
