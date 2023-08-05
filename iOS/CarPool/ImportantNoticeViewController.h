//
//  ImportantNoticeViewController.h
//  CarPool
//
//  Created by RiKS on 9/11/13.
//  Copyright (c) 2013 RiKS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImportantNoticeViewController : UIViewController
{
	IBOutlet UIButton *btnUnderstand;
}

@property(nonatomic, retain) IBOutlet UIButton *btnUnderstand;

-(IBAction)onUnderstand:(id)sender;

@end
