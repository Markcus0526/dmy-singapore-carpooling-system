//
//  Common.h
//  CarPool
//
//  Created by RiKS on 9/10/13.
//  Copyright (c) 2013 RiKS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "Reachability.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSInteger, DEVICE_KIND)
{
	IPHONE4 = 1,
	IPHONE5,
	IPAD
};

#define MOVE_FROM_LEFT			CATransition *animation = [CATransition animation]; \
								[animation setDuration:0.3]; \
								[animation setType:kCATransitionPush]; \
								[animation setSubtype:kCATransitionFromLeft]; \
								[animation setTimingFunction:[CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut]]; \
								[[self.view.superview layer] addAnimation:animation forKey:@"SwitchToView"];

#define MOVE_FROM_RIGHT(ctrl)	CATransition *animation = [CATransition animation]; \
								[animation setDuration:0.3]; \
								[animation setType:kCATransitionPush]; \
								[animation setSubtype:kCATransitionFromRight]; \
								[animation setTimingFunction:[CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut]]; \
								[[ctrl.view.superview layer] addAnimation:animation forKey:@"SwitchToView"];

#define SHOW_VIEW(ctrl)	 	MOVE_FROM_LEFT \
								[self presentViewController:ctrl animated:NO completion:nil];

#define BACK_VIEW(ctrl)	 	MOVE_FROM_RIGHT(ctrl) \
								[ctrl dismissViewControllerAnimated:NO completion:nil];


#define STATE_NOREPLY			0
#define STATE_AGREE				1
#define STATE_DISAGREE			2

#define LOGIN_NORMAL			0
#define LOGIN_FACEBOOK			1
#define LOGIN_LINKEDIN			2

#define FACEBOOK_APPID			@"443946145715814"/*@"8e1ee50901bebd486473407b9f918ec8"*/
#define FACEBOOK_PERMISSION		@"publish_stream"

#pragma mark Error codes
#define ERR_INVALID_USER		-103

#define LLINFO_FILE_PATH		@"llinfo"
#define FBINFO_FILE_PATH		@"fbinfo"
#define NORMALINFO_FILE_PATH	@"normal_userinfo"

#define KEY_CLIENT			@"client"
#define KEY_EMAIL			@"email"
#define KEY_PHONE			@"phone"
#define KEY_NAME			@"name"
#define KEY_YEAR			@"year"
#define KEY_MONTH			@"month"
#define KEY_DAY				@"day"
#define KEY_TOKEN			@"token"
#define KEY_PHOTO			@"photo"
#define KEY_GENDER			@"gender"
#define KEY_PWD				@"pwd"

#define	STR_APPNAME			@"Ride2Gather"
#define PAIR_SUCCESS		@"Pairing success"
#define OPPO_AGREED			@"Your party agreed to ride with you"
#define OPPO_DISAGREED		@"Your party disagreed to ride with you"

#define		SEND_INTERVAL		10
#define		SEND_LIMIT			7200



#pragma mark Methods
@interface Common : NSObject
{
	SystemSoundID soundID;
}

@property(nonatomic, readwrite) SystemSoundID soundID;

// Instance method
+ (Common*) getInstance;

+ (void)playsound;

+ (NSInteger) getPhoneType;
+ (NSArray*) getGenderKinds;
+ (NSArray*) getPax;
+ (NSArray*) getGrpGender;
+ (NSArray*) getIndGender;
+ (NSMutableArray*) getBirthYear;
+ (NSString*) getOnBoardText;

/*******************************************************************************************/
/***********************************	User information	********************************/
/*******************************************************************************************/

/********************************* linkedin information ************************************/
+ (NSString*) llFilePath;
+ (BOOL) saveLinkedinInfo:(NSString*)email phone:(NSString*)phone name:(NSString*)name year:(int)year month:(int)month day:(int)day token:(NSString*)token photo:(NSString*)photo;
+ (void)clearLinkedinInfo;
/*******************************************************************************************/


/***************************** facebook information ****************************************/
+ (NSString*) fbFilePath;
+ (BOOL) saveFacebookInfo:(NSString*)email phone:(NSString*)phone name:(NSString*)name year:(int)year month:(int)month day:(int)day token:(NSString*)token photo:(NSString*)photo_url;
+ (void)clearFacebookInfo;
/*******************************************************************************************/

/******************************* normal information ****************************************/
+ (NSString*) normalUserInfoPath;
+ (BOOL) saveUserInfo:(NSString*)email password:(NSString*)pwd;
+ (void) clearUserInfo;
+ (NSString*) getNormalEmail;
+ (NSString*) getNormalPwd;
/*******************************************************************************************/

/***************************** normal user information *************************************/
+ (long)readUserIdFromFile;
+ (void)writeUserIDToFile:(long)userID;

+ (void)writeUserNameToFile:(NSString*)userName;

+ (void)writeUserEmailToFile:(NSString*)email;
+ (NSString *)readUserEmailFromFile;

+ (void)writePasswordToFile:(NSString*)email;
+ (NSString *)readPasswordFromFile;

+ (void)saveLoginType:(int)type;
+ (int)loadLoginType;

+ (void)deleteUserInfoFile;
/*******************************************************************************************/
/*******************************************************************************************/
/*******************************************************************************************/


+ (NSString *) getGoogleAPI;
+ (NSString *) getGoogleMapKey;
+ (NSString *) getGoogleServerKey;
+ (NSString *) getGoogleRoutesUrl;
+ (NSURL *) getFindPositionUrlForLongitude:(double)longitude Latitude:(double)latitude Name:(NSString*)name Type:(NSString*)type Radius:(NSString*)radius;

+ (NSMutableArray*)getColorArray;

+ (BOOL) isValidEmail:(NSString *)checkString;
+ (void) showAlert : (NSString *)msg;

+ (NSString *)image2String:(UIImage*)imgData;
+ (UIImage *)string2Image:(NSString*)string;

+ (bool)isValidBirthYear:(NSString*)szYear;
+ (BOOL)isValidPhoneNum:(NSString*)phoneNum;

+ (void)startDejalActivity:(UIView *)view;
+ (void)endDejalActivity;

+ (bool)isReachable:(bool)showMessage;

+ (bool)vibrateIsEnabled;

+ (void)showNotification:(NSString*)szMsg;

@end
