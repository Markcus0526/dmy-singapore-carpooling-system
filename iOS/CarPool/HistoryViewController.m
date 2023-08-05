//
//  HistoryViewController.m
//  CarPool
//
//  Created by KimHakMin on 10/6/13.
//  Copyright (c) 2013 RiKS. All rights reserved.
//

#import "HistoryViewController.h"
#import "Common.h"
#import "CommManager.h"
#import "SVPullToRefresh.h"
#import "DejalActivityView.h"
#import "RatingViewController.h"

@interface HistoryViewController ()

@end

@implementation HistoryViewController

#define ROW_HEIGHT		50
#define PAGE_ITEMCOUNT	15

@synthesize tableview;
@synthesize lblPrice;
@synthesize lblNotYet;

@synthesize arrData;
@synthesize nPageCount;
@synthesize count;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if ([Common getPhoneType] == IPHONE5)
		nibNameOrNil = [nibNameOrNil stringByAppendingString:@"_ios5"];
	
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];


	if (self)
	{
		arrData = [[NSMutableArray alloc] initWithCapacity:0];
//		[arrData addObject:@"1"];
//		[arrData addObject:@"2"];
//		[arrData addObject:@"3"];

		nPageCount = 1;
	}

	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view from its nib.

	if (![Common isReachable:YES])
		return;
	
	__weak HistoryViewController *weakSelf = self;
	[tableview addInfiniteScrollingWithActionHandler:^{
		[weakSelf insertRowAtBottom];
	}];
	
	[Common startDejalActivity:self.view];

	CommManager* commMgr = [CommManager getCommMgr];
	[commMgr userManage].delegate = self;
	[[commMgr userManage] getRequestPairingHistoryCount:[Common readUserIdFromFile]];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)onButtonClick:(id)sender
{
	UIButton *btnRate = (UIButton*)sender;
	int nRow = btnRate.tag;

	STPairHistory *pairHistory = [arrData objectAtIndex:nRow];

	RatingViewController *controller = [[RatingViewController alloc] initWithNibName:@"RatingViewController" bundle:nil];
	controller.pairHistory = pairHistory;
	SHOW_VIEW(controller);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return ROW_HEIGHT;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [arrData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	STPairHistory *item = nil;
	if (indexPath.row < 0 || indexPath.row >= arrData.count)
		return [[UITableViewCell alloc] init];

	item = [arrData objectAtIndex:indexPath.row];

	NSString *identifier = [NSString stringWithFormat:@"cell_%@_%@_%.1f_%.1f_%d_%d", item.Name1, item.Name2, item.Score1,item.Score2, item.Gender1, item.Gender2];
	int nRow = indexPath.row;
	CGRect rcBounds;

	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	if (cell == nil)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];

		rcBounds = cell.bounds;

		UIColor *clrText = [UIColor colorWithRed:180/255.f green:180/255.f blue:180/255.f alpha:1];
		UILabel *lblTime = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 140, 17)];
		[lblTime setFont:[UIFont systemFontOfSize:14]];
		[lblTime setBackgroundColor:[UIColor clearColor]];
		[lblTime setText:item.PairingTime];
		[lblTime setTextColor:clrText];
		[cell addSubview:lblTime];

		UILabel *lblPair = [[UILabel alloc] initWithFrame:CGRectMake(15, 28, 150, 17)];
		[lblPair setFont:[UIFont systemFontOfSize:14]];
		[lblPair setBackgroundColor:[UIColor clearColor]];
		NSString *szName = nil, *szStartAddr = nil;
		if ([Common readUserIdFromFile] == item.Uid1)
			szName = item.Name2;
		else
			szName = item.Name1;

		szStartAddr = item.SrcAddr;

		[lblPair setText:[NSString stringWithFormat:@"with %@ @%@", szName, szStartAddr]];
		[lblPair setTextColor:clrText];
		[cell addSubview:lblPair];

		UILabel *lblScore = [[UILabel alloc] initWithFrame:CGRectMake(165, 10, 50, 30)];
		UIFont *sysFont = [UIFont systemFontOfSize:15];
		NSString *sysFontName = sysFont.fontName;
		UIFont *fntTemp = [UIFont fontWithName:[NSString stringWithFormat:@"%@-BoldOblique", sysFontName] size:25];
		[lblScore setBackgroundColor:[UIColor clearColor]];
		bool isRated = false;
		if (item.Uid1 == [Common readUserIdFromFile])
		{
			if (item.Score2 < 0)
				[lblScore setText:@"-"];
			else
				[lblScore setText:[NSString stringWithFormat:@"%.1f", item.Score2]];

			if (item.Score2 >= 0)
				isRated = true;
		}
		else
		{
			if (item.Score1 < 0)
				[lblScore setText:@"-"];
			else
				[lblScore setText:[NSString stringWithFormat:@"%.1f", item.Score1]];

			if (item.Score1 >= 0)
				isRated = true;
		}

		[lblScore setTextColor:lblPrice.textColor];
		[lblScore setFont:fntTemp];
		[cell addSubview:lblScore];

		UIButton *btnRate = [UIButton buttonWithType:UIButtonTypeCustom];
		btnRate.frame = CGRectMake(210, 10, 70, 30);
		btnRate.tag = nRow;

		int nOppoGender = 0;
		if (item.Uid1 == [Common readUserIdFromFile])
			nOppoGender = item.Gender2;
		else
			nOppoGender = item.Gender1;

		if (nOppoGender == 0)
			[btnRate setImage:[UIImage imageNamed:@"btnRateHim.png"] forState:UIControlStateNormal];
		else
			[btnRate setImage:[UIImage imageNamed:@"btnRateHer.png"] forState:UIControlStateNormal];

		[btnRate addTarget:self action:@selector(onButtonClick:) forControlEvents:UIControlEventTouchUpInside];

		if (isRated)
			[btnRate setEnabled:NO];
