//
//  DestFindViewController.m
//  CarPool
//
//  Created by KimHakMin on 11/22/13.
//  Copyright (c) 2013 RiKS. All rights reserved.
//

#import "DestFindViewController.h"
#import "TaxiStandMapViewController.h"
#import "FindNotTaxiStandViewController.h"
#import "Common.h"
#import "DejalActivityView.h"
#import "CommManager.h"
#import "MyInfoViewController.h"

@interface DestFindViewController ()

@end

@implementation DestFindViewController

#define PAGE_ITEM_COUNT			20

@synthesize btnFind;
@synthesize textFind;
@synthesize tableview;
@synthesize arrTaxiStands;
@synthesize parentController;
@synthesize imgFind;
@synthesize btnCancel;
@synthesize reverse_geocoder;
@synthesize szKeyword;
@synthesize pageno;
@synthesize reset;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if ([Common getPhoneType] == IPHONE5)
		nibNameOrNil = [nibNameOrNil stringByAppendingString:@"_ios5"];

	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	
	if (self)
	{
		parentController = nil;
		reverse_geocoder = nil;
		szKeyword = @"";
		pageno = 1;
		reset = true;
		arrTaxiStands = [[NSMutableArray alloc] initWithCapacity:0];
	}

	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];

	__weak DestFindViewController *weakSelf = self;
	[tableview addInfiniteScrollingWithActionHandler:^{
		[weakSelf insertRowAtBottom];
	}];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

-(IBAction)onFind:(id)sender
{
	if (![Common isReachable:YES])
		return;

	reset = YES;
	pageno = 1;

	[NSThread detachNewThreadSelector:@selector(getDestDataThread) toTarget:self withObject:nil];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	int nRow = indexPath.row;

	STTaxiStand *taxi_stand = [arrTaxiStands objectAtIndex:nRow];
	if (parentController != nil)
	{
		MyInfoViewController *controller = (MyInfoViewController*)parentController;
		controller.fDstLat = taxi_stand.Latitude;
		controller.fDstLon = taxi_stand.Longitude;

		if (taxi_stand.GpsAddress == nil || [taxi_stand.GpsAddress isEqualToString:@""])
			controller.dest = taxi_stand.StandName;
		else
			controller.dest = taxi_stand.GpsAddress;

		BACK_VIEW(self);
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	if ([textField.text isEqualToString:@""])
	{
		[Common showAlert:@"Please input destination keyword"];
		return NO;
	}
	else
	{
		szKeyword = textField.text;
		[self onFind:nil];
		[textFind resignFirstResponder];
		return YES;
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (arrTaxiStands == nil || [arrTaxiStands count] == 0)
		return 0;

	return [arrTaxiStands count];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	STTaxiStand *taxi_stand = [arrTaxiStands objectAtIndex:indexPath.row];
	NSString *identifier = [NSString stringWithFormat:@"taxi_cell_%@_%@", taxi_stand.StandName, taxi_stand.StandNo];
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];

	if (cell == nil)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];

		UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"buildmark.png"]];
		imgView.frame = CGRectMake(10, 10, 30, 30);
		[cell addSubview:imgView];

		UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(60, 10, 240, 20)];
		lblTitle.backgroundColor = [UIColor clearColor];
		NSString* sztitle = @"";
		if (taxi_stand.GpsAddress != nil && ![taxi_stand.GpsAddress isEqualToString:@""])
			sztitle = taxi_stand.GpsAddress;
		else
			sztitle = taxi_stand.StandName;
		lblTitle.text = sztitle;
		lblTitle.textColor = [UIColor colorWithRed:0x30/255.0 green:0x75/255.0 blue:0xA0/255.0 alpha:1];
		[lblTitle setFont:[UIFont systemFontOfSize:17]];
		[lblTitle setTextAlignment:NSTextAlignmentLeft];
		[cell addSubview:lblTitle];

		UILabel *lblDistrict = [[UILabel alloc] initWithFrame:CGRectMake(60, 35, 240, 15)];
		lblDistrict.backgroundColor = [UIColor clearColor];
		lblDistrict.text = [NSString stringWithFormat:@"%@,(S)%@", taxi_stand.StandName, taxi_stand.PostCode];
		lblDistrict.textColor = [UIColor blackColor];
		[lblDistrict setTextAlignment:NSTextAlignmentLeft];
		[lblDistrict setFont:[UIFont systemFontOfSize:14]];
		[cell addSubview:lblDistrict];
	}

	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 60;
}

- (IBAction)onClose:(id)sender
{
	//	[self dismissViewControllerAnimated:YES completion:nil];
	BACK_VIEW(self);
}

- (void)insertRowAtBottom
{
	__weak DestFindViewController *weakSelf = self;
	int64_t delayInSeconds = 1.0;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		[weakSelf.tableview beginUpdates];
		[NSThread detachNewThreadSelector:@selector(getDestDataThread) toTarget:self withObject:nil];
	});
}

- (void)getDestDataThread
{
	CommManager* commMgr = [CommManager getCommMgr];
	NSMutableArray *arrResult = [[commMgr userManage] getDestList:szKeyword withPageNo:pageno];

	[self performSelectorOnMainThread:@selector(getDestFinished:) withObject:arrResult waitUntilDone:NO];
}

- (void)getDestFinished:(NSMutableArray *)arrResult
{
	if (arrResult == nil)
		return;

	[tableview endUpdates];
	[tableview.infiniteScrollingView stopAnimating];

	if (reset)
	{
		[arrTaxiStands removeAllObjects];
		reset = NO;
	}
	else
	{
		int nBaseCount = PAGE_ITEM_COUNT * (pageno - 1);
		int nRemCount = arrTaxiStands.count - nBaseCount;
		[arrTaxiStands removeObjectsInRange:NSMakeRange(nBaseCount, nRemCount)];
	}

	[arrTaxiStands addObjectsFromArray:arrResult];

	if ([arrResult count] == PAGE_ITEM_COUNT)
		pageno++;

	[tableview reloadData];
}


@end
