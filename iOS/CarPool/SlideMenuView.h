//
//  SlideMenuView.h
//  CarPool
//
//  Created by KimHakMin on 10/6/13.
//  Copyright (c) 2013 RiKS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SlideMenuView : UIView<UITableViewDataSource, UITableViewDelegate>
{
	NSMutableArray *cell_array;
	NSMutableArray *cell_str_array;

	UIViewController *superVC;

	UITableView *tableview;
}

@property (nonatomic, retain) UIViewController *superVC;

@property (nonatomic, retain) UITableView *tableview;

+ (SlideMenuView *) createSlideMenu : (UIViewController *)superViewController;

- (void) selectNone;

@end
