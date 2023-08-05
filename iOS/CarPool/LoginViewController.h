//
//  LoginViewCotroller.h
//  CarPool
//
//  Created by RiKS on 9/10/13.
//  Copyright (c) 2013 RiKS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LIALinkedInApplication.h"
#import "LIALinkedInHttpClient.h"
#import "LIALinkedInAuthorizationViewController.h"
#import <Foundation/Foundation.h>
#import "Utils/CommManager.h"

@interface LoginViewController : UIViewController<UserManageDelegate>
{
	IBOutlet UIButton *btnFacebookLogin;
	IBOutlet UIButton *btnSignIn;
	IBOutlet UIButton *btnRegister;

}

@property(nonatomic, retain) IBOutlet UIButton *btnFacebookLogin;
@property(nonatomic, retain) IBOutlet UIButton *btnSignIn;
@property(nonatomic, retain) IBOutlet UIButton *btnRegister;




/***************************************************************/
/**************  FBLinkedin information properties  ************/
/***************************************************************/
@property (nonatomic, retain) LIALinkedInApplication *ll_app;
@property (nonatomic, retain) LIALinkedInHttpClient *ll_client;

@property (nonatomic, retain) NSString *ll_accessToken;

@property (nonatomic, nonatomic) int ll_year;
@property (nonatomic, nonatomic) int ll_month;
@property (nonatomic, nonatomic) int ll_day;

@property (nonatomic, retain) NSString *ll_id;
@property (nonatomic, retain) NSString *ll_email;
@property (nonatomic, retain) NSString *ll_name;
@property (nonatomic, retain) NSString *ll_phone;
@property (nonatomic, retain) NSString *ll_photo_url;
@property (nonatomic, retain) NSString *ll_gender;
/***************************************************************/
/***************************************************************/
/***************************************************************/

-(IBAction) btnFacebookLoginClick : (id)sender;
-(IBAction) btnLinkedinLoginClick : (id)sender;
-(IBAction) btnSignInClick : (id)sender;
-(IBAction) btnRegisterClick : (id)sender;

@end
