//
//  Common.m
//  CarPool
//
//  Created by RiKS on 9/10/13.
//  Copyright (c) 2013 RiKS. All rights reserved.
//

#import "Common.h"
#import "Base64.h"
#import "BuyCreditsViewController.h"
#import "CreditViewController.h"
#import "CriteriaViewController.h"
#import "FriendViewController.h"
#import "HelpViewController.h"
#import "HistoryViewController.h"
#import "ProfileViewController.h"
#import "DejalActivityView.h"


static Common *sharedInstance = nil;

@implementation Common

@synthesize soundID;

+ (Common *)getInstance {
	@synchronized(self)
	{
		if (sharedInstance == nil)
			sharedInstance = [Common new];
	}

	return sharedInstance;
}

+ (void)playsound
{
}

+ (NSMutableArray*)getColorArray {
	return [NSMutableArray arrayWithObjects:@"Black", @"White", @"Red", @"Orange", @"Yellow", @"Green", @"Cyan", @"Blue", @"Purple", @"Gold", @"Silver", nil];
}

+ (NSInteger)getPhoneType {
	if( [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone )
	{
		if ( [UIScreen mainScreen].bounds.size.height == 568 )
			return IPHONE5;
		else
			return IPHONE4;
	}
	else
		return IPAD;
}

+ (NSArray*) getGenderKinds {
	NSArray *array = [[NSArray alloc] initWithObjects:@"Male", @"Female", nil];
	return array;
}

+ (NSArray*) getPax {
	NSArray *array = [[NSArray alloc] initWithObjects:@"1", @"2", @"3", nil];
	return array;
}

+ (NSArray*) getGrpGender {
	NSArray *array = [[NSArray alloc] initWithObjects:@"Male", @"Female", @"Mixed", @"Male or Mixed", @"Female or Mixed", @"Any", nil];
	return array;
}

+ (NSArray*) getIndGender {
	NSArray *array = [[NSArray alloc] initWithObjects:@"Male", @"Female", @"Mixed", nil];
	return array;
}

+ (NSMutableArray*) getBirthYear {
	NSDateComponents *today = [[NSCalendar currentCalendar] components:(NSYearCalendarUnit) fromDate:[NSDate date]];
	NSInteger year = [today year];
	NSInteger count = 101;

	NSMutableArray *array = [NSMutableArray arrayWithCapacity:count];
	for (int i = 0; i < count; i++)
	{
		[array addObject:[NSString stringWithFormat:@"%d", year-100+i]];
	}

	return array;
}

+ (NSString*)getOnBoardText {
	NSString *strData = @"XXX, welcome to the club of smart riders!\n According to Land & Transpot Authority's statistics, the average taxi travel distance is 9.7Km per person per trip, which translates to a minimum taxi fare (2 peope, excluding any location & midnight surcharges and waiting time) of c.S$14. By sharing a taxi using RIDE2GATHER, you split the fare by two and effectively save S$7 on average. However. only 1 credit is deducted upon each successful sharing, which costs only S$1 or less. There will be absolutely no credit deduction if you simply check in to a Taxi Stand but do not manage to get a match to share with in the end.\n Being an early bird, you have been rewarded with 5 FREE Credits(worth S$5). Hurry up, let your friends know about this promotion and start saving as well.\n Let's save more money time, and save our lovely earth together!";
	return strData;
}



+ (NSString*) llFilePath {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	
	NSString *docDir = [paths objectAtIndex:0];
	NSString *filePath = [NSString stringWithFormat:@"%@/%@", docDir, LLINFO_FILE_PATH];
	return filePath;
}
+ (BOOL) saveLinkedinInfo:(NSString*)email phone:(NSString*)phone name:(NSString*)name year:(int)year month:(int)month day:(int)day token:(NSString*)token photo:(NSString*)photo {
	NSString *szYear = [NSString stringWithFormat:@"%d", year];
	NSString *szMonth = [NSString stringWithFormat:@"%d", month];
	NSString *szDay = [NSString stringWithFormat:@"%d", day];
	
	if (photo == nil)
		photo = @"";
	
	NSDictionary *resultDict = [NSDictionary dictionaryWithObjectsAndKeys : email, KEY_EMAIL, phone, KEY_PHONE, name, KEY_NAME, szYear, KEY_YEAR, szMonth, KEY_MONTH, szDay, KEY_DAY, token, KEY_TOKEN, photo, KEY_PHOTO, @"Male", KEY_GENDER, nil];
	
	return [resultDict writeToFile:[Common llFilePath] atomically:YES];
}
+ (void)clearLinkedinInfo {
	NSFileManager* fileManager = [NSFileManager defaultManager];
	
	if ([fileManager isReadableFileAtPath:[Common llFilePath]])
		[fileManager removeItemAtPath:[Common llFilePath] error:nil];

	[Common saveLoginType:-1];
}

+ (NSString*) fbFilePath {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	
	NSString *docDir = [paths objectAtIndex:0];
	NSString *filePath = [NSString stringWithFormat:@"%@/%@", docDir, FBINFO_FILE_PATH];
	return filePath;
}
+ (BOOL) saveFacebookInfo:(NSString*)email phone:(NSString*)phone name:(NSString*)name year:(int)year month:(int)month day:(int)day token:(NSString*)token photo:(NSString*)photo_url {
	NSString *szYear = [NSString stringWithFormat:@"%d", year];
	NSString *szMonth = [NSString stringWithFormat:@"%d", month];
	NSString *szDay = [NSString stringWithFormat:@"%d", day];
	
	if (photo_url == nil)
		photo_url = @"";
	
	NSDictionary *resultDict = [NSDictionary dictionaryWithObjectsAndKeys : email, KEY_EMAIL, phone, KEY_PHONE, name, KEY_NAME, szYear, KEY_YEAR, szMonth, KEY_MONTH, szDay, KEY_DAY, token, KEY_TOKEN, photo_url, KEY_PHOTO, @"Male", KEY_GENDER, nil];
	
	return [resultDict writeToFile:[Common fbFilePath] atomically:YES];
}

+ (void)clearFacebookInfo {
	NSFileManager* fileManager = [NSFileManager defaultManager];
	
	if ([fileManager isReadableFileAtPath:[Common fbFilePath]])
		[fileManager removeItemAtPath:[Common fbFilePath] error:nil];
	
	[Common saveLoginType:-1];
}


+ (NSString*) normalUserInfoPath
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	
	NSString *docDir = [paths objectAtIndex:0];
	NSString *filePath = [NSString stringWithFormat:@"%@/%@", docDir, NORMALINFO_FILE_PATH];
	return filePath;
}

