//
//  FindNotTaxiStandViewController.h
//  CarPool
//
//  Created by RiKS on 9/12/13.
//  Copyright (c) 2013 RiKS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STDataInfo.h"
#import "Utils/CommManager.h"

@interface FindNotTaxiStandViewController : UIViewController<UserManageDelegate>
{
	STTaxiStand *taxi_stand;
}

@property (nonatomic, retain) STTaxiStand *taxi_stand;

-(IBAction) onClickSubmit:(id)sender;
- (IBAction)onClickCancel:(id)sender;

@end
