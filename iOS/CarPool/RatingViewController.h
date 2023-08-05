//
//  RatingViewController.h
//  CarPool
//
//  Created by KimHakMin on 10/18/13.
//  Copyright (c) 2013 RiKS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SuperViewController.h"
#import "STDataInfo.h"
#import "ASStarRatingView.h"
#import "Utils/CommManager.h"

@interface RatingViewController : SuperViewController<UserManageDelegate>
{
	STPairHistory *pairHistory;

	IBOutlet UILabel *lblInfo;
	IBOutlet ASStarRatingView *rateView;

	bool bRated;
}

@property (nonatomic, retain) STPairHistory *pairHistory;
@property (nonatomic, retain) UILabel *lblInfo;
@property (nonatomic, retain) ASStarRatingView *rateView;

@property (nonatomic, readwrite) bool bRated;

- (IBAction)onClickOK:(id)sender;

- (IBAction)onClickCancel:(id)sender;

@end
