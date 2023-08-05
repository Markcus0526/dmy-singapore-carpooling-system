//
//  SlideMenuView.m
//  CarPool
//
//  Created by KimHakMin on 10/6/13.
//  Copyright (c) 2013 RiKS. All rights reserved.
//

#import "SlideMenuView.h"
#import "SuperViewController.h"
#import "Common.h"
#import "ProfileViewController.h"
#import "CriteriaViewController.h"
#import "CreditViewController.h"
#import "FriendViewController.h"
#import "HistoryViewController.h"
#import "HelpViewController.h"
#import "TaxiStandMapViewController.h"

#define VIEW_BACKCOLOR	[UIColor colorWithRed:77/255.f green:77/255.f blue:77/255.f alpha:1]

#define ITEM_IMG_HOME		@"Home.png"
#define ITEM_IMG_PROFILE	@"Profile.png"
#define ITEM_IMG_CRITERIA	@"Criteria.png"
#define ITEM_IMG_CREDIT		@"Credit.png"
#define ITEM_IMG_FRIEND		@"TellFriend.png"
#define ITEM_IMG_HISTORY	@"History_Rating.png"
#define ITEM_IMG_HELP		@"Help.png"

#define ITEM_STR_HOME		@"Home"
#define ITEM_STR_PROFILE	@"Profile"
#define ITEM_STR_CRITERIA	@"Sharing Criteria"
#define ITEM_STR_CREDIT		@"Credit Balance"
#define ITEM_STR_FRIEND		@"Tell a Friend"
#define ITEM_STR_HISTORY	@"History and Rating"
#define ITEM_STR_HELP		@"Help"

#define TABLEVIEW_WIDTH		260
#define IMAGE_VIEWSIZE		CGSizeMake(25, 25)
#define CELL_IMAGE_XPOS		20
#define CELL_TEXT_MARGIN	20
#define GRIDCOLOR			[UIColor colorWithRed:90/255.f green:90/255.f blue:90/255.f alpha:1]

//int cellitem_array[] = {ITEM_HOME, ITEM_PROFILE, ITEM_CRITERIA, ITEM_CREDIT, ITEM_FRIEND, ITEM_HISTORY, ITEM_HELP};

@implementation SlideMenuView

@synthesize superVC;

@synthesize tableview;


- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];

	if (self)
	{
		// Initialization code
		cell_array = [[NSMutableArray alloc] initWithCapacity:0];

		[cell_array addObject:ITEM_IMG_HOME];
		[cell_array addObject:ITEM_IMG_PROFILE];
		[cell_array addObject:ITEM_IMG_CRITERIA];
		[cell_array addObject:ITEM_IMG_CREDIT];
		[cell_array addObject:ITEM_IMG_FRIEND];
		[cell_array addObject:ITEM_IMG_HISTORY];
		[cell_array addObject:ITEM_IMG_HELP];


		cell_str_array = [[NSMutableArray alloc] initWithCapacity:0];
		
		[cell_str_array addObject:ITEM_STR_HOME];
		[cell_str_array addObject:ITEM_STR_PROFILE];
		[cell_str_array addObject:ITEM_STR_CRITERIA];
		[cell_str_array addObject:ITEM_STR_CREDIT];
		[cell_str_array addObject:ITEM_STR_FRIEND];
		[cell_str_array addObject:ITEM_STR_HISTORY];
		[cell_str_array addObject:ITEM_STR_HELP];

		superVC = nil;

		tableview = nil;
	}

	return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
	// Drawing code
}
*/

