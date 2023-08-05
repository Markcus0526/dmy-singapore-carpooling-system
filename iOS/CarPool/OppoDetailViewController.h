//
//  OppoDetailViewController.h
//  CarPool
//
//  Created by KimHakMin on 10/17/13.
//  Copyright (c) 2013 RiKS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SuperViewController.h"
#import "STDataInfo.h"
#import "CommManager.h"

@interface OppoDetailViewController : SuperViewController<UserManageDelegate>
{
	IBOutlet UILabel*	lblPairInfo;
	NSTimer*			timer;
}

@property(nonatomic, retain) UILabel* lblPairInfo;
@property(nonatomic, retain) NSTimer* timer;

- (IBAction)onClickNextBoard:(id)sender;

@end
