//
//  OnBoardViewController.m
//  CarPool
//
//  Created by RiKS on 9/11/13.
//  Copyright (c) 2013 RiKS. All rights reserved.
//

#import "OnBoardViewController.h"
#import "TaxiStandMapViewController.h"
#import "Common.h"

@interface OnBoardViewController ()

@end

@implementation OnBoardViewController

@synthesize lblData;
@synthesize btnStart;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if ( [Common getPhoneType] == IPHONE5 )
		nibNameOrNil = [nibNameOrNil stringByAppendingString:@"_ios5"];

	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view from its nib
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	NSString *data = [NSString stringWithFormat:@"<p align = \"justify\"><font face=\"Helvetica\" size=\"3\">%@,%@", [self readUserNameFromFile], @"Welcome to the club of smart riders!</font></p><p align = \"justify\"><font face=\"Helvetica\" size=\"3\">According to Land & Transpot Authority's statistics, the average taxi travel distance is 9.7Km per person per trip, which translates to a minimum taxi fare (2 people, excluding any location & midnight surcharges and waiting time) of c.S$14.</font></p><p align = \"justify\"><font face=\"Helvetica\" size=\"3\">By sharing a taxi using Ride2Gather, you split the fare by two and effectively save S$7 on average.</font></p><p align = \"justify\"><font face=\"Helvetica\" size=\"3\">However, only 1 credit is deducted upon each successful sharing, which costs only S$1.28 or less.</font></p><p align = \"justify\"><font face=\"Helvetica\" size=\"3\">There will be absolutely NO credit deduction if you simply check in to a Taxi Stand but do not manage to get a match to share with in the end.</font></p><p align = \"justify\"><font face=\"Helvetica\" size=\"3\">Being an early bird, you have been rewarded with 5 FREE Credits(worth S$6.40).</font></p><p align = \"justify\"><font face=\"Helvetica\" size=\"3\">Hurry up, let your friends know about this promotion and start saving as well.</font></p><p align = \"justify\"><font face=\"Helvetica\" size=\"3\">Let's save more money, more time, and save our lovely earth together!</font></p>"];

	[lblData loadHTMLString:data baseURL:nil];
	[lblData sizeToFit];
}

- (NSString *)readUserNameFromFile
{
	NSString *userName = @"";
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);

	if ([paths count] > 0)
	{
		NSLog(@"%@", [paths objectAtIndex:0]);
		NSString  *dictPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"CarPool.conf"];

		// Read both back in new collections
		NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:dictPath];
		userName = [dictionary valueForKey:@"UserName"];
		return userName;
	}

	return @"";
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

-(IBAction)onStart:(id)sender
{
	TaxiStandMapViewController *controller = [[TaxiStandMapViewController alloc] initWithNibName:@"TaxiStandMapViewController" bundle:nil];
	SHOW_VIEW(controller);
//	[self presentViewController:controller animated:YES completion:nil];
}

@end
