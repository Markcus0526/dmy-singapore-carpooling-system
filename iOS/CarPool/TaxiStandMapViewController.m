//
//  TaxiStandMapViewController.m
//  CarPool
//
//  Created by RiKS on 9/11/13.
//  Copyright (c) 2013 RiKS. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#import "TaxiStandMapViewController.h"
#import "TaxiStandFindViewController.h"
#import "BuyCreditViewController.h"
#import "MyInfoViewController.h"
#import "CommManager.h"
#import "DejalActivityView.h"
#import "Common.h"
#import "CarPoolAppDelegate.h"

#import <Foundation/NSKeyValueObserving.h>

@interface TaxiStandMapViewController ()

@end

@implementation TaxiStandMapViewController
{
	bool bFirst;
	double fSrcLat;
	double fSrcLon;
}

@synthesize btnModify;
@synthesize btnCheckIn;
@synthesize textCurrentPos;
@synthesize mapView;
@synthesize loc_man;

@synthesize btnShowMenu;
@synthesize runThread;
@synthesize curTaxiStand;
@synthesize firstLoad;

@synthesize nRetryCount;

#define TAXISTAND_NOT_FOUND		-109
#define RETRY_COUNT				3

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if ([Common getPhoneType] == IPHONE5)
		nibNameOrNil = [nibNameOrNil stringByAppendingString:@"_ios5"];

	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

	if (self)
	{
		firstLoad = YES;
		curTaxiStand = nil;
		nRetryCount = 0;
	}

	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];

	[mapView setDelegate:self];
	mapView.myLocationEnabled = YES;
	mapView.settings.compassButton = YES;
	mapView.settings.myLocationButton = YES;
	[mapView moveCamera:[GMSCameraUpdate zoomTo:15]];

	runThread = false;

	loc_man = [[CLLocationManager alloc] init];
	loc_man.delegate = self;
	[loc_man startUpdatingLocation];

	bFirst = false;
	fSrcLat = 0.0f;
	fSrcLon = 0.0f;
}

