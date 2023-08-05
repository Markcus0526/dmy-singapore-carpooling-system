//
//  TaxiStandFindViewController.m
//  CarPool
//
//  Created by RiKS on 9/12/13.
//  Copyright (c) 2013 RiKS. All rights reserved.
//

#import "TaxiStandFindViewController.h"
#import "TaxiStandMapViewController.h"
#import "FindNotTaxiStandViewController.h"
#import "Common.h"
#import "DejalActivityView.h"
#import "CommManager.h"
#import "MyInfoViewController.h"

@interface TaxiStandFindViewController ()

@end

@implementation TaxiStandFindViewController

@synthesize btnFind;
@synthesize btnCannotFind;
@synthesize textFind;
@synthesize taxiStand;
@synthesize tableview;

@synthesize arrTaxiStands;
@synthesize arrDBTaxiStands;

@synthesize parentController;
@synthesize reverse_geocoder;

@synthesize imgFind;
@synthesize btnCancel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if ([Common getPhoneType] == IPHONE5)
		nibNameOrNil = [nibNameOrNil stringByAppendingString:@"_ios5"];
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

	if (self)
	{
		parentController = nil;
		reverse_geocoder = nil;

		arrDBTaxiStands = [[NSMutableArray alloc] initWithCapacity:0];
	}

	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

-(IBAction)onFindCancel:(id)sender
{
	if (![Common isReachable:YES])
		return;

	[Common startDejalActivity:self.view];
	STReqTaxiStand *userInfo = [[STReqTaxiStand alloc] init];
	
	userInfo.Uid = [Common readUserIdFromFile];

#if true
	userInfo.Latitude = taxiStand.Latitude;
	userInfo.Longitude = taxiStand.Longitude;

	if (textFind.text == NULL)
		userInfo.Keyword = @"";
	else
		userInfo.Keyword = textFind.text;
#else
	userInfo.Latitude = 1.3;
	userInfo.Longitude = 103.85;
#endif

	CommManager* commMgr = [CommManager getCommMgr];
	[commMgr userManage].delegate = self;
	[[commMgr userManage] getRequestTaxiStandList:userInfo];
}

-(IBAction)onCannotFind:(id)sender
{
	NSIndexPath *indexPath = [tableview indexPathForSelectedRow];
	if (((arrDBTaxiStands == nil || [arrDBTaxiStands count] == 0) && (arrTaxiStands == nil || [arrTaxiStands count] == 0)) || indexPath == nil)
	{
		CLLocation *location = [[CLLocation alloc] initWithLatitude:taxiStand.Latitude longitude:taxiStand.Longitude];
		reverse_geocoder = [[CLGeocoder alloc] init];
		[reverse_geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
			CLPlacemark *placeMark = [placemarks objectAtIndex:0];

			NSDictionary *addr_dict = placeMark.addressDictionary;
			if (addr_dict == nil)
				taxiStand.GpsAddress = @"gps address unknown";
			else
			{
				NSArray *addressLines = [addr_dict objectForKey:@"FormattedAddressLines"];
				if (addressLines == nil || [addressLines count] != 4)
					taxiStand.GpsAddress = @"gps address unknown";
				else
				{
					taxiStand.GpsAddress = [NSString stringWithFormat:@"%@ %@ %@ %@", [addressLines objectAtIndex:0], [addressLines objectAtIndex:1], [addressLines objectAtIndex:2], [addressLines objectAtIndex:3]];
				}
			}

			taxiStand.StandType = @"taxi_stand";
			taxiStand.StandName = @"New taxi stand";
			taxiStand.StandNo = @"";
			taxiStand.PostCode = @"";

			FindNotTaxiStandViewController *controller = [[FindNotTaxiStandViewController alloc] initWithNibName:@"FindNotTaxiStandViewController" bundle:nil];
			controller.taxi_stand = taxiStand;
			SHOW_VIEW(controller);
//			[self presentViewController:controller animated:YES completion:nil];

		}];
	}
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	int nRow = indexPath.row;

	if (arrTaxiStands != nil && arrTaxiStands.count > 0)
	{
		GoogleTaxiStand *taxi_stand = [arrTaxiStands objectAtIndex:nRow];
		if (parentController != nil)
		{
			TaxiStandMapViewController *controller = (TaxiStandMapViewController *)parentController;

			STTaxiStandResp *resp = [[STTaxiStandResp alloc] init];

			STTaxiStand *taxistand = [[STTaxiStand alloc] init];

			taxistand.Latitude = taxi_stand.location.latitude;
			taxistand.Longitude = taxi_stand.location.longitude;
			taxistand.StandName = taxi_stand.name;
			taxistand.StandNo = @"";
			taxistand.GpsAddress = taxi_stand.vicinity;
			taxistand.StandType = @"taxi_stand";
			taxistand.PostCode = @"";

			resp.Result = 1;
			resp.Message = @"Success";
			resp.TaxiStand = taxistand;

			controller.curTaxiStand = resp;

			BACK_VIEW(self);
		}
	}
	else if (arrDBTaxiStands != nil && arrDBTaxiStands.count > 0)
	{
		STTaxiStand *taxi_stand = [arrDBTaxiStands objectAtIndex:nRow];
		if (parentController != nil)
		{
			TaxiStandMapViewController *controller = (TaxiStandMapViewController *)parentController;
			
			STTaxiStandResp *resp = [[STTaxiStandResp alloc] init];

			resp.Result = 1;
			resp.Message = @"Success";
			resp.TaxiStand = taxi_stand;

			controller.curTaxiStand = resp;
			
			BACK_VIEW(self);
		}

	}
}