//		else
//			lblScore.hidden = YES;

		[cell addSubview:btnRate];
	}

	return cell;
}

- (void) getRequestPairingHistoryCountResult:(STPairHistoryCount *)result
{
	count = result;
	
	STReqPairHistory *reqHistory = [[STReqPairHistory alloc] init];
	
	if (arrData.count == 0)
	{
		nPageCount = 1;
	}
	
	reqHistory.Uid = [Common readUserIdFromFile];
	reqHistory.PageNo = nPageCount;

	CommManager* commMgr = [CommManager getCommMgr];
	[commMgr userManage].delegate = self;
	[[commMgr userManage] getRequestPairingHistoryList:reqHistory];
}

- (void)showHideControls
{
	if (arrData.count == 0)
	{
		tableview.hidden = YES;
		lblNotYet.hidden = NO;
	}
	else
	{
		tableview.hidden = NO;
		lblNotYet.hidden = YES;
	}
}

- (void)getRequestPairingHistoryListResult:(NSMutableArray*)arrHistory
{
	[Common endDejalActivity];

	if (arrHistory == nil)
		return;

	[tableview endUpdates];
	[tableview.infiniteScrollingView stopAnimating];

	if (arrData.count < PAGE_ITEMCOUNT * nPageCount)
	{
		[arrData removeObjectsInRange:NSMakeRange((nPageCount - 1) * PAGE_ITEMCOUNT, arrData.count - PAGE_ITEMCOUNT * (nPageCount - 1))];
	}

	[arrData addObjectsFromArray:arrHistory];
	if (arrHistory.count == PAGE_ITEMCOUNT)
		nPageCount++;

	CGRect tblFrame = tableview.frame;
	tblFrame.size.height = self.view.bounds.size.height - 60 - tblFrame.origin.y;

	[tableview setFrame:tblFrame];
	[tableview reloadData];
	[lblPrice setText: [NSString stringWithFormat:@"S$%.2f", count.TotalSaving]];

	[self showHideControls];

}


- (void)insertRowAtBottom
{
	__weak HistoryViewController *weakSelf = self;
	int64_t delayInSeconds = 1.0;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		[weakSelf.tableview beginUpdates];

		CommManager* commMgr = [CommManager getCommMgr];
		[commMgr userManage].delegate = self;
		[[commMgr userManage] getRequestPairingHistoryCount:[Common readUserIdFromFile]];
	});
}



@end
