//
//  ServiceMethod.m
//  4S-C
//
//  Created by RyuCJ on 24/10/2012.
//  Copyright (c) 2012 . All rights reserved.
//

#import "ServiceMethod.h"

@implementation ServiceMethod

// Service Addrress
+ (NSString *) getServiceAddress
{
#if true
	return @"http://218.25.54.28:5041/Service.svc/";
#else
	return @"http://192.168.1.46:5000/Service.svc/";
#endif
}

// User Manage
+ (NSString *)cmdRequestRegister
{
	return @"RequestRegister";
}

+ (NSString*)cmdIsRegistered
{
	return @"RequestIsRegisteredUser";
}

+ (NSString *)cmdRequestLogin
{
	return @"RequestLogin";
}

+ (NSString *)cmdRequestPairOff
{
	return @"RequestPairOff";
}

+ (NSString *)cmdRequestUserCredits
{
	return @"RequestUserCredits";
}

+ (NSString *)cmdRequestUserProfile
{
	return @"RequestUserProfile";
}

+ (NSString *)cmdRequestOppoAgree
{
	return @"RequestOppoAgree";
}

+ (NSString *)cmdRequestPair
{
	return @"RequestPair";
}

+ (NSString *)cmdRequestNearestTaxiStand
{
	return @"RequestTaxiStand";
}

+ (NSString *)cmdRequestAddTaxiStand
{
	return @"RequestAddTaxiStand";
}

+ (NSString *)cmdRequestPairAgree
{
	return @"RequestPairAgree";
}

+ (NSString *)cmdRequestUpdateProfile
{
	return @"RequestUserProfileUpdate";
}

+ (NSString *)cmdRequestSendSMS
{
	return @"RequestSendSMS";
}

+ (NSString *)cmdRequestFLLogin
{
	return @"RequestFLLogin";
}

+ (NSString *)cmdRequestIsPaired
{
	return @"RequestIsPaired";
}

+ (NSString *)cmdRequestPairingHistoryCount
{
	return @"RequestPairingHistoryCount";
}

+ (NSString *)cmdRequestPairingHistoryList
{
	return @"RequestPairingHistoryList";
}

+ (NSString *)cmdGetPairingHistoryList
{
	return @"GetPairingHistoryList";
}

+ (NSString *)cmdRequestEvaluate
{
	return @"RequestEvaluate";
}

+ (NSString *)cmdRequestResetPassword
{
	return @"RequestResetPassword";
}

+ (NSString *)cmdGetSharable
{
	return @"GetSharable";
}

+ (NSString *)cmdRequestShareLog
{
	return @"RequestShareLog";
}

+ (NSString *)cmdGetDestList
{
	return @"GetDestList";
}

+ (NSString *)cmdRequestTaxiStandList
{
	return @"RequestTaxiStandList";
}

+ (NSString *)cmdRequestIsRegistedUser
{
	return @"RequestIsRegistedUser";
}

+ (NSString *)cmdIsNext
{
	return @"PairIsNext";
}

+ (NSString *)cmdSetNext
{
	return @"SetNextTurn";
}

@end
