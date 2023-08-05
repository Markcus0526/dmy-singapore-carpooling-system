//
//  CriteriaViewController.m
//  CarPool
//
//  Created by KimHakMin on 10/6/13.
//  Copyright (c) 2013 RiKS. All rights reserved.
//

#import "CriteriaViewController.h"
#import "Common.h"
#import "CommManager.h"
#import "DejalActivityView.h"
#import "TaxiStandMapViewController.h"

@interface CriteriaViewController ()

@end

@implementation CriteriaViewController

@synthesize lblCount;
@synthesize lblIndGender;
@synthesize lblGrpGender;
@synthesize lblDelayTime;
@synthesize btnSelGrpGender;

@synthesize pickerCount;
@synthesize pickerDelayTime;
@synthesize pickerGrpGender;
@synthesize pickerIndGender;

@synthesize asPeopleCount;
@synthesize asIndGender;
@synthesize asGrpGender;
@synthesize asDelayTime;

@synthesize userProfile;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if ([Common getPhoneType] == IPHONE5)
		nibNameOrNil = [nibNameOrNil stringByAppendingString:@"_ios5"];
	
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

		
	if (self) {
		// Custom initialization
		asPeopleCount = nil;
		asIndGender = nil;
		asGrpGender = nil;
		asDelayTime = nil;

		pickerIndGender = nil;
		pickerCount = nil;
		pickerDelayTime = nil;
		pickerGrpGender = nil;

		arrDelayTime = [[NSMutableArray alloc] initWithCapacity:0];
		[arrDelayTime addObject:@"3"];
		[arrDelayTime addObject:@"5"];
		[arrDelayTime addObject:@"10"];

		arrGender = [[NSMutableArray alloc] initWithCapacity:0];
		[arrGender addObject:@"Male"];
		[arrGender addObject:@"Female"];
		[arrGender addObject:@"Mixed"];

		arrGrpGender = [[NSMutableArray alloc] initWithCapacity:0];
		[arrGrpGender addObject:@"Male"];
		[arrGrpGender addObject:@"Female"];
		[arrGrpGender addObject:@"Mixed"];
		[arrGrpGender addObject:@"Male or Mixed"];
		[arrGrpGender addObject:@"Female or Mixed"];
		[arrGrpGender addObject:@"Any"];

		arrPeopleCount = [[NSMutableArray alloc] initWithCapacity:0];
		[arrPeopleCount addObject:@"Yes"];
		[arrPeopleCount addObject:@"No"];
	}

	return self;
}