-(void) getRequestTaxiStandListResult:(NSMutableArray *)result
{	
	[Common endDejalActivity];
	
	arrDBTaxiStands = result;
	if (arrDBTaxiStands == nil || arrDBTaxiStands.count == 0)
	{
		arrTaxiStands = [[[CommManager getCommMgr] userManage] findPositionWithName:textFind.text Type:@"taxi_stand" Latitude:taxiStand.Latitude Longitude:taxiStand.Longitude Radius:@"1000"];
	}
	else
	{
		[arrTaxiStands removeAllObjects];
	}
	
	[tableview reloadData];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[self onFindCancel:nil];
	[textFind resignFirstResponder];
	return YES;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (arrTaxiStands != nil && [arrTaxiStands count] != 0)
	{
		[btnCannotFind setEnabled:NO];
		return [arrTaxiStands count];
	}
	else if (arrDBTaxiStands != nil && arrDBTaxiStands.count != 0)
	{
		[btnCannotFind setEnabled:NO];
		return arrDBTaxiStands.count;
	}
	else
	{
		[btnCannotFind setEnabled:YES];
		return 0;
	}
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = nil;

	if (arrTaxiStands != nil && arrTaxiStands.count > 0)
	{
		GoogleTaxiStand *taxi_stand = [arrTaxiStands objectAtIndex:indexPath.row];
		NSString *identifier = [NSString stringWithFormat:@"taxi_cell_%@_%@", taxi_stand.name, taxi_stand.vicinity];
		cell = [tableView dequeueReusableCellWithIdentifier:identifier];
		if (cell == nil)
		{
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];


			UIImageView *imgView = [[UIImageView alloc] initWithImage:taxi_stand.icon_image];
			imgView.frame = CGRectMake(10, 10, 30, 30);
			[cell addSubview:imgView];


			UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(60, 10, 240, 20)];
			lblTitle.backgroundColor = [UIColor clearColor];
			lblTitle.text = taxi_stand.name;
			lblTitle.textColor = [UIColor colorWithRed:0x30/255.0 green:0x75/255.0 blue:0xA0/255.0 alpha:1];
			[lblTitle setFont:[UIFont systemFontOfSize:17]];
			[lblTitle setTextAlignment:NSTextAlignmentLeft];
			[cell addSubview:lblTitle];


			UILabel *lblDistrict = [[UILabel alloc] initWithFrame:CGRectMake(60, 35, 240, 15)];
			lblDistrict.backgroundColor = [UIColor clearColor];
			lblDistrict.text = taxi_stand.vicinity;
			lblDistrict.textColor = [UIColor blackColor];
			[lblDistrict setTextAlignment:NSTextAlignmentLeft];
			[lblDistrict setFont:[UIFont systemFontOfSize:14]];
			[cell addSubview:lblDistrict];
		}
	}
	else if (arrDBTaxiStands != nil && arrDBTaxiStands.count > 0)
	{
		STTaxiStand *taxi_stand = [arrDBTaxiStands objectAtIndex:indexPath.row];
		NSString *identifier = [NSString stringWithFormat:@"taxi_cell_%@_%@", taxi_stand.StandName, taxi_stand.GpsAddress];
		cell = [tableView dequeueReusableCellWithIdentifier:identifier];

		if (cell == nil)
		{
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
			
			
			UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"buildmark.png"]];
			imgView.frame = CGRectMake(10, 10, 30, 30);
			[cell addSubview:imgView];


			UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(60, 10, 240, 20)];
			lblTitle.backgroundColor = [UIColor clearColor];
			lblTitle.text = taxi_stand.StandName;
			lblTitle.textColor = [UIColor colorWithRed:0x30/255.0 green:0x75/255.0 blue:0xA0/255.0 alpha:1];
			[lblTitle setFont:[UIFont systemFontOfSize:17]];
			[lblTitle setTextAlignment:NSTextAlignmentLeft];
			[cell addSubview:lblTitle];


			UILabel *lblDistrict = [[UILabel alloc] initWithFrame:CGRectMake(60, 35, 240, 15)];
			lblDistrict.backgroundColor = [UIColor clearColor];
			lblDistrict.text = taxi_stand.GpsAddress;
			lblDistrict.textColor = [UIColor blackColor];
			[lblDistrict setTextAlignment:NSTextAlignmentLeft];
			[lblDistrict setFont:[UIFont systemFontOfSize:14]];
			[cell addSubview:lblDistrict];
		}
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



@end
