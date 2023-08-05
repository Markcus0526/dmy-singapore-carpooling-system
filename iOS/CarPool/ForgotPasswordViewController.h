//
//  ForgotPasswordViewController.h
//  CarPool
//
//  Created by RiKS on 10/13/13.
//  Copyright (c) 2013 RiKS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Utils/CommManager.h"

@interface ForgotPasswordViewController : UIViewController<UserManageDelegate>
{	
	BOOL keyboardVisible;
	UITextField *txtEmail;
}

@property (nonatomic,retain)IBOutlet UITextField *txtEmail;

- (IBAction)btnBackgroundClicked:(id)sender;
- (IBAction)onClickSend:(id)sender;
- (IBAction)onClickBack:(id)sender;

@end