+ (BOOL) saveUserInfo:(NSString*)email password:(NSString*)pwd
{
	NSDictionary *resultDict = [NSDictionary dictionaryWithObjectsAndKeys:email, KEY_EMAIL, pwd, KEY_PWD, nil];
	return [resultDict writeToFile:[Common normalUserInfoPath] atomically:YES];
}

+ (void) clearUserInfo
{
	NSFileManager* fileManager = [NSFileManager defaultManager];

	if ([fileManager isReadableFileAtPath:[Common normalUserInfoPath]])
		[fileManager removeItemAtPath:[Common normalUserInfoPath] error:nil];

	[Common saveLoginType:-1];
}

+ (NSString*) getNormalEmail
{
	NSString* szEmail = @"";

	// Read both back in new collections
	NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:[Common normalUserInfoPath]];
	if (dictionary == nil)
		return @"";

	szEmail = [dictionary objectForKey:KEY_EMAIL];

	if (szEmail == nil)
		return @"";

	return szEmail;
}

+ (NSString*) getNormalPwd
{
	NSString* szPwd = @"";

	// Read both back in new collections
	NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:[Common normalUserInfoPath]];
	if (dictionary == nil)
		return @"";
	
	szPwd = [dictionary objectForKey:KEY_PWD];

	if (szPwd == nil)
		return @"";
	
	return szPwd;
}


+ (long)readUserIdFromFile {
	long userId = 0;
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	
	if ([paths count] > 0)
	{
		NSLog(@"%@", [paths objectAtIndex:0]);
		NSString  *dictPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"CarPool.conf"];
		
		// Read both back in new collections
		NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:dictPath];
		
		userId = [[dictionary valueForKey:@"UserID"] longLongValue];
		
		return userId;
	}
	
	return 0;
}

+ (void)writeUserIDToFile:(long)userID {
	// Get path to documents directory
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	if ([paths count] > 0) {
		// Path to save dictionary
		NSString  *dictPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"CarPool.conf"];
		
		NSMutableDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:dictPath];
		
		NSFileManager *fileManager = [NSFileManager defaultManager];
		if (![fileManager fileExistsAtPath:dictPath]) {
			dic = [[NSMutableDictionary alloc] init];
		}
		
		NSString *strUserID = [NSString stringWithFormat:@"%ld", userID];
		
		[dic setValue:strUserID forKey:@"UserID"];
		[dic writeToFile:dictPath atomically:YES];
	}
}

