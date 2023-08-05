//
//  MainIAPHelper.m
//  CarPool
//
//  Created by KimHakMin on 11/1/13.
//  Copyright (c) 2013 RiKS. All rights reserved.
//

#import "MainIAPHelper.h"

@implementation MainIAPHelper

+ (MainIAPHelper *)sharedInstance
{
	static dispatch_once_t once;
	static MainIAPHelper *sharedInstance;
	dispatch_once(&once, ^{
		NSSet *productIdentifiers = [NSSet setWithObjects:
									 @"com.damytech.ride2gather.buy5credits",
									 @"com.damytech.ride2gather.buy10credits",
									 @"com.damytech.ride2gather.buy20credits", nil];
		sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
	});

	return sharedInstance;
}

@end
