//
//  MyInfoViewController.m
//  CarPool
//
//  Created by RiKS on 10/4/13.
//  Copyright (c) 2013 RiKS. All rights reserved.
//

#import "MyInfoViewController.h"
#import "CheckInViewController.h"
#import "KeyboardHelper.h"
#import "Common.h"
#import "TaxiStandFindViewController.h"
#import "DestFindViewController.h"

@interface MyInfoViewController ()

@end

@implementation MyInfoViewController

@synthesize txtOtherFeature;
@synthesize txtColorOfTop;
@synthesize txtPax;
@synthesize txtGrpGender;
@synthesize btnGrpGenderDetail;
@synthesize btnPaxDetail;
@synthesize pickerGrpGender;
@synthesize pickerPax;
@synthesize sheetGrpGender;
@synthesize sheetPax;
@synthesize fSrcLat;
@synthesize fSrcLon;
@synthesize fDstLat;
@synthesize fDstLon;
@synthesize btnCheckIn;
@synthesize dest;
@synthesize btnDest;
@synthesize txtDest;
@synthesize pickerColor;
@synthesize sheetColor;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if ([Common getPhoneType] == IPHONE5)
		nibNameOrNil = [nibNameOrNil stringByAppendingString:@"_ios5"];
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

	if (self)
	{
		// Custom initialization
		fDstLat = 0;
		fDstLon = 0;
		dest = @"";
	}
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view from its nib.

	mPax = [Common getPax];
	mGrpGender = [Common getIndGender];
	NSMutableArray* arrColors = [Common getColorArray];
	[txtColorOfTop setText:(NSString*)[arrColors objectAtIndex:0]];
	[txtPax setText:(NSString*)[mPax objectAtIndex:0]];
	[txtGrpGender setText:(NSString*)[mGrpGender objectAtIndex:0]];

	keyboardVisible = false;
	curTextField = nil;
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

///////////////////////////////////////////////////////////////////
#pragma mark - Scroll When Keyboard Focus
- (void)textViewDidBeginEditing:(UITextView *)textView
{
	curTextField = textView;
	if (keyboardVisible)
		[KeyboardHelper moveScrollView:curTextField scrollView:(UIScrollView*)pMainView];
}
- (void)textViewDidEndEditing:(UITextView *)textView
{
	curTextField = nil;
	[textView resignFirstResponder];
}

- (IBAction)BeginEditing:(UITextField *)sender
{
	curTextField = sender;
	if (keyboardVisible)
		[KeyboardHelper moveScrollView:curTextField scrollView:(UIScrollView*)pMainView];
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
	
	[KeyboardHelper moveScrollView:curTextField scrollView:(UIScrollView*)pMainView];
	
	keyboardVisible = true;
}

- (void)keyboardWillHide:(NSNotification *)notification
{
	//---gets the size of the keyboard---
	NSDictionary *userInfo = [notification userInfo];
	NSValue *keyboardValue = [userInfo objectForKey:UIKeyboardBoundsUserInfoKey];
	[keyboardValue getValue:&keyboardBounds];

	[KeyboardHelper moveScrollView:nil scrollView:(UIScrollView*)pMainView];

	keyboardVisible = false;

	curTextField = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:self.view.window];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:self.view.window];
}

- (void)viewDidAppear:(BOOL)animated
{
	if (dest == nil || [dest isEqualToString:@""])
	{
		txtDest.text = @"";
//		[btnDest setTitle:@"Your destination" forState:UIControlStateNormal];
//		[btnDest setTitle:@"Your destination" forState:UIControlStateHighlighted];
	}
	else
	{
		txtDest.text = dest;
//		[btnDest setTitle:dest forState:UIControlStateNormal];
//		[btnDest setTitle:dest forState:UIControlStateHighlighted];
	}
}

- (void)viewWillDisappear:(BOOL)animated
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

-(IBAction)onClickBack:(id)sender
{
	BACK_VIEW(self);
}

- (IBAction)btnCheckInClicked:(id)sender
{
	if ([txtColorOfTop text].length == 0) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ride2Gather" message:@"Please input your color of top." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		return;
	}

	[txtOtherFeature resignFirstResponder];

#if true
	if (dest != nil && dest.length == 0)
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ride2Gather" message:@"Please input your destination." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		return;
	}
#endif

	CheckInViewController *controller = [[CheckInViewController alloc] initWithNibName:@"CheckInViewController" bundle:nil];

	controller.fSrcLat = self.fSrcLat;
	controller.fSrcLon = self.fSrcLon;
#if true
	controller.fDstLat = self.fDstLat;
	controller.fDstLon = self.fDstLon;
	controller.strDstAddress = dest;
#else			// For test
	controller.fDstLat = 41.6648;
	controller.fDstLon = 123.3442;
	controller.strDstAddress = @"Near Sujiatun";
#endif
	controller.nPax = [[txtPax text] intValue];
	controller.nGrpGender = [pickerGrpGender selectedRowInComponent:0];
	controller.strColor = [txtColorOfTop text];
	controller.strOtherFeature = [txtOtherFeature text];

	SHOW_VIEW(controller);