+ (SlideMenuView *) createSlideMenu : (UIViewController *)superViewController
{
	CGRect rcScreen = [UIScreen mainScreen].bounds;

	SlideMenuView *view = [[SlideMenuView alloc] initWithFrame:CGRectMake(0, 0, TABLEVIEW_WIDTH, rcScreen.size.height)];

	view.backgroundColor = VIEW_BACKCOLOR;
	view.superVC = superViewController;

	CGRect rcBounds = view.bounds;

	view.tableview = [[UITableView alloc] initWithFrame:rcBounds style:UITableViewStylePlain];
	view.tableview.backgroundColor = VIEW_BACKCOLOR;

	view.tableview.dataSource = view;
	view.tableview.delegate = view;
	view.tableview.separatorStyle = UITableViewCellSeparatorStyleNone;

	[view addSubview:view.tableview];

	return view;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [cell_array count] + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	int nRow = indexPath.row;
	if (nRow >= [cell_array count])
		return;

	NSString *szText = [cell_array objectAtIndex:nRow];

	SuperViewController *superViewController = (SuperViewController *)superVC;
	if (superViewController == nil)
		return;
	[superViewController showhideMenuFunc];

	if ([szText isEqualToString:ITEM_IMG_HOME])
	{
		TaxiStandMapViewController *controller = [[TaxiStandMapViewController alloc] initWithNibName:@"TaxiStandMapViewController" bundle:nil];

		CATransition *animation = [CATransition animation];
		[animation setDuration:0.3];
		[animation setType:kCATransitionPush];
		[animation setSubtype:kCATransitionFromLeft];
		[animation setTimingFunction:[CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut]];
		[[superVC.view.superview layer] addAnimation:animation forKey:@"SwitchToView"];
		[superVC presentViewController:controller animated:NO completion:nil];
	}
	else if ([szText isEqualToString:ITEM_IMG_PROFILE])
	{
		if ([superVC isKindOfClass:[ProfileViewController class]])
			return;

		ProfileViewController *viewController = [[ProfileViewController alloc] initWithNibName:@"ProfileViewController" bundle:nil];

		CATransition *animation = [CATransition animation];
		[animation setDuration:0.3];
		[animation setType:kCATransitionPush];
		[animation setSubtype:kCATransitionFromLeft];
		[animation setTimingFunction:[CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut]];
		[[superVC.view.superview layer] addAnimation:animation forKey:@"SwitchToView"];
		[superVC presentViewController:viewController animated:NO completion:nil];
	}
	else if ([szText isEqualToString:ITEM_IMG_CRITERIA])
	{
		if ([superVC isKindOfClass:[CriteriaViewController class]])
			return;

		CriteriaViewController *viewController = [[CriteriaViewController alloc] initWithNibName:@"CriteriaViewController" bundle:nil];

		CATransition *animation = [CATransition animation];
		[animation setDuration:0.3];
		[animation setType:kCATransitionPush];
		[animation setSubtype:kCATransitionFromLeft];
		[animation setTimingFunction:[CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut]];
		[[superVC.view.superview layer] addAnimation:animation forKey:@"SwitchToView"];
		[superVC presentViewController:viewController animated:NO completion:nil];
	}
	else if ([szText isEqualToString:ITEM_IMG_CREDIT])
	{
		if ([superVC isKindOfClass:[CreditViewController class]])
			return;

		CreditViewController *viewController = [[CreditViewController alloc] initWithNibName:@"CreditViewController" bundle:nil];

		CATransition *animation = [CATransition animation];
		[animation setDuration:0.3];
		[animation setType:kCATransitionPush];
		[animation setSubtype:kCATransitionFromLeft];
		[animation setTimingFunction:[CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut]];
		[[superVC.view.superview layer] addAnimation:animation forKey:@"SwitchToView"];
		[superVC presentViewController:viewController animated:NO completion:nil];
	}
	else if ([szText isEqualToString:ITEM_IMG_FRIEND])
	{
		if ([superVC isKindOfClass:[FriendViewController class]])
			return;

		FriendViewController *viewController = [[FriendViewController alloc] initWithNibName:@"FriendViewController" bundle:nil];

		CATransition *animation = [CATransition animation];
		[animation setDuration:0.3];
		[animation setType:kCATransitionPush];
		[animation setSubtype:kCATransitionFromLeft];
		[animation setTimingFunction:[CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut]];
		[[superVC.view.superview layer] addAnimation:animation forKey:@"SwitchToView"];
		[superVC presentViewController:viewController animated:NO completion:nil];
	}
	else if ([szText isEqualToString:ITEM_IMG_HISTORY])
	{
		if ([superVC isKindOfClass:[HistoryViewController class]])
			return;

		HistoryViewController *viewController = [[HistoryViewController alloc] initWithNibName:@"HistoryViewController" bundle:nil];

		CATransition *animation = [CATransition animation];
		[animation setDuration:0.3];
		[animation setType:kCATransitionPush];
		[animation setSubtype:kCATransitionFromLeft];
		[animation setTimingFunction:[CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut]];
		[[superVC.view.superview layer] addAnimation:animation forKey:@"SwitchToView"];
		[superVC presentViewController:viewController animated:NO completion:nil];
	}
	else if ([szText isEqualToString:ITEM_IMG_HELP])
	{
		if ([superVC isKindOfClass:[HelpViewController class]])
			return;

		HelpViewController *viewController = [[HelpViewController alloc] initWithNibName:@"HelpViewController" bundle:nil];

		CATransition *animation = [CATransition animation];
		[animation setDuration:0.3];
		[animation setType:kCATransitionPush];
		[animation setSubtype:kCATransitionFromLeft];
		[animation setTimingFunction:[CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut]];
		[[superVC.view.superview layer] addAnimation:animation forKey:@"SwitchToView"];
		[superVC presentViewController:viewController animated:NO completion:nil];
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *identifier = @"slidemenu_cell";
	int nRow = indexPath.row;

	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	if (cell == nil)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];

		cell.backgroundColor = VIEW_BACKCOLOR;

		CGRect rcCell = cell.bounds;

		UIView *sepView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, rcCell.size.width, 1)];
		sepView.backgroundColor = GRIDCOLOR;
		[cell addSubview:sepView];

		if (nRow >= [cell_array count])
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
		else
		{
			NSString *szImageName = [cell_array objectAtIndex:nRow];
			NSString *szText = [cell_str_array objectAtIndex:nRow];
			UIImage *imgIcon = [UIImage imageNamed:szImageName];
			CGRect rcImage = CGRectMake(CELL_IMAGE_XPOS, rcCell.size.height / 2 - IMAGE_VIEWSIZE.height / 2, IMAGE_VIEWSIZE.width, IMAGE_VIEWSIZE.height);
			UIImageView *iconView = [[UIImageView alloc] initWithFrame:rcImage];
			[iconView setImage:imgIcon];
			[cell addSubview:iconView];

			UILabel *lblText = [[UILabel alloc] initWithFrame:CGRectMake(rcImage.origin.x + rcImage.size.width + CELL_TEXT_MARGIN, 10, rcCell.size.width - rcImage.origin.x - rcImage.size.width - CELL_TEXT_MARGIN, rcCell.size.height - 20)];
			[lblText setBackgroundColor:[UIColor clearColor]];
			[lblText setTextColor:[UIColor whiteColor]];
			[lblText setText:szText];
			[cell addSubview:lblText];
		}
	}

	return cell;
}

- (void) selectNone
{
	[tableview selectRowAtIndexPath:0 animated:NO scrollPosition:UITableViewScrollPositionTop];
}

@end
