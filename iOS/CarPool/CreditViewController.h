//
//  CreditViewController.h
//  CarPool
//
//  Created by KimHakMin on 10/6/13.
//  Copyright (c) 2013 RiKS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SuperViewController.h"
#import "Utils/CommManager.h"

@interface CreditViewController : SuperViewController<UserManageDelegate>
{
	IBOutlet UILabel *lblCredits;
	IBOutlet UILabel *lblCreditRemain;
	IBOutlet UILabel *lblTotalSaving;
}

@property (nonatomic, retain) IBOutlet UILabel *lblCredits;
@property (nonatomic, retain) IBOutlet UILabel *lblCreditRemain;
@property (nonatomic, retain) IBOutlet UILabel *lblTotalSaving;

- (IBAction) onClickBuy:(id)sender;

@end
