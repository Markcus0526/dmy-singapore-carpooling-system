//
//  HistoryViewController.h
//  CarPool
//
//  Created by KimHakMin on 10/6/13.
//  Copyright (c) 2013 RiKS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SuperViewController.h"
#import "STDataInfo.h"
#import "Utils/CommManager.h"

@interface HistoryViewController : SuperViewController<UITableViewDataSource, UITableViewDelegate, UserManageDelegate>
{
	IBOutlet UITableView *tableview;
	IBOutlet UILabel *lblPrice;
	IBOutlet UILabel *lblNotYet;

	NSMutableArray *arrData;
	int nPageCount;

	STPairHistoryCount *count;
}

@property (nonatomic, retain) IBOutlet UITableView *tableview;
@property (nonatomic, retain) IBOutlet UILabel *lblPrice;
@property (nonatomic, retain) IBOutlet UILabel *lblNotYet;

@property (nonatomic, retain) NSMutableArray *arrData;
@property (nonatomic, nonatomic) int nPageCount;
@property (nonatomic, retain) STPairHistoryCount *count;

-(void)onButtonClick:(id)sender;

@end
