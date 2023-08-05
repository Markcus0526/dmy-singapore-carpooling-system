//
//  SuperViewController.h
//  CarPool
//
//  Created by KimHakMin on 10/6/13.
//  Copyright (c) 2013 RiKS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideMenuView.h"

@interface SuperViewController : UIViewController
{
	SlideMenuView		*pMenuView;
	IBOutlet UIView				*pMainView;

	bool				bShowMenu;
}

- (IBAction)showhideMenu:(id)sender;
- (void) showhideMenuFunc;

@property (nonatomic, retain) SlideMenuView *pMenuView;
@property (nonatomic, retain) IBOutlet UIView *pMainView;

@end
