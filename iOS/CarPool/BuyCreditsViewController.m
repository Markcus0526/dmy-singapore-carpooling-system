//
//  BuyCreditsViewController.m
//  CarPool
//
//  Created by KimHakMin on 10/7/13.
//  Copyright (c) 2013 RiKS. All rights reserved.
//

#import "BuyCreditsViewController.h"
#import "Common.h"
#import "CommManager.h"
#import "FriendViewController.h"
#import "MainIAPHelper.h"
#import <FacebookSDK/FacebookSDK.h>
#import "DejalActivityView.h"

@interface BuyCreditsViewController ()

@end

@implementation BuyCreditsViewController

@synthesize _products;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if ([Common getPhoneType] == IPHONE5)
		nibNameOrNil = [nibNameOrNil stringByAppendingString:@"_ios5"];
	
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

	if (self)
	{
		_products = nil;
	}
	
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	// Do any additional setup after loading the view from its nib.

	[[MainIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
		if (success)
		{
			_products = products;
		}
	}];

}

- (void)viewWillAppear:(BOOL)animated
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:IAPHelperProductPurchasedNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

-(IBAction) onClick5Credits:(id)sender
{
	if (_products == nil || _products.count == 0)
	{
		[Common showAlert:@"No valid products"];
		return;
	}

	SKProduct *product = (SKProduct *)_products[0];
	[[MainIAPHelper sharedInstance] buyProduct:product];
}

-(IBAction) onClick10Credits:(id)sender
{
	if (_products == nil || _products.count <= 1)
	{
		[Common showAlert:@"No valid product for this index"];
		return;
	}

	SKProduct *product = (SKProduct *)_products[1];
	[[MainIAPHelper sharedInstance] buyProduct:product];
}

-(IBAction) onClick20Credits:(id)sender
{
	if (_products == nil || _products.count <= 2)
	{
		[Common showAlert:@"No valid product for this index"];
		return;
	}

	SKProduct *product = (SKProduct *)_products[2];
	[[MainIAPHelper sharedInstance] buyProduct:product];
}

- (void)productPurchased:(NSNotification *)notification
{
	NSString *productIdentifier = notification.object;
	[_products enumerateObjectsUsingBlock:^(SKProduct *product, NSUInteger idx, BOOL *stop) {
		if ([product.productIdentifier isEqualToString:productIdentifier])
		{
			*stop = YES;
		}
	}];
}

- (NSDictionary*)parseURLParams:(NSString *)query
{
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        params[kv[0]] = val;
    }
    return params;
}

-(IBAction) onClickPostFB:(id)sender
{
	[Common startDejalActivity:self.view];
	[NSThread detachNewThreadSelector:@selector(sharableThread) toTarget:self withObject:nil];
}

- (void)sharableThread
{
	UserManage* userManage = [[CommManager getCommMgr] userManage];
	int nRet = [userManage getSharable];
	[self performSelectorOnMainThread:@selector(sharableThreadFinished:) withObject:[NSNumber numberWithInt:nRet] waitUntilDone:NO];
}

- (void)sharableThreadFinished:(id)retvalue
{
	NSInteger ret = [retvalue intValue];
	[Common endDejalActivity];
	if (ret == 0)
	{
		[Common showAlert:@"You are able to share only once a week"];
	}
	else
	{
		[self shareText];
	}
}

- (void)shareText
{
	NSMutableDictionary *params =
    [NSMutableDictionary dictionaryWithObjectsAndKeys:
     @"Facebook SDK for iOS", @"name",
	 //     @"Build great social apps and get more installs.", @"caption",
	 //     @"The Facebook SDK for iOS makes it easier and faster to develop Facebook integrated iOS apps.", @"description",
	 //     @"https://developers.facebook.com/ios", @"link",
	 //     nil, @"picture",
     nil];

    // Invoke the dialog
    [FBWebDialogs presentFeedDialogModallyWithSession:nil
                                           parameters:params
                                              handler:
     ^(FBWebDialogResult result, NSURL *resultURL, NSError *error)
	 {
         if (error) {
             // Error launching the dialog or publishing a story.
             NSLog(@"Error publishing story.");
         }
		 else
		 {
             if (result == FBWebDialogResultDialogNotCompleted)
			 {
                 // User clicked the "x" icon
                 NSLog(@"User canceled story publishing.");
             }
			 else
			 {
                 // Handle the publish feed callback
                 NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                 if (![urlParams valueForKey:@"post_id"])
				 {
                     // User clicked the Cancel button
                     NSLog(@"User canceled story publishing.");
                 }
				 else
				 {
					 // User clicked the Share button
					 NSString *msg = [NSString stringWithFormat:
                                      @"Posted story, id: %@",
                                      [urlParams valueForKey:@"post_id"]];
                     NSLog(@"%@", msg);
                     // Show the result in an alert
					 [Common showAlert:@"Sharing succeeded."];

					 [NSThread detachNewThreadSelector:@selector(logThread) toTarget:self withObject:nil];
				 }
			 }
		 }
	 }];
}

- (void)logThread
{
	STShareLog *shareLog = [[STShareLog alloc] init];
	shareLog.Uid = [Common readUserIdFromFile];
	shareLog.Content = @"";

	UserManage* userManage = [[CommManager getCommMgr] userManage];
	[userManage getRequestShareLog:shareLog];
}

-(IBAction) onClickInvite:(id)sender
{
	FriendViewController *controller = [[FriendViewController alloc] initWithNibName:@"FriendViewController" bundle:nil];
	SHOW_VIEW(controller);
}


@end
