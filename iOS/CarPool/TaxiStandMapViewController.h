//
//  TaxiStandMapViewController.h
//  CarPool
//
//  Created by RiKS on 9/11/13.
//  Copyright (c) 2013 RiKS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import "SuperViewController.h"
#import "STDataInfo.h"
#import "Utils/CommManager.h"

@interface TaxiStandMapViewController : SuperViewController <CLLocationManagerDelegate, GMSMapViewDelegate, UserManageDelegate>
{
	IBOutlet UIButton *btnModify;
	IBOutlet UIButton *btnCheckIn;
	IBOutlet UITextField *textCurrentPos;
	IBOutlet GMSMapView *mapView;

	IBOutlet UIButton *btnShowMenu;

	CLLocationManager *loc_man;

	bool runThread;

	STTaxiStandResp *curTaxiStand;
	bool firstLoad;

	int nRetryCount;
}

@property(nonatomic, retain) IBOutlet UIButton *btnModify;
@property(nonatomic, retain) IBOutlet UIButton *btnCheckIn;
@property(nonatomic, retain) IBOutlet UITextField *textCurrentPos;
@property(nonatomic, retain) IBOutlet GMSMapView *mapView;
@property(nonatomic, retain) CLLocationManager *loc_man;
@property(nonatomic, retain) IBOutlet UIButton *btnShowMenu;
@property(nonatomic, nonatomic) bool runThread;
@property(nonatomic, retain) STTaxiStandResp *curTaxiStand;
@property(nonatomic, readwrite) bool firstLoad;

@property(nonatomic, readwrite) int nRetryCount;

-(IBAction)onModify:(id)sender;
-(IBAction)onCheckIn:(id)sender;

//-(void) getNearestTaxiStand;
//-(void) nearestTaxiStandSucceed;

@end
