//
//  OnBoardViewController.h
//  CarPool
//
//  Created by RiKS on 9/11/13.
//  Copyright (c) 2013 RiKS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OnBoardViewController : UIViewController
{
	IBOutlet UIButton *btnStart;
	IBOutlet UIWebView *lblData;
}

@property(nonatomic, retain) IBOutlet UIButton *btnStart;
@property(nonatomic, retain) IBOutlet UIWebView *lblData;

-(IBAction)onStart:(id)sender;

@end