//	controller.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
//	[self presentViewController:controller animated:YES completion:nil];
}

- (IBAction)btnBackgroundClicked:(id)sender
{
	if (curTextField != nil)
		[curTextField resignFirstResponder];
}

- (IBAction)onPaxDetail:(id)sender
{
	[self createPaxSheet];
	pickerPax = [[UIPickerView alloc] initWithFrame:CGRectMake(0.0, 45.0, 0.0, 0.0)];
	pickerPax.dataSource = self;
	pickerPax.delegate = self;
	pickerPax.showsSelectionIndicator = YES;
	[sheetPax addSubview:pickerPax];

	if ([txtPax text].length > 0) {
		NSString *pax = [txtPax text];
		
		for (int i = 0; i < mPax.count; i++) {
			NSString *strData = [mPax objectAtIndex:i];
			if ( [pax isEqualToString:strData] == YES) {
				[pickerPax selectRow:i inComponent:0 animated :YES];
				break;
			}
		}
	}
}

- (IBAction)onGrpGenderDetail:(id)sender
{
	[self createGrpGenderSheet];
	pickerGrpGender = [[UIPickerView alloc] initWithFrame:CGRectMake(0.0, 45.0, 0.0, 0.0)];
	pickerGrpGender.dataSource = self;
	pickerGrpGender.delegate = self;
	pickerGrpGender.showsSelectionIndicator = YES;
	[sheetGrpGender addSubview:pickerGrpGender];

	if ([txtGrpGender text].length > 0) {
		NSString *grpGender = [txtGrpGender text];
		
		for (int i = 0; i < mGrpGender.count; i++) {
			NSString *strData = [mGrpGender objectAtIndex:i];
			if ( [grpGender isEqualToString:strData] == YES) {
				[pickerGrpGender selectRow:i inComponent:0 animated :YES];
				break;
			}
		}
	}
}

- (IBAction)onColorDetail:(id)sender
{
	[self createColorSheeet];

	pickerColor = [[UIPickerView alloc] initWithFrame:CGRectMake(0.0, 45.0, 0.0, 0.0)];
	pickerColor.dataSource = self;
	pickerColor.delegate = self;
	pickerColor.showsSelectionIndicator = YES;
	[sheetColor addSubview:pickerColor];

	if ([txtColorOfTop text].length > 0)
	{
		NSMutableArray* arrTopColors = [Common getColorArray];
		NSString *grpGender = [txtColorOfTop text];

		for (int i = 0; i < arrTopColors.count; i++) {
			NSString *strData = [arrTopColors objectAtIndex:i];
			if ([grpGender isEqualToString:strData] == YES)
			{
				[pickerColor selectRow:i inComponent:0 animated :YES];
				break;
			}
		}
	}
}

- (void)createPaxSheet
{
	if (sheetPax == nil) {
		// setup actionsheet to contain the UIPicker
		sheetPax = [[UIActionSheet alloc] initWithTitle:@"No. of Pax"
												  delegate:self
										 cancelButtonTitle:nil
									destructiveButtonTitle:nil
										 otherButtonTitles:nil];
		
		UISegmentedControl *closeButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"OK"]];
		closeButton.momentary = YES;
		closeButton.frame = CGRectMake(260, 7, 50, 30);
		closeButton.segmentedControlStyle = UISegmentedControlStyleBar;
		closeButton.tintColor = [UIColor blueColor];
		[closeButton addTarget:self action:@selector(onPaxSelected:) forControlEvents:UIControlEventValueChanged];
		
		UISegmentedControl *cancelButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"Cancel"]];
		cancelButton.momentary = YES;
		cancelButton.frame = CGRectMake(10, 7, 50, 30);
		cancelButton.segmentedControlStyle = UISegmentedControlStyleBar;
		cancelButton.tintColor = [UIColor lightGrayColor];
		[cancelButton addTarget:self action:@selector(onPaxCanceled:) forControlEvents:UIControlEventValueChanged];
		
		[sheetPax addSubview:closeButton];
		[sheetPax addSubview:cancelButton];
		[sheetPax showInView:self.view];
		[sheetPax setBounds:CGRectMake(0,0,320, 464)];
		
	}
}

- (void)createGrpGenderSheet
{
	if (sheetGrpGender == nil) {
		// setup actionsheet to contain the UIPicker
		sheetGrpGender = [[UIActionSheet alloc] initWithTitle:@"Gender"
													 delegate:self
											cancelButtonTitle:nil
									   destructiveButtonTitle:nil
											otherButtonTitles:nil];

		UISegmentedControl *closeButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"OK"]];
		closeButton.momentary = YES;
		closeButton.frame = CGRectMake(260, 7, 50, 30);
		closeButton.segmentedControlStyle = UISegmentedControlStyleBar;
		closeButton.tintColor = [UIColor blueColor];
		[closeButton addTarget:self action:@selector(onGrpGenderSelected:) forControlEvents:UIControlEventValueChanged];

		UISegmentedControl *cancelButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"Cancel"]];
		cancelButton.momentary = YES;
		cancelButton.frame = CGRectMake(10, 7, 50, 30);
		cancelButton.segmentedControlStyle = UISegmentedControlStyleBar;
		cancelButton.tintColor = [UIColor lightGrayColor];
		[cancelButton addTarget:self action:@selector(onGrpGenderCanceled:) forControlEvents:UIControlEventValueChanged];

		[sheetGrpGender addSubview:closeButton];
		[sheetGrpGender addSubview:cancelButton];
		[sheetGrpGender showInView:self.view];
		[sheetGrpGender setBounds:CGRectMake(0,0,320, 464)];
		
	}
}