-(id)init
{
	self = [super init];
	if (self) {
		// Custom initialization
		asPeopleCount = nil;
		asIndGender = nil;
		asGrpGender = nil;
		asDelayTime = nil;
		
		pickerIndGender = nil;
		pickerCount = nil;
		pickerDelayTime = nil;
		pickerGrpGender = nil;
		
		arrDelayTime = [[NSMutableArray alloc] initWithCapacity:0];
		[arrDelayTime addObject:@"3"];
		[arrDelayTime addObject:@"5"];
		[arrDelayTime addObject:@"10"];

		arrGender = [[NSMutableArray alloc] initWithCapacity:0];
		[arrGender addObject:@"Male"];
		[arrGender addObject:@"Female"];
		[arrGender addObject:@"Both"];

		arrGrpGender = [[NSMutableArray alloc] initWithCapacity:0];
		[arrGrpGender addObject:@"Male"];
		[arrGrpGender addObject:@"Female"];
		[arrGrpGender addObject:@"Mixed"];
		[arrGrpGender addObject:@"Male or Mixed"];
		[arrGrpGender addObject:@"Female or Mixed"];
		[arrGrpGender addObject:@"Any"];

		arrPeopleCount = [[NSMutableArray alloc] initWithCapacity:0];
		[arrPeopleCount addObject:@"Yes"];
		[arrPeopleCount addObject:@"No"];
	}
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view from its nib.

	pickerCount = [[UIPickerView alloc] initWithFrame:CGRectMake(0.0, 45.0, 0.0, 0.0)];
	pickerCount.dataSource = self;
	pickerCount.delegate = self;
	pickerCount.showsSelectionIndicator = YES;
	pickerCount.tag = 0;
	
	pickerIndGender = [[UIPickerView alloc] initWithFrame:CGRectMake(0.0, 45.0, 0.0, 0.0)];
	pickerIndGender.dataSource = self;
	pickerIndGender.delegate = self;
	pickerIndGender.showsSelectionIndicator = YES;
	pickerIndGender.tag = 1;

	pickerGrpGender = [[UIPickerView alloc] initWithFrame:CGRectMake(0.0, 45.0, 0.0, 0.0)];
	pickerGrpGender.dataSource = self;
	pickerGrpGender.delegate = self;
	pickerGrpGender.showsSelectionIndicator = YES;
	pickerGrpGender.tag = 2;
	
	pickerDelayTime = [[UIPickerView alloc] initWithFrame:CGRectMake(0.0, 45.0, 0.0, 0.0)];
	pickerDelayTime.dataSource = self;
	pickerDelayTime.delegate = self;
	pickerDelayTime.showsSelectionIndicator = YES;
	pickerDelayTime.tag = 3;

	if (![Common isReachable:YES])
		return;

	[Common startDejalActivity:self.view];

	CommManager* commMgr = [CommManager getCommMgr];
	[commMgr userManage].delegate = (id<UserManageDelegate>)self;
	[[commMgr userManage] getRequestUserProfile];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	int nCount = 0;
	switch (pickerView.tag)
	{
		case 0:					// People Count
			nCount = 2;
			break;
		case 1:					// Ind Gender
			nCount = 3;
			break;
		case 2:					// Grp Gender
			nCount = 6;
			break;
		case 3:					// Delay Time
			nCount = 3;
			break;
	}

	return nCount;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
	UILabel* label = (UILabel*)view;
	if (view == nil)
	{
		label= [[UILabel alloc] initWithFrame:CGRectMake(0, 0, pickerView.bounds.size.width, 44)];
		[label setTextAlignment:NSTextAlignmentCenter];
		label.opaque = YES;
		label.backgroundColor = [UIColor clearColor];
		label.textColor = [UIColor blackColor];
		UIFont *font = [UIFont boldSystemFontOfSize:20];
		label.font = font;
	}

	switch (pickerView.tag)
	{
		case 0:
			[label setText:[arrPeopleCount objectAtIndex:row]];
			break;
		case 1:
			[label setText:[arrGender objectAtIndex:row]];
			break;
		case 2:
			[label setText:[arrGrpGender objectAtIndex:row]];
			break;
		case 3:
		{
			NSString *szMinutes = [arrDelayTime objectAtIndex:row];
			szMinutes = [szMinutes stringByAppendingString:@" minutes"];
			[label setText:szMinutes];
			break;
		}
	}
	
	return label;
}

- (void)createPeoplePickerView
{
	if (asPeopleCount == nil)
	{
		asPeopleCount = [[UIActionSheet alloc] initWithTitle:@"a group of people(2~3 pax)"
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
	[closeButton addTarget:self action:@selector(peopleCountSelected:) forControlEvents:UIControlEventValueChanged];

	UISegmentedControl *cancelButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"Cancel"]];
	cancelButton.momentary = YES;
	cancelButton.frame = CGRectMake(10, 7, 50, 30);
	cancelButton.segmentedControlStyle = UISegmentedControlStyleBar;
	cancelButton.tintColor = [UIColor lightGrayColor];
	[cancelButton addTarget:self action:@selector(peopleCountCancelled:) forControlEvents:UIControlEventValueChanged];

	[asPeopleCount addSubview:closeButton];
	[asPeopleCount addSubview:cancelButton];
	[asPeopleCount showInView:self.view];
	[asPeopleCount setBounds:CGRectMake(0,0,320, 464)];
	asPeopleCount.tag = 0;
}

- (void)createIndGenderPickerView
{
	if (asIndGender == nil)
	{
		asIndGender = [[UIActionSheet alloc] initWithTitle:@"an individual of"
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
	[closeButton addTarget:self action:@selector(IndGenderSelected:) forControlEvents:UIControlEventValueChanged];

	UISegmentedControl *cancelButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"Cancel"]];
	cancelButton.momentary = YES;
	cancelButton.frame = CGRectMake(10, 7, 50, 30);
	cancelButton.segmentedControlStyle = UISegmentedControlStyleBar;
	cancelButton.tintColor = [UIColor lightGrayColor];
	[cancelButton addTarget:self action:@selector(IndGenderCancelled:) forControlEvents:UIControlEventValueChanged];

	[asIndGender addSubview:closeButton];
	[asIndGender addSubview:cancelButton];
	[asIndGender showInView:self.view];
	[asIndGender setBounds:CGRectMake(0, 0, 320, 464)];
	asIndGender.tag = 1;
}

