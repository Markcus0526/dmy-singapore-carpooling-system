//
//  RouteViewController.h
//  CarPool
//
//  Created by KimHakMin on 10/15/13.
//  Copyright (c) 2013 RiKS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <GoogleMaps/GoogleMaps.h>
#import "SuperViewController.h"
#import "CommManager.h"
#import "Utils/CommManager.h"

@interface RouteViewController : SuperViewController<GMSMapViewDelegate, UserManageDelegate>
{
	CLLocationCoordinate2D start_coord;
	CLLocationCoordinate2D dst_coord1;
	CLLocationCoordinate2D dst_coord2;

	IBOutlet GMSMapView *mapview;

	int						curCount;
	NSTimer					*timer;

	UIViewController		*matchingController;
	UIViewController		*matchingFoundController;
	
	STPairAgree *pairAgree;
}

@property(nonatomic, nonatomic) CLLocationCoordinate2D start_coord;
@property(nonatomic, nonatomic) CLLocationCoordinate2D dst_coord1;
@property(nonatomic, nonatomic) CLLocationCoordinate2D dst_coord2;
@property(nonatomic, retain) NSTimer *timer;
@property(nonatomic, retain) IBOutlet GMSMapView *mapview;
@property(nonatomic, nonatomic) int curCount;
@property(nonatomic, retain) UIViewController *matchingController;
@property(nonatomic, retain) UIViewController *matchingFoundController;


- (IBAction)onClickAgree:(id)sender;
- (IBAction)onClickReject:(id)sender;




@end
