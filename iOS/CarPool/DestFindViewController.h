//
//  DestFindViewController.h
//  CarPool
//
//  Created by KimHakMin on 11/22/13.
//  Copyright (c) 2013 RiKS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "STDataInfo.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "UIScrollView+SVInfiniteScrolling.h"
#import "UIScrollView+SVPullToRefresh.h"

@interface DestFindViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, CLLocationManagerDelegate>
{
	IBOutlet UIButton		*btnFind;
	IBOutlet UITextField	*textFind;
	IBOutlet UITableView	*tableview;
	IBOutlet UIImageView	*imgFind;
	IBOutlet UIButton		*btnCancel;
	NSMutableArray			*arrTaxiStands;
	UIViewController		*parentController;
	CLGeocoder				*reverse_geocoder;
	NSString				*szKeyword;

	int						pageno;
	bool					reset;
}

@property(nonatomic, retain) IBOutlet UIButton *btnFind;
@property(nonatomic, retain) IBOutlet UITextField *textFind;
@property(nonatomic, retain) IBOutlet UITableView *tableview;
@property(nonatomic, retain) IBOutlet UIImageView *imgFind;
@property(nonatomic, retain) IBOutlet UIButton *btnCancel;
@property(nonatomic, retain) NSMutableArray *arrTaxiStands;
@property(nonatomic, retain) UIViewController *parentController;
@property(nonatomic, retain) CLGeocoder *reverse_geocoder;
@property(nonatomic, retain) NSString *szKeyword;
@property(nonatomic, readwrite) int pageno;
@property(nonatomic, readwrite) bool reset;

- (IBAction)onFind:(id)sender;
- (IBAction)onClose:(id)sender;

@end