- (void)createGrpGenderPickerView
{
	if (asGrpGender == nil)
	{
		asGrpGender = [[UIActionSheet alloc] initWithTitle:@"a of Group"
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
	[closeButton addTarget:self action:@selector(GrpGenderSelected:) forControlEvents:UIControlEventValueChanged];

	UISegmentedControl *cancelButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"Cancel"]];
	cancelButton.momentary = YES;
	cancelButton.frame = CGRectMake(10, 7, 50, 30);
	cancelButton.segmentedControlStyle = UISegmentedControlStyleBar;
	cancelButton.tintColor = [UIColor lightGrayColor];
	[cancelButton addTarget:self action:@selector(GrpGenderCancelled:) forControlEvents:UIControlEventValueChanged];

	[asGrpGender addSubview:closeButton];
	[asGrpGender addSubview:cancelButton];
	[asGrpGender showInView:self.view];
	[asGrpGender setBounds:CGRectMake(0, 0, 320, 464)];
	asGrpGender.tag = 2;
}

- (void) createDelayTimePickerView
{
	if (asDelayTime == nil)
	{
		asDelayTime = [[UIActionSheet alloc] initWithTitle:@"Select delay time"
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
	[closeButton addTarget:self action:@selector(DelayTimeSelected:) forControlEvents:UIControlEventValueChanged];

	UISegmentedControl *cancelButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"Cancel"]];
	cancelButton.momentary = YES;
	cancelButton.frame = CGRectMake(10, 7, 50, 30);
	cancelButton.segmentedControlStyle = UISegmentedControlStyleBar;
	cancelButton.tintColor = [UIColor lightGrayColor];
	[cancelButton addTarget:self action:@selector(DelayTimeCancelled:) forControlEvents:UIControlEventValueChanged];

	[asDelayTime addSubview:closeButton];
	[asDelayTime addSubview:cancelButton];
	[asDelayTime showInView:self.view];
	[asDelayTime setBounds:CGRectMake(0, 0, 320, 464)];
	asDelayTime.tag = 3;
}

- (IBAction) onClickPeopleCount : (id)sender
{
	[self createPeoplePickerView];

	int nRowCount = [pickerCount numberOfRowsInComponent:0];
	int i = 0;
	for (i = 0; i < nRowCount; i++)
	{
		NSString *szTemp = [arrPeopleCount objectAtIndex:i];
		if ([szTemp isEqualToString:lblCount.text])
			break;
	}

	if (i == nRowCount)
		i = 0;

	[pickerCount selectRow:i inComponent:0 animated:NO];

	[asPeopleCount addSubview:pickerCount];
}

- (void) peopleCountSelected:(id)sender
{
	int nRow = [pickerCount selectedRowInComponent:0];
	[lblCount setText:[arrPeopleCount objectAtIndex:nRow]];
	[asPeopleCount dismissWithClickedButtonIndex:0 animated:YES];

	[self enableControls];

}

- (void) peopleCountCancelled:(id)sender
{
	[asPeopleCount dismissWithClickedButtonIndex:0 animated:YES];

	[self enableControls];
}

- (IBAction) onClickIndGender : (id)sender
{
	[self createIndGenderPickerView];

	int nRowCount = [pickerIndGender numberOfRowsInComponent:0];
	int i = 0;
	for (i = 0; i < nRowCount; i++)
	{
		NSString *szTemp = [arrGender objectAtIndex:i];
		if ([szTemp isEqualToString:lblIndGender.text])
		{
			break;
		}
	}
	
	if (i == nRowCount)
		i = 0;
	
	[pickerIndGender selectRow:i inComponent:0 animated:NO];

	[asIndGender addSubview:pickerIndGender];
}

- (void) IndGenderSelected:(id)sender
{
	int nRow = [pickerIndGender selectedRowInComponent:0];
	[lblIndGender setText:[arrGender objectAtIndex:nRow]];
	[asIndGender dismissWithClickedButtonIndex:0 animated:YES];
}

- (void) IndGenderCancelled:(id)sender
{
	[asIndGender dismissWithClickedButtonIndex:0 animated:YES];
}

- (IBAction) onClickGrpGender : (id)sender
{
	[self createGrpGenderPickerView];

	int nRowCount = [pickerGrpGender numberOfRowsInComponent:0];
	int i = 0;
	for (i = 0; i < nRowCount; i++)
	{
		NSString *szTemp = [arrGrpGender objectAtIndex:i];
		if ([szTemp isEqualToString:lblGrpGender.text])
			break;
	}

	if (i == nRowCount)
		i = 0;

	[pickerGrpGender selectRow:i inComponent:0 animated:NO];

	[asGrpGender addSubview:pickerGrpGender];
}

- (void) GrpGenderSelected:(id)sender
{
	int nRow = [pickerGrpGender selectedRowInComponent:0];
	[lblGrpGender setText:[arrGrpGender objectAtIndex:nRow]];
	[asGrpGender dismissWithClickedButtonIndex:0 animated:YES];
}

