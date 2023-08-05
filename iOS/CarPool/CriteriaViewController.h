//
//  CriteriaViewController.h
//  CarPool
//
//  Created by KimHakMin on 10/6/13.
//  Copyright (c) 2013 RiKS. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SuperViewController.h"
#import "STDataInfo.h"

@interface CriteriaViewController : SuperViewController<UIPickerViewDataSource, UIPickerViewDelegate, UIActionSheetDelegate>
{
	IBOutlet UILabel *lblCount;
	IBOutlet UILabel *lblIndGender;
	IBOutlet UILabel *lblGrpGender;
	IBOutlet UILabel *lblDelayTime;

	IBOutlet UIButton *btnSelGrpGender;

	UIPickerView *pickerCount;
	UIPickerView *pickerIndGender;
	UIPickerView *pickerGrpGender;
	UIPickerView *pickerDelayTime;

	UIActionSheet *asPeopleCount;
	UIActionSheet *asIndGender;
	UIActionSheet *asGrpGender;
	UIActionSheet *asDelayTime;

	NSMutableArray *arrPeopleCount;
	NSMutableArray *arrGender;
	NSMutableArray *arrGrpGender;
	NSMutableArray *arrDelayTime;

	STUserProfile *userProfile;
}

@property (nonatomic, retain) IBOutlet UILabel *lblCount;
@property (nonatomic, retain) IBOutlet UILabel *lblIndGender;
@property (nonatomic, retain) IBOutlet UILabel *lblGrpGender;
@property (nonatomic, retain) IBOutlet UILabel *lblDelayTime;

@property (nonatomic, retain) IBOutlet UIButton *btnSelGrpGender;

@property (nonatomic, retain) UIPickerView *pickerCount;
@property (nonatomic, retain) UIPickerView *pickerIndGender;
@property (nonatomic, retain) UIPickerView *pickerGrpGender;
@property (nonatomic, retain) UIPickerView *pickerDelayTime;

@property (nonatomic, retain) UIActionSheet *asPeopleCount;
@property (nonatomic, retain) UIActionSheet *asIndGender;
@property (nonatomic, retain) UIActionSheet *asGrpGender;
@property (nonatomic, retain) UIActionSheet *asDelayTime;

@property (nonatomic, retain) STUserProfile *userProfile;

- (IBAction) onClickPeopleCount : (id)sender;
- (IBAction) onClickIndGender : (id)sender;
- (IBAction) onClickGrpGender : (id)sender;
- (IBAction) onClickDelayTime : (id)sender;
- (IBAction) onClickOK : (id)sender;

//- (void)selectedGender:(id)sender;
//- (void)cancelledGender:(id)sender;

@end