+ (void)writeUserNameToFile:(NSString*)userName {
	// Get path to documents directory
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	if ([paths count] > 0) {
		// Path to save dictionary
		NSString  *dictPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"CarPool.conf"];
		
		NSMutableDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:dictPath];
		
		NSFileManager *fileManager = [NSFileManager defaultManager];
		if (![fileManager fileExistsAtPath:dictPath]) {
			dic = [[NSMutableDictionary alloc] init];
		}
		
		[dic setValue:userName forKey:@"UserName"];
		[dic writeToFile:dictPath atomically:YES];
	}
}

+ (void)deleteUserInfoFile {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);

	if ([paths count] > 0)
	{
		NSLog(@"%@", [paths objectAtIndex:0]);
		NSString  *dictPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"CarPool.conf"];

		NSFileManager *fileManager = [NSFileManager defaultManager];
		NSError *error;
		if ([fileManager removeItemAtPath:dictPath error:&error])
		{
			NSLog(@"Removed user id file successfully!");
		}
		else
		{
			NSLog(@"Remove user id file failed!");
		}
	}

}

+ (NSString *)readUserEmailFromFile {
	NSString *userEmail = @"";
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	if ([paths count] > 0)
	{
		NSLog(@"%@", [paths objectAtIndex:0]);
		NSString  *dictPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"CarPool.conf"];
		
		// Read both back in new collections
		NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:dictPath];
		
		userEmail = [dictionary valueForKey:@"UserEmail"];
		
		return userEmail;
	}
	
	return @"";
}
+ (void)writeUserEmailToFile:(NSString*)email {
	// Get path to documents directory
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	if ([paths count] > 0)
	{
		// Path to save dictionary
		NSString  *dictPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"CarPool.conf"];
		
		NSMutableDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:dictPath];
		
		NSFileManager *fileManager = [NSFileManager defaultManager];
		if (![fileManager fileExistsAtPath:dictPath])
		{
			dic = [[NSMutableDictionary alloc] init];
		}
		
		NSString *strUserEmail = email;
		
		[dic setValue:strUserEmail forKey:@"UserEmail"];
		[dic writeToFile:dictPath atomically:YES];
	}
}

+ (NSString *)readPasswordFromFile {
	NSString *szPwd = @"";
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	if ([paths count] > 0)
	{
		NSLog(@"%@", [paths objectAtIndex:0]);
		NSString  *dictPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"CarPool.conf"];
		
		// Read both back in new collections
		NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:dictPath];
		
		szPwd = [dictionary valueForKey:@"Password"];
	}
	
	return szPwd;
}
+ (void)writePasswordToFile:(NSString*)password {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	if ([paths count] > 0)
	{
		// Path to save dictionary
		NSString  *dictPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"CarPool.conf"];
		
		NSMutableDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:dictPath];
		
		NSFileManager *fileManager = [NSFileManager defaultManager];
		if (![fileManager fileExistsAtPath:dictPath])
		{
			dic = [[NSMutableDictionary alloc] init];
		}
		
		NSString *strPwd = password;
		
		[dic setValue:strPwd forKey:@"Password"];
		[dic writeToFile:dictPath atomically:YES];
	}
}

+ (void)saveLoginType:(int)type {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	
	if ([paths count] > 0)
	{
		// Path to save dictionary
		NSString  *dictPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"LoginType.conf"];
		
		NSMutableDictionary *dic = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:type] forKey:@"Type"];
		[dic writeToFile:dictPath atomically:YES];
	}
}
+ (int)loadLoginType {
	int nType = -1;
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	
	if ([paths count] > 0)
	{
		NSLog(@"%@", [paths objectAtIndex:0]);
		NSString  *dictPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"LoginType.conf"];
		
		// Read both back in new collections
		NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:dictPath];
		
		id objType = [dictionary objectForKey:@"Type"];
		
		if (objType != nil)
			nType = [objType intValue];
	}
	
	return nType;
}

