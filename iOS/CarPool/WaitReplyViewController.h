//
//  WaitReplyViewController.h
//  CarPool
//
//  Created by KimHakMin on 10/16/13.
//  Copyright (c) 2013 RiKS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SuperViewController.h"
#import "Utils/CommManager.h"

@interface WaitReplyViewController : SuperViewController<UserManageDelegate>
{
	IBOutlet UILabel	*label;
	IBOutlet UIButton	*mainButton;

	NSTimer				*timer;

	int					agree_state;
}

@property (nonatomic, retain) IBOutlet UILabel *label;
@property (nonatomic, retain) NSTimer *timer;
@property (nonatomic, retain) UIButton *mainButton;

- (IBAction)onClickButton:(id)sender;

@end