- (NSString*)getTextForStartAddres:(STTaxiStand*)taxiStand
{
	NSString* szText = @"";

	if (taxiStand != nil)
	{
		if (taxiStand.StandNo == nil || taxiStand.StandNo.length < 1)
			szText = taxiStand.StandName;
		else
			szText = [NSString stringWithFormat:@"%@-%@", taxiStand.StandNo, taxiStand.StandName];
	}

	return szText;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	if (curTaxiStand != nil)
		[textCurrentPos setText:[self getTextForStartAddres:curTaxiStand.TaxiStand]];

	if (textCurrentPos.text != NULL && ![textCurrentPos.text isEqualToString:@""])
		[btnCheckIn setEnabled:YES];
	else
		[btnCheckIn setEnabled:NO];

	[mapView addObserver:self forKeyPath:@"myLocation" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ([keyPath isEqualToString:@"myLocation"] && [object isKindOfClass:[GMSMapView class]])
	{
		[mapView animateToCameraPosition:[GMSCameraPosition cameraWithLatitude:mapView.myLocation.coordinate.latitude longitude:mapView.myLocation.coordinate.longitude zoom:mapView.camera.zoom]];
		if (bFirst == false)
		{
			GMSGeocoder *geocoder = [[GMSGeocoder alloc] init];
			CLLocationCoordinate2D coord = mapView.myLocation.coordinate;
			fSrcLat = coord.latitude;
			fSrcLon = coord.longitude;
			[geocoder reverseGeocodeCoordinate:coord completionHandler:^(GMSReverseGeocodeResponse *place, NSError *error) {
				if (error)
					return;
				if (place && place.results.count > 0)
				{
					bFirst = true;
					//NSString *address1 = place.firstResult.addressLine1;
					//NSString *address2 = place.firstResult.addressLine2;
					//[textCurrentPos setText:[NSString stringWithFormat:@"%@%@", address1, address2]];
					//[textCurrentPos setText:address1];
				}
			}];
		}
	}
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];

	[mapView removeObserver:self forKeyPath:@"myLocation"];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

-(IBAction)onModify:(id)sender
{
	TaxiStandFindViewController *controller = [[TaxiStandFindViewController alloc] initWithNibName:@"TaxiStandFindViewController" bundle:nil];
	controller.parentController = self;
	STTaxiStand *taxi_stand = [[STTaxiStand alloc] init];
	taxi_stand.Latitude = fSrcLat;
	taxi_stand.Longitude = fSrcLon;
	controller.taxiStand = taxi_stand;

	SHOW_VIEW(controller);
//	[self presentViewController:controller animated:YES completion:nil];
}

-(IBAction)onCheckIn:(id)sender
{
	if (curTaxiStand == nil)
	{
		[Common showAlert:@"Not found taxi stand."];
		return;
	}

	[Common startDejalActivity:self.view];

	CommManager* commMgr = [CommManager getCommMgr];
	[commMgr userManage].delegate = self;
	[[commMgr userManage] getRequestUserCredits:[NSString stringWithFormat:@"%ld",[Common readUserIdFromFile]] ];
	
}

- (void) getRequestUserCreditsResult:(int)result
{
	[Common endDejalActivity];
	if (result > 0)
	{
		MyInfoViewController *controller = [[MyInfoViewController alloc] initWithNibName:@"MyInfoViewController" bundle:nil];
		
		controller.fSrcLat = curTaxiStand.TaxiStand.Latitude;
		controller.fSrcLon = curTaxiStand.TaxiStand.Longitude;
		
		[CommManager getGlobalCommMgr].strSrcAddress = curTaxiStand.TaxiStand.StandName;
		
		SHOW_VIEW(controller);
	}
	else
	{
		BuyCreditViewController *controller = [[BuyCreditViewController alloc] initWithNibName:@"BuyCreditViewController" bundle:nil];
		SHOW_VIEW(controller);
	}
}

- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation
{
	[mapView animateToLocation:newLocation.coordinate];
	[loc_man stopUpdatingLocation];

	if (curTaxiStand == NULL && !runThread && firstLoad)
	{
		firstLoad = NO;

		runThread = true;
		nRetryCount = 0;
		[self startTaxiStandThread];
	}
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
	if (error.code == kCLErrorDenied)
	{
		[Common showAlert:@"Location service is disabled by user"];
	}
}

-(void)startTaxiStandThread
{
	STReqTaxiStand *taxiStand = [[STReqTaxiStand alloc] init];

	taxiStand.Uid = [Common readUserIdFromFile];
	taxiStand.Longitude = mapView.myLocation.coordinate.longitude;
	taxiStand.Latitude = mapView.myLocation.coordinate.latitude;

	if (![Common isReachable:YES])
		return;

	[Common startDejalActivity:self.view];
	[NSThread detachNewThreadSelector:@selector(getNearestTaxiStand:) toTarget:self withObject:taxiStand];	
}

- (void)getNearestTaxiStand:(STReqTaxiStand *)taxiStand
{
	CommManager* commMgr = [CommManager getCommMgr];
	[commMgr userManage].delegate = self;
	[[commMgr userManage] getRequestTaxiStand:taxiStand];
}

-(void) getRequestTaxiStandResult:(STTaxiStandResp *)result
{
	[Common endDejalActivity];

	runThread = NO;

	curTaxiStand = result;
	if (curTaxiStand == nil)
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ride2Gather" message:@"Service Failure" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		alert.tag = 2;
		[alert show];

		btnCheckIn.enabled = NO;

		if (nRetryCount < RETRY_COUNT)
		{
			nRetryCount++;
			runThread = true;
			[self startTaxiStandThread];
		}

		return;
	}

	if (curTaxiStand.Result == TAXISTAND_NOT_FOUND)
	{
		curTaxiStand = nil;
		btnCheckIn.enabled = NO;

		if (nRetryCount < RETRY_COUNT)
		{
			nRetryCount++;
			runThread = true;
			[self startTaxiStandThread];
		}

		return;
	}
	else if (curTaxiStand.Result < 0)
	{
		curTaxiStand = nil;
		btnCheckIn.enabled = NO;

		if (nRetryCount < RETRY_COUNT)
		{
			nRetryCount++;
			runThread = true;
			[self startTaxiStandThread];
		}

		return;
	}

	btnCheckIn.enabled = YES;
	[textCurrentPos setText:[self getTextForStartAddres:curTaxiStand.TaxiStand]];
	[loc_man stopUpdatingLocation];
}

@end