+ (bool) isValidBirthYear:(NSString*)szYear {
	int nValue = [szYear integerValue], nYear;
	if (nValue == 0)
		return false;
	
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"yyyy"];
	NSString *yearString = [formatter stringFromDate:[NSDate date]];
	nYear = [yearString integerValue];
	
	if (nValue > nYear || nValue <= nYear - 100)
		return false;
	
	return true;
}
+ (BOOL) isValidEmail:(NSString *)checkString {
	BOOL stricterFilter = YES; 
	NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{1,4}";
	NSString *laxString = @".+@([A-Za-z0-9]+\\.)+[A-Za-z]{1}[A-Za-z]*";
	NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
	NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
	return [emailTest evaluateWithObject:checkString];
}
+ (BOOL) isValidPhoneNum:(NSString*)phoneNum {
	if (phoneNum == nil || [phoneNum isEqualToString:@""])
		return FALSE;

	return TRUE;
}

+ (NSString*) getGoogleAPI {
	return @"https://maps.googleapis.com/maps/api/place/nearbysearch/json?";
}
+ (NSString*) getGoogleMapKey {
	return @"AIzaSyDuePAo8t-EXy9nPgZ69P3MyibLxG6YQPg";
}
+ (NSString*) getGoogleServerKey {
	return @"AIzaSyDA7rjm1Il4Q8jxjR1lb6pOdjZ3I3F2g68";
}
+ (NSString*) getGoogleRoutesUrl {
	return @"http://maps.googleapis.com/maps/api/directions/json?";
}
+ (NSURL*) getFindPositionUrlForLongitude:(double)longitude Latitude:(double)latitude Name:(NSString*)name Type:(NSString*)type Radius:(NSString*)radius {
	NSString *szUrl = nil;

#if false
	NSString *szRadius = @"50000";
	latitude = -33.8670522;
	longitude = 151.19573628;
#else
	NSString *szRadius = radius;
#endif

	szUrl = [NSString stringWithFormat:@"%@location=%f,%f&radius=%@&sensor=false&key=%@", [Common getGoogleAPI], latitude, longitude, szRadius, [Common getGoogleServerKey]];

	if (name != nil || ![name isEqualToString:@""])
	{
		szUrl = [szUrl stringByAppendingFormat:@"&name=%@", name];
	}

#if true
	if (type != nil || ![type isEqualToString:@""])
	{
		szUrl = [szUrl stringByAppendingFormat:@"&types=%@", type];
	}
#endif

	return [NSURL URLWithString:szUrl];
}

+ (NSString *)image2String:(UIImage*)imgData {
	NSData *data = UIImageJPEGRepresentation(imgData, 0.5f);
	[Base64 initialize];
	NSString *strEncoded = [Base64 encode:data];
	return strEncoded;
}
+ (UIImage *)string2Image:(NSString*)string {
	[Base64 initialize];

	NSData *data = [Base64 decode:string];
	UIImage *imgResult = [UIImage imageWithData:data];

	return imgResult;
}

+ (void) showAlert : (NSString *)msg {
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Ride2Gather" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
	[alertView show];
}

+ (void)startDejalActivity:(UIView *)view {
	[DejalActivityView activityViewForView:view withLabel:@"waiting..." indicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
}
+ (void)endDejalActivity {
	[DejalActivityView removeView];
}

+ (bool)isReachable:(bool)showMessage {
	Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
	NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
	if (networkStatus == NotReachable)
	{
		NSLog(@"No internet connection");

		if (showMessage)
			[Common showAlert:@"Network disconnected"];
		return false;
	}
	else
	{
		NSLog(@"Connected to internet");
		return true;
	}
}

+ (bool)vibrateIsEnabled
{
	NSString *sbPath = @"/var/mobile/Library/Preferences/com.apple.springboard.plist";
	NSMutableDictionary *sbDict = [[NSMutableDictionary alloc] initWithContentsOfFile:sbPath];
	id vibrate = [sbDict objectForKey:@"silent-vibrate"];

	if (vibrate == nil)
		return NO;

	return [vibrate boolValue];
}

+ (void)showNotification:(NSString*)szMsg
{
	UILocalNotification* notif = [[UILocalNotification alloc] init];
	
	[notif setAlertBody:szMsg];
	[notif setFireDate:nil];			// Start notification immediately
	[notif setHasAction:NO];			// No alert button or slider
	[notif setRepeatCalendar:nil];		// User current calendar for notification
	[notif setRepeatInterval:0];		// No repeat
	[notif setSoundName:@"notify.caf"];
	
	[[UIApplication sharedApplication] scheduleLocalNotification:notif];
	
	AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

@end






