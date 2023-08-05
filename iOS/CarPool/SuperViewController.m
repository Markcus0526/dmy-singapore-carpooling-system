//
//  SuperViewController.m
//  CarPool
//
//  Created by KimHakMin on 10/6/13.
//  Copyright (c) 2013 RiKS. All rights reserved.
//

#import "SuperViewController.h"
#import "TaxiStandFindViewController.h"

@interface SuperViewController ()

@end

@implementation SuperViewController

@synthesize pMenuView;
@synthesize pMainView;

#define SLIDE_DURATION			0.4f

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		// Custom initialization
	}
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];

	bShowMenu = NO;

	pMenuView = [SlideMenuView createSlideMenu:self];
	pMenuView.frame = CGRectMake(-pMenuView.bounds.size.width, 0, pMenuView.bounds.size.width, pMenuView.bounds.size.height);

	[self.view addSubview:pMenuView];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void) showhideMenuFunc
{
	if (pMainView == nil)
		return;
	
	bShowMenu = !bShowMenu;
	
	CGSize zMenu = pMenuView.bounds.size;
	CGRect rcBounds = pMainView.frame;
	
	if (bShowMenu)
	{
		[UIView animateWithDuration:SLIDE_DURATION animations:^{
			[pMainView setFrame:CGRectMake(zMenu.width, 0, rcBounds.size.width, rcBounds.size.height)];
			[pMenuView setFrame:CGRectMake(0, 0, zMenu.width, zMenu.height)];
		}];
	}
	else
	{
		[UIView animateWithDuration:SLIDE_DURATION animations:^{
			[pMainView setFrame:CGRectMake(0, 0, rcBounds.size.width, rcBounds.size.height)];
			[pMenuView setFrame:CGRectMake(-zMenu.width, 0, zMenu.width, zMenu.height)];
		}];
		
		[pMenuView selectNone];
	}

}

- (IBAction)showhideMenu:(id)sender
{
	[self showhideMenuFunc];
}

@end
