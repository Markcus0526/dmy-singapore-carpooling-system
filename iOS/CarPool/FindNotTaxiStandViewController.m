//
//  FindNotTaxiStandViewController.m
//  CarPool
//
//  Created by RiKS on 9/12/13.
//  Copyright (c) 2013 RiKS. All rights reserved.
//

#import "FindNotTaxiStandViewController.h"
#import "DejalActivityView.h"
#import "Common.h"
#import "CommManager.h"
#import "TaxiStandMapViewController.h"

@interface FindNotTaxiStandViewController ()

@end

@implementation FindNotTaxiStandViewController

#define TAXISTAND_EXIST		-105

@synthesize taxi_stand;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if ([Common getPhoneType] == IPHONE5)
		nibNameOrNil = [nibNameOrNil stringByAppendingString:@"_ios5"];
	
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

	
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

-(IBAction) onClickSubmit:(id)sender
{
	if (![Common isReachable:YES])
		return;

	[Common startDejalActivity:self.view];

	CommManager* commMgr = [CommManager getCommMgr];
	[commMgr userManage].delegate = self;
	[[commMgr userManage] getRequestAddTaxiStand:taxi_stand];
}

-(void) getRequestAddTaxiStandResult:(StringContainer *)szRes
{
	[Common endDejalActivity];

	if (szRes.Result >= 1 || szRes.Result == TAXISTAND_EXIST)
	{
		[Common showAlert:@"Add new taxi stand succeeded"];

		TaxiStandMapViewController *controller = [[TaxiStandMapViewController alloc] initWithNibName:@"TaxiStandMapViewController" bundle:nil];
//		[self presentViewController:controller animated:YES completion:nil];
		SHOW_VIEW(controller);

	}
	else
	{
		[Common showAlert:[NSString stringWithFormat:@"Add new taxi stand failed. %@", szRes.Value]];
	}
}



- (IBAction)onClickCancel:(id)sender
{
//	[self dismissViewControllerAnimated:YES completion:nil];
	BACK_VIEW(self);
}

@end
