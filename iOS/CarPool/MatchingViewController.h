//
//  MatchingViewController.h
//  CarPool
//
//  Created by RiKS on 10/5/13.
//  Copyright (c) 2013 RiKS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STDataInfo.h"
#import "SuperViewController.h"
#import "Utils/CommManager.h"

@interface MatchingViewController : SuperViewController<UserManageDelegate>
{
	IBOutlet UIButton *btnCheckOut;

	STPairResponse *pairResponse;
	int nRequestCurCount;
}

@property(nonatomic, retain) IBOutlet UIButton *btnCheckOut;
@property(nonatomic, retain) STPairResponse *pairResponse;
@property (nonatomic, nonatomic) int nRequestCurCount;

-(IBAction)btnCheckOutClicked:(id)sender;

- (void)startTimer;

@end
