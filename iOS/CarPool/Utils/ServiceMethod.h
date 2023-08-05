//
//  STServiceInfo.h
//  4S-C
//
//  Created by RyuCJ on 24/10/2012.
//  Copyright (c) 2012 PIC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ServiceMethod : NSObject {
}

// Service Addr
+ (NSString *)getServiceAddress;

// user manage
+ (NSString *)cmdRequestRegister;
+ (NSString *)cmdIsRegistered;
+ (NSString *)cmdRequestLogin;
+ (NSString *)cmdRequestUserCredits;
+ (NSString *)cmdRequestUserProfile;
+ (NSString *)cmdRequestOppoAgree;
+ (NSString *)cmdRequestResetPassword;
+ (NSString *)cmdRequestNearestTaxiStand;
+ (NSString *)cmdRequestAddTaxiStand;
+ (NSString *)cmdRequestPairOff;
+ (NSString *)cmdRequestPairAgree;
+ (NSString *)cmdRequestUpdateProfile;
+ (NSString *)cmdRequestSendSMS;
+ (NSString *)cmdRequestFLLogin;

+ (NSString *)cmdRequestPairingHistoryCount;
+ (NSString *)cmdRequestPairingHistoryList;
+ (NSString *)cmdGetPairingHistoryList;
+ (NSString *)cmdRequestEvaluate;
+ (NSString *)cmdGetSharable;
+ (NSString *)cmdRequestShareLog;
+ (NSString *)cmdGetDestList;

+ (NSString *)cmdRequestTaxiStandList;

// User Pairing
+ (NSString *)cmdRequestPair;
+ (NSString *)cmdRequestIsPaired;

+ (NSString *)cmdRequestIsRegistedUser;
+ (NSString *)cmdIsNext;
+ (NSString *)cmdSetNext;


@end
