//
//  BuyCreditsViewController.h
//  CarPool
//
//  Created by KimHakMin on 10/7/13.
//  Copyright (c) 2013 RiKS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>
#import "SuperViewController.h"

@interface BuyCreditsViewController : SuperViewController
{
	NSArray *_products;
}

-(IBAction) onClick5Credits:(id)sender;
-(IBAction) onClick10Credits:(id)sender;
-(IBAction) onClick20Credits:(id)sender;

-(IBAction) onClickPostFB:(id)sender;
-(IBAction) onClickInvite:(id)sender;

@property (nonatomic, retain) NSArray *_products;


@end
