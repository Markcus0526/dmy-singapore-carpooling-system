//
//  CheckInViewController.h
//  CarPool
//
//  Created by RiKS on 10/4/13.
//  Copyright (c) 2013 RiKS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SuperViewController.h"
#import "STDataInfo.h"
#import "Utils//CommManager.h"

@interface CheckInViewController : SuperViewController<PairManageDelegate>
{
	double fSrcLat;
	double fSrcLon;
	double fDstLat;
	double fDstLon;
	NSString *strDstAddress;
	int nPax;
	int nGrpGender;
	NSString *strColor;
	NSString *strOtherFeature;

	IBOutlet UIButton *btnConfirm;
	IBOutlet UIButton *btnAmend;
	IBOutlet UITextView *txtConfirmData;

	STPairInfo *pairInfo;
	STPairResponse *pairResponse;
}

@property(nonatomic, assign) double fSrcLat;
@property(nonatomic, assign) double fSrcLon;
@property(nonatomic, assign) double fDstLat;
@property(nonatomic, assign) double fDstLon;
@property(nonatomic, retain) NSString *strDstAddress;
@property(nonatomic, assign) int nPax;
@property(nonatomic, assign) int nGrpGender;
@property(nonatomic, retain) NSString *strColor;
@property(nonatomic, retain) NSString *strOtherFeature;

@property(nonatomic, retain) IBOutlet UIButton *btnConfirm;
@property(nonatomic, retain) IBOutlet UIButton *btnAmend;
@property(nonatomic, retain) IBOutlet UITextView *txtConfirmData;

@property(nonatomic, retain) STPairInfo *pairInfo;
@property(nonatomic, retain) STPairResponse *pairResponse;

-(IBAction)onConfirm:(id)sender;
-(IBAction)onAmend:(id)sender;

@end