- (void) GrpGenderCancelled:(id)sender
{
	[asGrpGender dismissWithClickedButtonIndex:0 animated:YES];
}


- (IBAction) onClickDelayTime : (id)sender
{
	[self createDelayTimePickerView];

	int nRowCount = [pickerDelayTime numberOfRowsInComponent:0];
	int i = 0;
	for (i = 0; i < nRowCount; i++)
	{
		NSString *szTemp = [arrDelayTime objectAtIndex:i];
		szTemp = [szTemp stringByAppendingString:@" minutes"];
		NSString *szMinutes = lblDelayTime.text;
		if ([szTemp isEqualToString:szMinutes])
			break;
	}

	if (i == nRowCount)
		i = 0;

	[pickerDelayTime selectRow:i inComponent:0 animated:NO];
	[asDelayTime addSubview:pickerDelayTime];
}

- (void) DelayTimeSelected:(id)sender
{
	int nRow = [pickerDelayTime selectedRowInComponent:0];
	NSString *szMinutes = [arrDelayTime objectAtIndex:nRow];
	szMinutes = [szMinutes stringByAppendingString:@" minutes"];
	[lblDelayTime setText:szMinutes];
	[asDelayTime dismissWithClickedButtonIndex:0 animated:YES];
}

- (void) DelayTimeCancelled:(id)sender
{
	[asDelayTime dismissWithClickedButtonIndex:0 animated:YES];
}

- (IBAction) onClickOK : (id)sender
{
//	[DejalActivityView activityViewForView:self.view withLabel:@"waiting..." indicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	[Common startDejalActivity:self.view];

	userProfile.IsGroup = [lblCount.text isEqualToString:@"Yes"] ? 1 : 0;

	int nIndGender = 0;
	if ([lblIndGender.text isEqualToString:@"Male"])
		nIndGender = 0;
	else if ([lblIndGender.text isEqualToString:@"Female"])
		nIndGender = 1;
	else
		nIndGender = 2;
	userProfile.IndGender = nIndGender;


	int nGrpGender = 0;
	if ([lblGrpGender.text isEqualToString:@"Male"])
		nGrpGender = 0;
	else if ([lblGrpGender.text isEqualToString:@"Female"])
		nGrpGender = 1;
	else if ([lblGrpGender.text isEqualToString:@"Mixed"])
		nGrpGender = 2;
	else if ([lblGrpGender.text isEqualToString:@"Male or Mixed"])
		nGrpGender = 3;
	else if ([lblGrpGender.text isEqualToString:@"Female or Mixed"])
		nGrpGender = 4;
	else if ([lblGrpGender.text isEqualToString:@"Any"])
		nGrpGender = 5;
	userProfile.GrpGender = nGrpGender;

	int nDelayTime = 10;
	if ([lblDelayTime.text isEqualToString:@"3 minutes"])
		nDelayTime = 3;
	else if ([lblDelayTime.text isEqualToString:@"5 minutes"])
		nDelayTime = 5;
	else if ([lblDelayTime.text isEqualToString:@"10 minutes"])
		nDelayTime = 10;
	userProfile.DelayTime = nDelayTime;

	if (![Common isReachable:YES])
		return;

	CommManager* commMgr = [CommManager getCommMgr];
	[commMgr userManage].delegate = (id<UserManageDelegate>)self;
	[[commMgr userManage] getRequestUserProfileUpdate:userProfile];
}

- (void)getRequestUserProfileUpdateResult:(StringContainer *)szRes
{
	[Common endDejalActivity];

	if (szRes.Result == 1)
	{
		[Common showAlert:@"Save success"];

		TaxiStandMapViewController* controller = [[TaxiStandMapViewController alloc] initWithNibName:@"TaxiStandMapViewController" bundle:nil];
		SHOW_VIEW(controller);
	}
	else
		[Common showAlert:@"Save failed"];
}

- (void)getRequestUserProfileResult:(STUserProfile *)result
{
	[Common endDejalActivity];
	
	userProfile = result;
	
	if (userProfile.IsGroup == 1)
		[lblCount setText:@"Yes"];
	else
		[lblCount setText:@"No"];

	[lblIndGender setText:[arrGender objectAtIndex:userProfile.IndGender]];
	[lblGrpGender setText:[arrGrpGender objectAtIndex:userProfile.GrpGender]];

	[lblDelayTime setText:[NSString stringWithFormat:@"%d minutes", userProfile.DelayTime]];

	[self enableControls];
}

- (void)enableControls
{
	bool bIsGroup = [lblCount.text isEqualToString:@"Yes"];
	btnSelGrpGender.enabled = bIsGroup;
}

@end
