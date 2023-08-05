//
//  ImportantNoticeViewController.m
//  CarPool
//
//  Created by RiKS on 9/11/13.
//  Copyright (c) 2013 RiKS. All rights reserved.
//

#import "ImportantNoticeViewController.h"
#import "OnBoardViewController.h"
#import "Common.h"

@interface ImportantNoticeViewController ()

@end

@implementation ImportantNoticeViewController

@synthesize btnUnderstand;

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

-(IBAction)onUnderstand:(id)sender
{	
	OnBoardViewController *controller = [[OnBoardViewController alloc] initWithNibName:@"OnBoardViewController" bundle:nil];
	controller.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
//	[self presentViewController : controller animated:YES completion:nil];
	SHOW_VIEW(controller);
}

@end
