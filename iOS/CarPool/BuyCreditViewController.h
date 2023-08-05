//
//  BuyCreditViewController.h
//  CarPool
//
//  Created by RiKS on 10/4/13.
//  Copyright (c) 2013 RiKS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SuperViewController.h"

@interface BuyCreditViewController : SuperViewController
{
	IBOutlet UILabel *lblData;
}

@property(nonatomic, retain)IBOutlet UILabel *lblData;

- (IBAction)onClickMaybeLater:(id)sender;

- (IBAction)onClickBuyNow:(id)sender;

@end
