//
//  TaxiStandFindViewController.h
//  CarPool
//
//  Created by RiKS on 9/12/13.
//  Copyright (c) 2013 RiKS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STDataInfo.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "CommManager.h"

@interface TaxiStandFindViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, CLLocationManagerDelegate, UserManageDelegate>
{
	IBOutlet UIButton *btnFind;
	IBOutlet UIButton *btnCannotFind;
	IBOutlet UITextField *textFind;

	IBOutlet UITableView *tableview;

	IBOutlet UIImageView *imgFind;
	IBOutlet UIButton *btnCancel;

	STTaxiStand *taxiStand;

	NSMutableArray *arrTaxiStands;
	NSMutableArray *arrDBTaxiStands;

	UIViewController *parentController;

	CLGeocoder *reverse_geocoder;
}

@property(nonatomic, retain) IBOutlet UIButton *btnFind;
@property(nonatomic, retain) IBOutlet UIButton *btnCannotFind;
@property(nonatomic, retain) IBOutlet UITextField *textFind;
@property(nonatomic, retain) IBOutlet UITableView *tableview;

@property(nonatomic, retain) CLGeocoder *reverse_geocoder;

@property(nonatomic, retain) STTaxiStand *taxiStand;

@property(nonatomic, retain) NSMutableArray *arrTaxiStands;
@property(nonatomic, retain) NSMutableArray *arrDBTaxiStands;
@property(nonatomic, retain) UIViewController *parentController;

@property (nonatomic, retain) IBOutlet UIImageView *imgFind;
@property (nonatomic, retain) IBOutlet UIButton *btnCancel;

- (IBAction)onFindCancel:(id)sender;
- (IBAction)onCannotFind:(id)sender;
- (IBAction)onClose:(id)sender;

@end