- (void)createColorSheeet
{
	if (sheetColor == nil) {
		sheetColor = [[UIActionSheet alloc] initWithTitle:@"Color of your top"
													 delegate:self
											cancelButtonTitle:nil
									   destructiveButtonTitle:nil
											otherButtonTitles:nil];

		UISegmentedControl *closeButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"OK"]];
		closeButton.momentary = YES;
		closeButton.frame = CGRectMake(260, 7, 50, 30);
		closeButton.segmentedControlStyle = UISegmentedControlStyleBar;
		closeButton.tintColor = [UIColor blueColor];
		[closeButton addTarget:self action:@selector(onTopColorSelected:) forControlEvents:UIControlEventValueChanged];

		UISegmentedControl *cancelButton = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObject:@"Cancel"]];
		cancelButton.momentary = YES;
		cancelButton.frame = CGRectMake(10, 7, 50, 30);
		cancelButton.segmentedControlStyle = UISegmentedControlStyleBar;
		cancelButton.tintColor = [UIColor lightGrayColor];
		[cancelButton addTarget:self action:@selector(onTopColorCancelled:) forControlEvents:UIControlEventValueChanged];

		[sheetColor addSubview:closeButton];
		[sheetColor addSubview:cancelButton];
		[sheetColor showInView:self.view];
		[sheetColor setBounds:CGRectMake(0,0,320, 464)];
	}
}

- (IBAction)onPaxSelected:(id)sender
{
	NSMutableString *pax = [NSMutableString string];
	
	int idx = [pickerPax selectedRowInComponent:0];
	[pax appendFormat:@"%@", [mPax objectAtIndex:idx]];
	[sheetPax dismissWithClickedButtonIndex:0 animated:YES];
	sheetPax = nil;
	
	[txtPax setText:pax];
}

- (IBAction)onPaxCanceled:(id)sender
{
	[sheetPax dismissWithClickedButtonIndex:0 animated:YES];
	sheetPax = nil;
}

- (IBAction)onGrpGenderSelected:(id)sender
{
	NSMutableString *grpGender = [NSMutableString string];
	
	int idx = [pickerGrpGender selectedRowInComponent:0];
	[grpGender appendFormat:@"%@", [mGrpGender objectAtIndex:idx]];
	[sheetGrpGender dismissWithClickedButtonIndex:0 animated:YES];
	sheetGrpGender = nil;

	[txtGrpGender setText:grpGender];
}

- (IBAction)onGrpGenderCanceled:(id)sender
{
	[sheetGrpGender dismissWithClickedButtonIndex:0 animated:YES];
	sheetGrpGender = nil;
}

- (void)onTopColorSelected:(id)sender
{
	NSMutableArray* arrColors = [Common getColorArray];
	int idx = [pickerColor selectedRowInComponent:0];
	NSString* topColor = [arrColors objectAtIndex:idx];
	[sheetColor dismissWithClickedButtonIndex:0 animated:YES];
	sheetColor = nil;

	[txtColorOfTop setText:topColor];
}

- (void)onTopColorCancelled:(id)sender
{
	[sheetColor dismissWithClickedButtonIndex:0 animated:YES];
	sheetColor = nil;
}

#pragma mark PickerView DataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	if ([pickerView isEqual:pickerPax])
		return mPax.count;
	else if ([pickerView isEqual:pickerGrpGender])
		return mGrpGender.count;
	else if ([pickerView isEqual:pickerColor])
		return [Common getColorArray].count;
	return 0;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
	UILabel* label = (UILabel*)view;
	if (view == nil)
	{
		label= [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 44)];
		[label setTextAlignment:NSTextAlignmentCenter];
		label.opaque= YES;
		label.backgroundColor=[UIColor clearColor];
		label.textColor = [UIColor blackColor];
		UIFont *font = [UIFont boldSystemFontOfSize:20];
		label.font = font;
	}
	
	if ([pickerView isEqual:pickerPax])
	{
		[label setText:[mPax objectAtIndex:row]];
	}
	else if ([pickerView isEqual:pickerGrpGender])
	{
		[label setText:[mGrpGender objectAtIndex:row]];
	}
	else
	{
		[label setText:[[Common getColorArray] objectAtIndex:row]];
	}

	return label;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row
	  inComponent:(NSInteger)component
{
}

- (IBAction)onDestClicked:(id)sender
{
	DestFindViewController *controller = [[DestFindViewController alloc] initWithNibName:@"DestFindViewController" bundle:nil];
	controller.parentController = self;
	SHOW_VIEW(controller);
}


@end
