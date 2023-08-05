//
//  MatchFoundViewController.h
//  CarPool
//
//  Created by KimHakMin on 10/15/13.
//  Copyright (c) 2013 RiKS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SuperViewController.h"
#import "STDataInfo.h"
#import "Utils/CommManager.h"

@interface MatchFoundViewController : SuperViewController<UserManageDelegate>
{
	IBOutlet UILabel *lblResult;

	CLLocationCoordinate2D start_coord;
	CLLocationCoordinate2D dst_coord;

	STPairResponse *pairResp;

	UIViewController *parentController;
	NSTimer *timer;

	int curCount;
}

@property (nonatomic, retain) IBOutlet UILabel *lblResult;
@property (nonatomic, retain) STPairResponse *pairResp;

@property (nonatomic, nonatomic) CLLocationCoordinate2D start_coord;
@property (nonatomic, nonatomic) CLLocationCoordinate2D dst_coord;

@property (nonatomic, retain) UIViewController *parentController;
@property (nonatomic, nonatomic) int curCount;
@property (nonatomic, retain) NSTimer *timer;

-(IBAction)onViewRoute:(id)sender;
-(IBAction)onReject:(id)sender;
-(IBAction)onCheckOut:(id)sender;

@end
